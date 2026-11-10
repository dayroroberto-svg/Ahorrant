import 'dart:async';

import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import 'armario_screen.dart';
import 'hormiguero_screen.dart';
import 'metas_screen.dart';

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
  int _pendientesSync = 0;
  String? _ultimaNotificacion;
  bool _permisosNotificaciones = false;
  bool _sincronizando = false;

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
      _pendientesSync = transacciones.where((t) => !t.synced).length;
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
    if (!_activo) {
      _colaEventos.add(notificacion);
      return;
    }

    final monto = _extraerMonto(notificacion.text) ??
        _extraerMonto(notificacion.title);
    if (monto == null) return;

    if (!mounted) return;
    setState(() {
      _ultimaNotificacion =
          '${notificacion.title} - ${notificacion.text}';
    });

    final tipo = await _mostrarDialogoTipo();
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
    if (!mounted) return;
    await _cargarTransacciones();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tipo == 'ingreso' ? 'Ingreso' : 'Gasto'} registrado: '
          'S/ ${monto.toStringAsFixed(2)} - $categoria',
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

  Future<String?> _mostrarDialogoTipo() {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Se detecto un movimiento de dinero'),
          content: const Text('¿Es un ingreso o un egreso?'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'ingreso'),
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              label: const Text('Ingreso'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'egreso'),
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              label: const Text('Egreso'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Movimiento detectado: S/ ${monto.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                const Text(
                  '¿Que tipo de gasto fue?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categoriasEgreso.map((categoria) {
                    return ActionChip(
                      avatar: const Icon(Icons.label_outline, size: 16),
                      label: Text(_etiquetaCategoria(categoria)),
                      onPressed: () => Navigator.pop(context, categoria),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Descartar'),
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
        return 'Gasto hormiga';
      case 'necesario':
        return 'Necesario';
      case 'alimentacion':
        return 'Alimentacion';
      case 'transporte':
        return 'Transporte';
      case 'entretenimiento':
        return 'Entretenimiento';
      default:
        return 'Otro';
    }
  }

  Future<void> _sincronizar() async {
    if (_sincronizando) return;
    setState(() => _sincronizando = true);
    final resultado = await SyncService.sincronizarPendientes();
    if (!mounted) return;
    await _cargarTransacciones();
    if (!mounted) return;
    setState(() => _sincronizando = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resultado.mensaje)),
    );
  }

  void _simularNotificacionYape() {
    _onNotificacionDetectada(
      DetectedNotification(
        title: 'Pago mediante Yape',
        text: 'S/ 8.00 - Cafe',
        timestamp: DateTime.now(),
      ),
    );
  }

  void _simularCorreo() {
    _onNotificacionDetectada(
      DetectedNotification(
        packageName: 'com.google.android.gm',
        title: 'BCP: Consumo con tu tarjeta',
        text: 'Se realizo un consumo de S/ 45.00 en tu tarjeta de credito.',
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
      const SnackBar(content: Text('Marcado como gasto hormiga')),
    );
  }

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '¡Hola, amiga! tu hormiguita ahorradora esta vigilando tus gastos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ClipOval(
            child: Image.asset(
              'assets/hormiguita.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 40,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosList() {
    if (_transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No hay movimientos registrados. Realiza un pago o espera el correo '
          'bancario; tambien puedes usar "Simular correo" para probar.',
        ),
      );
    }

    return Column(
      children: [
        for (final t in _transactions.take(5))
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (t.type == 'egreso'
                          ? Colors.red
                          : Colors.green)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  t.type == 'egreso' ? Icons.remove : Icons.add,
                  color: t.type == 'egreso' ? Colors.red : Colors.green,
                  size: 20,
                ),
              ),
              title: Text(
                '${t.category}: S/ ${t.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${t.origin} - ${t.description ?? ""}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'hormiga') {
                    _marcarGastoHormiga(t);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'hormiga',
                    child: ListTile(
                      leading: Icon(Icons.label_outline),
                      title: Text('Gasto hormiga'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResumenTarjeta() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Financiero',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResumenItem(
                  icon: Icons.remove,
                  label: 'Gastos',
                  amount: _totalGastos,
                  color: Colors.red,
                ),
                _buildResumenItem(
                  icon: Icons.add,
                  label: 'Ingresos',
                  amount: _totalIngresos,
                  color: Colors.green,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildResumenItem(
                  icon: Icons.savings_outlined,
                  label: 'Hormigasoles',
                  amount: _calcularHormigasoles(),
                  color: Colors.orange,
                ),
                _buildResumenItem(
                  icon: Icons.trending_up,
                  label: 'Progreso metas',
                  amount: _calcularProgresoMetas(),
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              'S/ ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSyncCard() {
    return Card(
      child: ListTile(
        leading: Icon(
          _pendientesSync == 0 ? Icons.cloud_done : Icons.cloud_queue,
          color: _pendientesSync == 0 ? Colors.green : Colors.orange,
        ),
        title: const Text('Sincronizacion'),
        subtitle: Text(
          _pendientesSync == 0
              ? 'Todo sincronizado'
              : '$_pendientesSync movimiento(s) en cola local',
        ),
        trailing: _sincronizando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: _sincronizar,
                child: const Text('Sincronizar'),
              ),
      ),
    );
  }

  Widget _buildModulosGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        _moduloTarjeta(
          context,
          icon: Icons.looks_one,
          label: 'Hormiguero',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HormigueroScreen()),
          ),
        ),
        _moduloTarjeta(
          context,
          icon: Icons.shopping_bag,
          label: 'Armario',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ArmarioScreen()),
          ),
        ),
        _moduloTarjeta(
          context,
          icon: Icons.flag,
          label: 'Metas',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MetasScreen()),
          ),
        ),
        _moduloTarjeta(
          context,
          icon: Icons.mail_outline,
          label: 'Simular correo',
          onTap: _simularCorreo,
        ),
      ],
    );
  }

  Widget _moduloTarjeta(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.orange),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimaNotificacion() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Ultima deteccion: $_ultimaNotificacion',
              style: const TextStyle(fontSize: 12, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermisosPendientes() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Permisos de notificaciones pendientes. Activalos para detectar '
              'correos bancarios y Yape automaticamente.',
              style: TextStyle(fontSize: 12, color: Colors.deepOrange),
            ),
          ),
          TextButton(
            onPressed: _activarPermisos,
            child: const Text('Activar'),
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
        title: const Text('Ahorrant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            tooltip: 'Simular correo bancario',
            onPressed: _simularCorreo,
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Simular notificacion Yape',
            onPressed: _simularNotificacionYape,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simularCorreo,
        icon: const Icon(Icons.mail_outline),
        label: const Text('Simular correo'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGreetingCard(),
              const SizedBox(height: 16),
              _buildResumenTarjeta(),
              const SizedBox(height: 16),
              _buildSyncCard(),
              const SizedBox(height: 24),
              const Text(
                'Movimientos Recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMovimientosList(),
              const SizedBox(height: 24),
              const Text(
                'Accesos Rapidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildModulosGrid(context),
              const SizedBox(height: 24),
              if (_ultimaNotificacion != null) _buildUltimaNotificacion(),
              if (!_permisosNotificaciones) _buildPermisosPendientes(),
            ],
          ),
        ),
      ),
    );
  }
}
