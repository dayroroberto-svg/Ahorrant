import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/goal_model.dart';
import '../services/database_helper.dart';
import '../services/gamification_service.dart';
import '../theme/app_theme.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final GamificationService _gamif = GamificationService.instance;
  late List<Goal> _metas;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMetas();
  }

  Future<void> _cargarMetas() async {
    final metas = await _dbHelper.getAllGoals();
    setState(() {
      _metas = metas;
      _cargando = false;
    });
  }

  // Controlador para el formulario de crear meta
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _montoObjetivoController = TextEditingController();
  final _categoriaController = TextEditingController();

  // Mostrar diálogo para crear nueva meta
  Future<void> _mostrarDialogoCrearMeta() async {
    // Limpiar controladores
    _tituloController.clear();
    _descripcionController.clear();
    _montoObjetivoController.clear();
    _categoriaController.clear();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Crear Nueva Meta',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Título
                TextField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título de la meta',
                    labelStyle: GoogleFonts.fredoka(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: GoogleFonts.fredoka(fontSize: 14),
                  // Remove validator for now
                ),
                const SizedBox(height: 12),

                // Descripción
                TextField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    labelStyle: GoogleFonts.fredoka(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: GoogleFonts.fredoka(fontSize: 14),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Monto objetivo
                TextField(
                  controller: _montoObjetivoController,
                  decoration: InputDecoration(
                    labelText: 'Monto objetivo (S/)',
                    labelStyle: GoogleFonts.fredoka(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Ej: 500.00',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.fredoka(fontSize: 14),
                  // Remove validator for now
                ),
                const SizedBox(height: 12),

                // Categoría
                TextField(
                  controller: _categoriaController,
                  decoration: InputDecoration(
                    labelText: 'Categoría (ej: ahorro, viaje, educación)',
                    labelStyle: GoogleFonts.fredoka(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: GoogleFonts.fredoka(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.fredoka(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final titulo = _tituloController.text.trim();
                final descripcion = _descripcionController.text.trim();
                final montoObjetivoStr = _montoObjetivoController.text.trim();
                final categoria = _categoriaController.text.trim();

                if (titulo.isEmpty || montoObjetivoStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa los campos obligatorios'),
                      backgroundColor: AppColors.yellow,
                    ),
                  );
                  return;
                }

                final montoObjetivo = double.parse(montoObjetivoStr);

                final nuevaMeta = Goal(
                  titulo: titulo,
                  descripcion: descripcion,
                  montoObjetivo: montoObjetivo,
                  montoActual: 0.0,
                  categoria: categoria.isNotEmpty ? categoria : 'general',
                );

                await _dbHelper.insertGoal(nuevaMeta);
                await _cargarMetas();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Meta "${titulo}" creada exitosamente'),
                    backgroundColor: AppColors.teal,
                  ),
                );
              },
              child: Text(
                'Crear',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo para agregar ingresos a una meta
  Future<void> _mostrarDialogoAgregarIngreso(Goal meta) async {
    final _controlMonto = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Agregar Ingreso a "${meta.titulo}"',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _controlMonto,
                  decoration: InputDecoration(
                    labelText: 'Monto del ingreso (S/)',
                    labelStyle: GoogleFonts.fredoka(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Ej: 100.00',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.fredoka(fontSize: 14),
                  // Remove validator for now
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.fredoka(
                  color: AppColors.textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final montoStr = _controlMonto.text.trim();
                if (montoStr.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingrese un monto'),
                      backgroundColor: AppColors.yellow,
                    ),
                  );
                  return;
                }

                final monto = double.parse(montoStr);

                // Sumar el monto a la meta actual
                final metaActualizada = meta.copyWith(
                  montoActual: meta.montoActual + monto,
                );

                await _dbHelper.updateGoal(metaActualizada);

                // Verificar si se completó la meta
                if (metaActualizada.estaCompleta) {
                  // Calcular hormigasoles premio basándose en el monto objetivo
                  final hormigasolesPremio = _calcularHormigasolesPremio(metaActualizada.montoObjetivo);

                  // Agregar hormigasoles al servicio de gamificación
                  await _gamif.ganarHormigasoles(hormigasolesPremio, motivo: 'Meta completada');

                  // Mostrar éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Meta completada! 🎉',
                            style: GoogleFonts.fredoka(
                              fontWeight: FontWeight.bold,
                              color: AppColors.teal,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Has reclamado ${hormigasolesPremio} hormigasoles por completar "${meta.titulo}"',
                            style: GoogleFonts.fredoka(color: AppColors.textDark),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.softTeal,
                      duration: const Duration(seconds: 4),
                    ),
                  );

                  // Recargar metas para ocultar el botón reclamar
                  await _cargarMetas();
                } else {
                  // Actualizar progreso
                  await _dbHelper.updateGoal(metaActualizada);
                  await _cargarMetas();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ingreso de S/ $monto agregado. Progreso: ${metaActualizada.progresoString}',
                        style: GoogleFonts.fredoka(color: AppColors.textDark),
                      ),
                      backgroundColor: AppColors.softTeal,
                    ),
                  );
                }
              },
              child: Text(
                'Agregar',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Fórmula para calcular hormigasoles premio según el monto objetivo
  // Formulación: 1 hormiga sol por cada 10 S/ del objetivo, mínimo 5, máximo 50
  int _calcularHormigasolesPremio(double montoObjetivo) {
    // 1 HS por cada 10 S/ del objetivo
    final base = (montoObjetivo / 10).floor();
    // Mínimo 5 hormigasoles, máximo 50
    return base.clamp(5, 50);
  }

  // Eliminar meta
  Future<void> _eliminarMeta(Goal meta) async {
    await _dbHelper.deleteGoal(meta.id!);
    await _cargarMetas();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Meta eliminada'),
        backgroundColor: AppColors.yellow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Metas',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botón para crear nueva meta
            ElevatedButton.icon(
              onPressed: _mostrarDialogoCrearMeta,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(
                'Crear Nueva Meta',
                style: GoogleFonts.fredoka(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Si no hay metas o está cargando
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else if (_metas.isEmpty)
              // Mensaje cuando no hay metas
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.delete,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes metas aún',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crear tu primera meta arriba para comenzar',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              // Mostrar lista de metas
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _metas.length,
                itemBuilder: (context, index) {
                  final meta = _metas[index];
                  final esCompleta = meta.estaCompleta;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header de la meta
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                meta.titulo,
                                style: GoogleFonts.fredoka(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              if (esCompleta)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.teal,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Completada',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Progreso
                          Row(
                            children: [
                              Text(
                                'Progreso: ',
                                style: GoogleFonts.fredoka(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: meta.progresoPorcentaje / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.softTeal,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      esCompleta ? AppColors.teal : AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Monto actual / objetivo
                          Text(
                            '${meta.progresoFormato}',
                            style: GoogleFonts.fredoka(
                              fontSize: 14,
                              color: AppColors.darkBlue,
                            ),
                          ),

                          // Descripción y categoría
                          Text(
                            meta.descripcion.isNotEmpty
                                ? meta.descripcion
                                : 'Sin descripción',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Si la meta NO está completada: mostrar campo para agregar ingreso
                          if (!esCompleta)
                            ElevatedButton.icon(
                              onPressed: () => _mostrarDialogoAgregarIngreso(meta),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.softTeal,
                                foregroundColor: AppColors.darkBlue,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.arrow_upward_rounded,
                                  size: 18),
                              label: Text(
                                'Agregar Ingreso',
                                style: GoogleFonts.fredoka(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            )
                          // Si la meta SÍ está completada: mostrar botón reclamar
                          else
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Ya se manejó el reclamar dentro del agregar ingreso cuándo se completó
                                // Pero también podríamos tener un botón directo
                                if (!meta.estaCompleta) {
                                  // Esto shouldn't happen, but just in case
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Meta ya completada'),
                                      backgroundColor: AppColors.yellow,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: AppColors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.remove_circle_outlined),
                              label: Text(
                                'Reclamar Hormigasoles',
                                style: GoogleFonts.fredoka(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}