import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/articulo_tienda.dart';
import '../models/mascota_model.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService instance = GamificationService._internal();

  GamificationService._internal();

  // Original fields
  int _hormigasoles = 60;
  int _rachaDias = 0;
  int _nivelHormiguero = 1;
  int _xp = 0;
  DateTime? _ultimaReclamacion;
  DateTime? _ultimoRegistroGasto;
  bool _inicializado = false;
  final Set<String> _inventario = {};
  final Set<String> _equipados = {};
  EstadoMascota _estado = EstadoMascota.feliz;

  // Original getters
  int get hormigasoles => _hormigasoles;
  int get rachaDias => _rachaDias;
  int get nivelHormiguero => _nivelHormiguero;
  int get xp => _xp;
  DateTime? get ultimaReclamacion => _ultimaReclamacion;
  DateTime? get ultimoRegistroGasto => _ultimoRegistroGasto;
  bool get inicializado => _inicializado;

  // Original level name
  String get nombreNivel {
    switch (_nivelHormiguero) {
      case 1:
        return 'Hormiguero Inicial';
      case 2:
        return 'Hormiguero en Crecimiento';
      case 3:
        return 'Hormiguero Organizado';
      case 4:
        return 'Hormiguero Avanzado';
      default:
        return 'Hormiguero Desarrollado';
    }
  }

  double get progresoNivel => (_xp % 100) / 100.0;

  // Original inventory/equipment
  Set<String> get inventario => Set.unmodifiable(_inventario);
  Set<String> get equipados => Set.unmodifiable(_equipados);
  bool estaComprado(String articuloId) => _inventario.contains(articuloId);
  bool estaEquipado(String articuloId) => _equipados.contains(articuloId);

  // Original pet state
  EstadoMascota get estado => _estado;
  cambiarEstado(EstadoMascota nuevoEstado) async {
    _estado = nuevoEstado;
    await _guardar();
    notifyListeners();
  }
  acariciarMascota() async {
    _hormigasoles += 2;
    _xp += 5;
    _estado = EstadoMascota.animada;
    await _guardar();
    notifyListeners();
  }

  // Original store methods
  Future<bool> comprarArticulo(ArticuloTienda articulo) async {
    if (_hormigasoles < articulo.precio) {
      return false;
    }
    _hormigasoles -= articulo.precio;
    _inventario.add(articulo.id);
    _equipados.add(articulo.id);
    _estado = EstadoMascota.animada;
    _xp += 15;
    await _guardar();
    notifyListeners();
    return true;
  }

  Future<void> alternarEquipado(String articuloId) async {
    if (!_inventario.contains(articuloId)) return;

    if (_equipados.contains(articuloId)) {
      _equipados.remove(articuloId);
    } else {
      _equipados.add(articuloId);
      _estado = EstadoMascota.feliz;
    }
    await _guardar();
    notifyListeners();
  }

  // NEW: Daily goal tracking
  /// Verifica si se puede reclamar el objetivo diario y lo reclama si es posible
  /// Retorna true si se reclamó, false si ya se reclamó hoy
  Future<bool> tentarObjetivoDiario() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    // Si nunca se reclamó, permite reclamar
    if (_ultimaReclamacion == null) {
      // Reclamar objetivo diario: +10 HS y +20 XP
      await _sumarHormigasoles(10, motivo: 'Objetivo diario');
      _ultimaReclamacion = ahora;
      await _guardar();
      notifyListeners();
      return true;
    }

    // Si la última reclamación fue en otro día, permite reclamar de nuevo
    final ultimaFecha =
        DateTime(_ultimaReclamacion!.year, _ultimaReclamacion!.month,
            _ultimaReclamacion!.day);
    final diferenciaDias =
        ahora.difference(ultimaFecha).inDays;

    if (diferenciaDias >= 1) {
      // Reclamar objetivo diario: +10 HS y +20 XP
      await _sumarHormigasoles(10, motivo: 'Objetivo diario');
      _ultimaReclamacion = ahora;
      await _guardar();
      notifyListeners();
      return true;
    }

    // Ya se reclamó hoy, no permite reclamar nuevamente
    return false;
  }

  /// Añade Hormigasoles y XP por registrar un gasto hormiga
  Future<void> registrarGastoHormiga() async {
    // Award 5 HS and 10 XP per gasto hormiga
    await _sumarHormigasoles(5, motivo: 'Gasto hormiga registrado');
    // Additional 5 XP to reach total of 15 XP
    _xp += 5;
    // Incrementar la racha
    await _incrementarRacha();
    notifyListeners();
  }

  /// Incrementa la racha al registrar un gasto hormiga
  Future<void> _incrementarRacha() async {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final ultimoRegistroHoy =
        _ultimoRegistroGasto != null
            ? DateTime(_ultimoRegistroGasto!.year, _ultimoRegistroGasto!.month,
                _ultimoRegistroGasto!.day)
            : null;

    // Si ya registró hoy, no incrementa la racha (se mantiene)
    if (ultimoRegistroHoy != null && ultimoRegistroHoy == hoy) {
      return;
    }

    // Primera vez o hace más de 24 horas: reinicia la racha a 1
    if (_ultimoRegistroGasto == null) {
      _rachaDias = 1;
    } else {
      final diferencia = ahora.difference(_ultimoRegistroGasto!).inHours;
      if (diferencia > 24) {
        _rachaDias = 1;
      } else {
        // Continuar la racha
        _rachaDias = _rachaDias + 1;
      }
    }

    _ultimoRegistroGasto = ahora;
    await _guardar();
    notifyListeners();
  }

  /// Método interno para sumar hormigasoles y XP y subir nivel
  Future<void> _sumarHormigasoles(int cantidad, {required String motivo}) async {
    _hormigasoles += cantidad;
    _xp += cantidad * 2;

    // Subida de nivel cada 100 XP
    final nuevoNivel = 1 + (_xp ~/ 100);
    if (nuevoNivel > _nivelHormiguero) {
      _nivelHormiguero = nuevoNivel;
    }

    await _guardar();
    notifyListeners();
  }

  // Original public method that other screens use
  Future<void> ganarHormigasoles(int cantidad, {required String motivo}) async {
    await _sumarHormigasoles(cantidad, motivo: motivo);
  }

  // Original initialization and saving
  Future<void> inicializar() async {
    if (_inicializado) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _hormigasoles = prefs.getInt('gamif_hs') ?? 60;
      _rachaDias = prefs.getInt('gamif_racha') ?? 0;
      _nivelHormiguero = prefs.getInt('gamif_nivel') ?? 1;
      _xp = prefs.getInt('gamif_xp') ?? 0;

      final reklamacion = prefs.getString('gamif_ultima_reclamacion');
      if (reklamacion != null) {
        _ultimaReclamacion = DateTime.tryParse(reklamacion);
      }

      final ultimoRegistro = prefs.getString('gamif_ultimo_registro_gasto');
      if (ultimoRegistro != null) {
        _ultimoRegistroGasto = DateTime.tryParse(ultimoRegistro);
      }

      _inicializado = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error al inicializar GamificationService: $e');
    }
  }

  Future<void> _guardar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('gamif_hs', _hormigasoles);
      await prefs.setInt('gamif_racha', _rachaDias);
      await prefs.setInt('gamif_nivel', _nivelHormiguero);
      await prefs.setInt('gamif_xp', _xp);
      await prefs.setString('gamif_ultima_reclamacion',
          _ultimaReclamacion?.toIso8601String() ?? '');
      await prefs.setString('gamif_ultimo_registro_gasto',
          _ultimoRegistroGasto?.toIso8601String() ?? '');
    } catch (e) {
      debugPrint('Error al guardar datos de GamificationService: $e');
    }
  }
}