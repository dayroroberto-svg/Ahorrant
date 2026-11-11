import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/articulo_tienda.dart';
import '../models/mascota_model.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService instance = GamificationService._internal();

  GamificationService._internal();

  int _hormigasoles = 60;
  int _rachaDias = 3;
  int _nivelHormiguero = 1;
  int _xp = 45;
  EstadoMascota _estado = EstadoMascota.feliz;
  final Set<String> _inventario = {};
  final Set<String> _equipados = {};
  bool _inicializado = false;

  int get hormigasoles => _hormigasoles;
  int get rachaDias => _rachaDias;
  int get nivelHormiguero => _nivelHormiguero;
  int get xp => _xp;
  EstadoMascota get estado => _estado;
  Set<String> get inventario => Set.unmodifiable(_inventario);
  Set<String> get equipados => Set.unmodifiable(_equipados);
  bool get inicializado => _inicializado;

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

  Future<void> inicializar() async {
    if (_inicializado) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _hormigasoles = prefs.getInt('gamif_hs') ?? 60;
      _rachaDias = prefs.getInt('gamif_racha') ?? 3;
      _nivelHormiguero = prefs.getInt('gamif_nivel') ?? 1;
      _xp = prefs.getInt('gamif_xp') ?? 45;

      final estadoIndex = prefs.getInt('gamif_estado');
      if (estadoIndex != null &&
          estadoIndex >= 0 &&
          estadoIndex < EstadoMascota.values.length) {
        _estado = EstadoMascota.values[estadoIndex];
      }

      final inv = prefs.getStringList('gamif_inventario') ?? [];
      _inventario.addAll(inv);

      final eq = prefs.getStringList('gamif_equipados') ?? [];
      _equipados.addAll(eq);

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
      await prefs.setInt('gamif_estado', _estado.index);
      await prefs.setStringList('gamif_inventario', _inventario.toList());
      await prefs.setStringList('gamif_equipados', _equipados.toList());
    } catch (e) {
      debugPrint('Error al guardar datos de GamificationService: $e');
    }
  }

  /// Añade Hormigasoles y XP por acciones positivas
  Future<void> ganarHormigasoles(int cantidad, {required String motivo}) async {
    _hormigasoles += cantidad;
    _xp += (cantidad * 2);

    // Subida de nivel cada 100 XP
    final nuevoNivel = 1 + (_xp ~/ 100);
    if (nuevoNivel > _nivelHormiguero) {
      _nivelHormiguero = nuevoNivel;
      _estado = EstadoMascota.animada;
    } else {
      _estado = EstadoMascota.animada;
    }

    await _guardar();
    notifyListeners();
  }

  /// Compra un accesorio de la tienda descontando Hormigasoles del balance
  Future<bool> comprarArticulo(ArticuloTienda articulo) async {
    if (_hormigasoles < articulo.precio) {
      return false;
    }

    _hormigasoles -= articulo.precio;
    _inventario.add(articulo.id);
    _equipados.add(articulo.id); // Lo equipa automáticamente al comprar
    _estado = EstadoMascota.animada;
    _xp += 15;

    await _guardar();
    notifyListeners();
    return true;
  }

  /// Alterna si un artículo comprado está equipado o en el guardarropa
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

  /// Cambia el estado emocional de la mascota
  Future<void> cambiarEstado(EstadoMascota nuevoEstado) async {
    _estado = nuevoEstado;
    await _guardar();
    notifyListeners();
  }

  /// Acción interactiva para consentir a la mascota
  Future<void> acariciarMascota() async {
    _hormigasoles += 2;
    _xp += 5;
    _estado = EstadoMascota.animada;
    await _guardar();
    notifyListeners();
  }

  bool estaComprado(String articuloId) => _inventario.contains(articuloId);
  bool estaEquipado(String articuloId) => _equipados.contains(articuloId);
}

