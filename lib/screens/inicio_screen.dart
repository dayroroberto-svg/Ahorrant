import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/notification_service.dart';
import '../services/database_helper.dart';
import 'hormiguero_screen.dart';
import 'armario_screen.dart';
import 'metas_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late DatabaseHelper _dbHelper;
  List<Transaction> _transactions = [];
  double _totalGastos = 0;
  double _totalIngresos = 0;
  String? _ultimaNotificacion;
  bool _permisosNotificaciones = false;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _cargarTransacciones();
    _solicitarPermisosInicial();
  }

  Future<void> _solicitarPermisosInicial() async {
    final tienePermisos = await NotificationService.solicitarPermisos();
    if (!mounted) return;
    setState(() {
      _permisosNotificaciones = tienePermisos;
    });
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
    for (var t in _transactions) {
      if (t.type == 'egreso') {
        gastos += t.amount;
      } else if (t.type == 'ingreso') {
        ingresos += t.amount;
      }
    }
    setState(() {
      _totalGastos = gastos;
      _totalIngresos = ingresos;
    });
  }

  Future<void> _procesarNotificacion(String titulo, String cuerpo) async {
    // Procesar la notificación y extraer datos
    final procesado = NotificationService.procesarNotificacion(titulo, cuerpo);

    if (procesado != null) {
      final monto = procesado['monto'] as double;
      final tipo = procesado['tipo'] as String;
      final descripcion = '${procesado['titulo']}: ${procesado['descripcion']}';

      // Crear transacción
      final transaccion = Transaction(
        id: null,
        amount: monto,
        date: DateTime.now(),
        type: tipo,
        category: _categorizarGasto(monto, tipo),
        origin: 'yape',
        description: descripcion,
        synced: false,
      );

      // Guardar en SQLite
      await _dbHelper.insertTransaction(transaccion);

      if (!mounted) return;
      // Actualizar lista local
      setState(() {
        _ultimaNotificacion = '$titulo - $cuerpo';
        _transactions.insert(0, transaccion);
        _calcularTotales();
      });

      // Mostrar confirmación
      _mostrarConfirmacion(transaccion, tipo);
    }
  }

  String _categorizarGasto(double amount, String type) {
    // Lógica simple de clasificación
    if (type == 'egreso') {
      if (amount < 10) return 'gastos hormiga';
      if (amount < 50) return 'entretenimiento';
      return 'alimentacion';
    }
    return 'ingreso';
  }

  void _mostrarConfirmacion(Transaction transaccion, String tipo) {
    String mensaje = 'Movimiento registrado: S/ ${transaccion.amount.toStringAsFixed(2)} - ${transaccion.category}';
    if (tipo == 'ingreso') {
      mensaje = 'Ingreso registrado: S/ ${transaccion.amount.toStringAsFixed(2)}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método simulado para procesar notificaciones entrantes de Yape
  void _simularNotificacionYape() {
    const titulo = 'Pago mediante Yape';
    const cuerpo = 'S/ 8.00 - Café';

    _procesarNotificacion(titulo, cuerpo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorrant'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Simular notificación Yape',
            onPressed: _simularNotificacionYape,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simularNotificacionYape,
        icon: const Icon(Icons.flash_on),
        label: const Text('Simular Yape'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de resumen financiero
              _buildResumenTarjeta(),

              const SizedBox(height: 24),

              // Lista de movimientos recientes
              const Text(
                'Movimientos Recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMovimientosList(),

              const SizedBox(height: 24),

              // Acceso rápido a módulos
              const Text(
                'Accesos Rápidos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildModulosGrid(context),

              const SizedBox(height: 32),

              // Estado de última notificación recibida
              if (_ultimaNotificacion != null)
                Container(
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
                          'Última detección: $_ultimaNotificacion',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),

              // Estado de permisos
              if (!_permisosNotificaciones)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Permisos de notificaciones pendientes. '
                          'Actívalos para detectar Yape automáticamente.',
                          style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
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
                  amount: (_transactions.where((t) => t.type == 'egreso' && t.category == 'gastos hormiga').length * 5).toDouble(),
                  color: Colors.orange,
                ),
                _buildResumenItem(
                  icon: Icons.trending_up,
                  label: 'Metas',
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
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

  Widget _buildMovimientosList() {
    if (_transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No hay movimientos registrados. Realiza una compra con Yape o presiona "Simular Yape" para comenzar.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length > 5 ? 5 : _transactions.length,
      itemBuilder: (context, index) {
        final t = _transactions[index];
        return ListTile(
          leading: Icon(
            t.type == 'egreso' ? Icons.remove : Icons.add,
            color: t.type == 'egreso' ? Colors.red : Colors.green,
          ),
          title: Text('${t.category}: S/ ${t.amount.toStringAsFixed(2)}'),
          subtitle: Text('${t.origin} - ${t.description ?? ""}'),
          trailing: Icon(
            t.synced ? Icons.check_circle : Icons.pending,
            color: t.synced ? Colors.green : Colors.orange,
          ),
        );
      },
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
          icon: Icons.home,
          label: 'Inicio',
          onTap: () {},
        ),
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
}
