import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../services/gamification_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen>
    with WidgetsBindingObserver {
  late final DatabaseHelper _dbHelper;
  StreamSubscription<DetectedNotification>? _suscripcion;
  final List<DetectedNotification> _colaEventos = [];
  bool _activo = true;

  List<Transaction> _transactions = [];
  double _totalGastos = 0;
  double _totalIngresos = 0;
  String? _ultimaNotificacion;
  bool _permisosNotificaciones = false;
  final List<String> _avisosProcesados = [];

  static const List<String> _categoriasEgreso = [
    'gastos hormiga',
    'necesario',
    'alimentacion',
    'transporte',
    'entretenimiento',
    'otro',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dbHelper = DatabaseHelper.instance;
    _inicializar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _suscripcion?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _activo = state == AppLifecycleState.resumed;
    if (_activo) {
      _actualizarPermisos();
      _procesarPendientesNativas();
      _procesarColaEventos();
    }
  }

  Future<void> _inicializar() async {
    await GamificationService.instance.inicializar();
    _suscripcion =
        NotificationService.stream.listen(_onNotificacionDetectada);
    await _actualizarPermisos();
    await _cargarTransacciones();
    await _procesarPendientesNativas();
  }

  Future<void> _actualizarPermisos() async {
    final tienePermisos = await NotificationService.hayPermisos();
    if (!mounted) return;
    setState(() {
      _permisosNotificaciones = tienePermisos;
    });
  }

  Future<void> _activarPermisos() async {
    await NotificationService.solicitarPermisos();
    await _actualizarPermisos();
  }

  Future<void> _cargarTransacciones() async {
    final transacciones = await _dbHelper.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = transacciones;
      _calcularTotales();
    });
  }

  void _calcularTotales() {
    double gastos = 0;
    double ingresos = 0;
    for (final t in _transactions) {
      if (t.type == 'egreso') {
        gastos += t.amount;
      } else if (t.type == 'ingreso') {
        ingresos += t.amount;
      }
    }
    _totalGastos = gastos;
    _totalIngresos = ingresos;
  }

  Future<void> _procesarPendientesNativas() async {
    final pendientes = await NotificationService.obtenerPendientes();
    for (final notificacion in pendientes) {
      await _onNotificacionDetectada(notificacion);
    }
  }

  Future<void> _onNotificacionDetectada(
      DetectedNotification notificacion) async {
    debugPrint('[AhorrantFlutter] Notificacion recibida: '
        'pkg=${notificacion.packageName} '
        'title="${notificacion.title}" text="${notificacion.text}" '
        'activo=$_activo mounted=$mounted');

    // Evitar procesar la misma notificacion dos veces (stream + cola pendiente).
    // Se compara titulo+texto dentro de una ventana de 10 segundos.
    final clave =
        '${notificacion.title}|${notificacion.text}';
    final ahora = DateTime.now();
    _avisosProcesados.removeWhere((item) {
      final partes = item.split('||');
      final fecha = DateTime.tryParse(partes[0]) ?? DateTime(2000);
      return ahora.difference(fecha).inSeconds > 10;
    });
    final duplicado = _avisosProcesados.any((item) {
      final partes = item.split('||');
      return partes.length > 1 && partes[1] == clave;
    });
    if (duplicado) {
      debugPrint('[AhorrantFlutter] Duplicado detectado, se ignora');
      return;
    }
    _avisosProcesados.add('${ahora.toIso8601String()}||$clave');
    if (_avisosProcesados.length > 50) {
      _avisosProcesados.removeAt(0);
    }

    if (!_activo) {
      debugPrint('[AhorrantFlutter] App en background, se encola');
      _colaEventos.add(notificacion);
      return;
    }

    final rawMonto = _extraerMonto(notificacion.text) ?? _extraerMonto(notificacion.title);
    debugPrint('[AhorrantFlutter] Monto extraido: $rawMonto');

    if (rawMonto == null) {
      // No hay monto: mostrar aviso breve y no abrir dialogo.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.teal,
          content: Text(
            'Notificación de ${notificacion.origen} recibida (sin monto)',
            style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final monto = rawMonto;

    if (!mounted) {
      debugPrint('[AhorrantFlutter] Widget no montado, se ignora');
      return;
    }
    setState(() {
      _ultimaNotificacion =
          '${notificacion.title} - ${notificacion.text}';
    });

    debugPrint('[AhorrantFlutter] Abriendo dialogo por S/ $monto');
    final tipo = await _mostrarDialogoTipo(monto);
    if (tipo == null) return;

    String? categoria;
    if (tipo == 'ingreso') {
      categoria = 'ingreso';
    } else {
      categoria = await _mostrarDialogoClasificacion(
          monto, '${notificacion.title}: ${notificacion.text}');
      if (categoria == null) return;
    }

    final transaccion = Transaction(
      amount: monto,
      date: DateTime.now(),
      type: tipo,
      category: categoria,
      origin: notificacion.origen,
      description: '${notificacion.title}: ${notificacion.text}',
      synced: false,
    );

    await _dbHelper.insertTransaction(transaccion);
    // Recompensa por notificaciones de pagos (Yape o Plin)
    if (notificacion.origen == 'yape' || notificacion.origen == 'plin') {
      // Award 5 Hormigasoles for each detected payment notification
      await GamificationService.instance.ganarHormigasoles(5, motivo: '${notificacion.origen} pago detectado');
    }
    if (!mounted) return;
    await _cargarTransacciones();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.teal,
        content: Text(
          '${tipo == 'ingreso' ? 'Ingreso' : 'Gasto'} registrado: S/ ${monto.toStringAsFixed(2)} - ${_etiquetaCategoria(categoria)}',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double? _extraerMonto(String texto) {
    final regex = RegExp(r'S\/\.?\s*([\d]+(?:[.,]\d{1,2})?)');
    final match = regex.firstMatch(texto);
    if (match == null) return null;
    final montoTexto = (match.group(1) ?? '').replaceAll(',', '.');
    return double.tryParse(montoTexto);
  }

  Future<String?> _mostrarDialogoTipo(double monto) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            '💰 Movimiento detectado',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'S/ ${monto.toStringAsFixed(2)}',
                style: GoogleFonts.fredoka(
                  fontSize: 36,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Es un ingreso o un egreso?',
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'ingreso'),
              icon: const Icon(Icons.add_circle_outline, color: AppColors.teal),
              label: Text(
                'Ingreso',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'egreso'),
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.expenseRed),
              label: Text(
                'Egreso',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.expenseRed,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _procesarColaEventos() async {
    while (_colaEventos.isNotEmpty && mounted) {
      final notificacion = _colaEventos.removeAt(0);
      await _onNotificacionDetectada(notificacion);
    }
  }

  Future<String?> _mostrarDialogoClasificacion(
    double monto,
    String descripcion,
  ) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gasto: S/ ${monto.toStringAsFixed(2)}',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Qué tipo de gasto fue?',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categoriasEgreso.map((categoria) {
                    final esHormiga = categoria == 'gastos hormiga';
                    return ActionChip(
                      avatar: Icon(
                        _iconoPorCategoria(categoria),
                        size: 18,
                        color: esHormiga ? AppColors.darkBlue : AppColors.teal,
                      ),
                      backgroundColor: esHormiga ? AppColors.yellow : AppColors.softTeal,
                      label: Text(
                        _etiquetaCategoria(categoria),
                        style: GoogleFonts.fredoka(
                          fontWeight: FontWeight.bold,
                          color: esHormiga ? AppColors.darkBlue : AppColors.teal,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, categoria),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Descartar',
                      style: GoogleFonts.fredoka(color: AppColors.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _etiquetaCategoria(String categoria) {
    switch (categoria) {
      case 'gastos hormiga':
        return 'Gasto hormiga 🐜';
      case 'necesario':
        return 'Necesario';
      case 'alimentacion':
        return 'Alimentación';
      case 'transporte':
        return 'Transporte';
      case 'entretenimiento':
        return 'Entretenimiento';
      default:
        return 'Otro';
    }
  }

  IconData _iconoPorCategoria(String categoria) {
    switch (categoria) {
      case 'gastos hormiga':
        return Icons.pest_control_rounded;
      case 'necesario':
        return Icons.check_circle_outline_rounded;
      case 'alimentacion':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_bus_rounded;
      case 'entretenimiento':
        return Icons.sports_esports_rounded;
      case 'ingreso':
        return Icons.savings_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _simularNotificacionYape() {
    _onNotificacionDetectada(
      DetectedNotification(
        title: 'Pago mediante Yape',
        text: 'S/ 8.00 - Café matutino',
        timestamp: DateTime.now(),
      ),
    );
  }

  void _simularCorreo() {
    _onNotificacionDetectada(
      DetectedNotification(
        packageName: 'com.google.android.gm',
        title: 'BCP: Consumo con tu tarjeta',
        text: 'Se realizó un consumo de S/ 45.00 en tu tarjeta de débito.',
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _marcarGastoHormiga(Transaction t) async {
    final actualizado = t.copyWith(category: 'gastos hormiga');
    await _dbHelper.updateTransaction(actualizado);
    if (!mounted) return;
    await _cargarTransacciones();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.yellow,
        content: Text(
          '¡Movimiento clasificado como Gasto Hormiga! 🐜',
          style: GoogleFonts.fredoka(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleMovimiento(Transaction t) {
    final esEgreso = t.type == 'egreso';
    final fechaStr = '${t.date.day.toString().padLeft(2, '0')}/${t.date.month.toString().padLeft(2, '0')}/${t.date.year} • ${t.date.hour.toString().padLeft(2, '0')}:${t.date.minute.toString().padLeft(2, '0')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Información del Movimiento',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: esEgreso
                        ? const Color(0xFFFFF0F0)
                        : AppColors.softTeal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: esEgreso
                          ? AppColors.expenseRed.withValues(alpha: 0.3)
                          : AppColors.teal.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            esEgreso ? 'Egreso / Gasto' : 'Ingreso',
                            style: GoogleFonts.fredoka(
                              fontSize: 13,
                              color: esEgreso
                                  ? AppColors.expenseRed
                                  : AppColors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${esEgreso ? '-' : '+'} S/ ${t.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.fredoka(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: esEgreso
                                  ? AppColors.expenseRed
                                  : AppColors.teal,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: esEgreso
                              ? AppColors.expenseRed
                              : AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          esEgreso
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _detalleFila(
                  icono: _iconoPorCategoria(t.category),
                  titulo: 'Categoría',
                  valor: _etiquetaCategoria(t.category),
                  destacadoColor: t.category == 'gastos hormiga'
                      ? AppColors.yellow
                      : null,
                ),
                const Divider(height: 16),
                _detalleFila(
                  icono: Icons.account_balance_wallet_rounded,
                  titulo: 'Origen del Registro',
                  valor: t.origin.toUpperCase(),
                ),
                const Divider(height: 16),
                _detalleFila(
                  icono: Icons.calendar_today_rounded,
                  titulo: 'Fecha y Hora',
                  valor: fechaStr,
                ),
                const Divider(height: 16),
                _detalleFila(
                  icono: Icons.description_rounded,
                  titulo: 'Detalle / Concepto',
                  valor: (t.description != null && t.description!.isNotEmpty)
                      ? t.description!
                      : 'Sin descripción adicional',
                ),
                const SizedBox(height: 24),
                if (esEgreso && t.category != 'gastos hormiga')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.darkBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _marcarGastoHormiga(t);
                    },
                    icon: const Icon(Icons.pest_control_rounded),
                    label: Text(
                      'Marcar como Gasto Hormiga 🐜',
                      style: GoogleFonts.fredoka(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.fredoka(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detalleFila({
    required IconData icono,
    required String titulo,
    required String valor,
    Color? destacadoColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.softCyan,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 20, color: AppColors.teal),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                if (destacadoColor != null)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: destacadoColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      valor,
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  )
                else
                  Text(
                    valor,
                    style: GoogleFonts.fredoka(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cuadro con el mensaje y la imagen: mas ancho, llamativo y amigable
  Widget _buildGreetingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '¡Hola, amiga!',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ahorrante',
                        style: GoogleFonts.fredoka(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tu hormiguita ahorradora está vigilando tus gastos y cuidando cada monedita 🐜✨',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softYellow,
              border: Border.all(color: AppColors.yellow, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/hormiguita.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.pest_control_rounded,
                    color: AppColors.teal,
                    size: 42,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenTarjeta() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.softCyan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen Financiero',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Este mes',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumenItem(
                icon: Icons.arrow_upward_rounded,
                label: 'Gastos',
                amount: _totalGastos,
                color: AppColors.expenseRed,
                bgColor: const Color(0xFFFFF0F0),
              ),
              _buildResumenItem(
                icon: Icons.arrow_downward_rounded,
                label: 'Ingresos',
                amount: _totalIngresos,
                color: AppColors.teal,
                bgColor: AppColors.softTeal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumenItem(
                icon: Icons.pest_control_rounded,
                label: 'Hormigasoles',
                amount: _calcularHormigasoles(),
                color: AppColors.darkBlue,
                bgColor: AppColors.softYellow,
                esMonedaVirtual: true,
              ),
              _buildResumenItem(
                icon: Icons.flag_rounded,
                label: 'Metas',
                amount: _calcularProgresoMetas(),
                color: AppColors.cyan,
                bgColor: AppColors.softCyan,
                esPorcentaje: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumenItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
    required Color bgColor,
    bool esPorcentaje = false,
    bool esMonedaVirtual = false,
  }) {
    String formattedAmount = 'S/ ${amount.toStringAsFixed(2)}';
    if (esPorcentaje) {
      formattedAmount = '${amount.toStringAsFixed(0)}%';
    } else if (esMonedaVirtual) {
      formattedAmount = '${amount.toInt()} HS';
    }

    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedAmount,
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Lista de movimientos recientes: mas notoria y con click para ver detalles
  Widget _buildMovimientosList() {
    if (_transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.softTeal),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.cyan,
            ),
            const SizedBox(height: 10),
            Text(
              'Aún no hay movimientos',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Realiza un pago con Yape o presiona "Simular" arriba para registrar tu primer gasto.',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final t in _transactions.take(6))
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: t.type == 'egreso'
                    ? const Color(0xFFFFEBEE)
                    : AppColors.softTeal,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBlue.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _mostrarDetalleMovimiento(t),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Icono con fondo temático
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: t.type == 'egreso'
                              ? const Color(0xFFFFEBEE)
                              : AppColors.softTeal,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconoPorCategoria(t.category),
                          color: t.type == 'egreso'
                              ? AppColors.expenseRed
                              : AppColors.teal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Textos centrales
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _etiquetaCategoria(t.category),
                                    style: GoogleFonts.fredoka(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.softCyan,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.origin.toUpperCase(),
                                    style: GoogleFonts.fredoka(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              t.description ?? 'Sin descripción',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Monto y chevron indicador de click
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${t.type == 'egreso' ? '-' : '+'} S/ ${t.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.fredoka(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: t.type == 'egreso'
                                  ? AppColors.expenseRed
                                  : AppColors.teal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ver detalle',
                                style: GoogleFonts.fredoka(
                                  fontSize: 10,
                                  color: AppColors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: AppColors.teal,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUltimaNotificacion() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softCyan,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded,
              color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Última detección: $_ultimaNotificacion',
              style: GoogleFonts.fredoka(
                fontSize: 12.5,
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermisosPendientes() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softYellow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.yellow),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.darkBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Permisos pendientes. Actívalos para detectar correos bancarios y Yape automáticamente.',
              style: GoogleFonts.fredoka(
                fontSize: 12,
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.darkBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _activarPermisos,
            child: Text(
              'Activar',
              style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  double _calcularHormigasoles() {
    final hormiga =
        _transactions.where((t) => t.category == 'gastos hormiga').length;
    return (hormiga * 5).toDouble();
  }

  double _calcularProgresoMetas() {
    if (_transactions.isEmpty) return 0;
    final ingresos = _transactions
        .where((t) => t.type == 'ingreso')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final gastos = _transactions
        .where((t) => t.type == 'egreso')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    if (ingresos == 0) return 0;
    return ((ingresos - gastos) / ingresos * 100).clamp(0.0, 100.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const AhorrantLogoTitle(fontSize: 24),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.softCyan,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: AppColors.teal,
              ),
            ),
            tooltip: 'Simular correo bancario',
            onPressed: _simularCorreo,
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.softYellow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.yellow),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                size: 20,
                color: AppColors.darkBlue,
              ),
            ),
            tooltip: 'Simular notificación Yape',
            onPressed: _simularNotificacionYape,
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simularNotificacionYape,
        icon: const Icon(Icons.flash_on_rounded, color: AppColors.darkBlue),
        label: Text(
          'Simular Yape',
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        backgroundColor: AppColors.yellow,
        elevation: 3,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGreetingCard(),
            const SizedBox(height: 18),
            _buildResumenTarjeta(),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimientos Recientes',
                  style: GoogleFonts.fredoka(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                if (_transactions.isNotEmpty)
                  Text(
                    'Toca para ver detalle',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      color: AppColors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            _buildMovimientosList(),
            const SizedBox(height: 20),
            if (_ultimaNotificacion != null) _buildUltimaNotificacion(),
            if (!_permisosNotificaciones) _buildPermisosPendientes(),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }
}
