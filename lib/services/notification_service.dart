import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio para manejar la lectura de notificaciones Android
/// Utiliza el NotificationListenerService nativo de Android
class NotificationService {
  /// Solicitar permisos de notificaciones al usuario
  static Future<bool> solicitarPermisos() async {
    try {
      // En un proyecto real, esto invocaría el Android NotificationListenerService
      // Para now, simulamos la solicitud
      // Platform.invokeMethod('solicitarPermisNotificaciones');
      return true; // Simulamos que el usuario aceptó
    } on PlatformException catch (e) {
      debugPrint('Error al solicitar permisos: ${e.message}');
      return false;
    }
  }

  /// Verificar si ya tienen permisos
  static Future<bool> hayPermisos() async {
    try {
      // Verificar estado actual de permisos
      // final result = await Platform.invokeMethod('verificarPermisos');
      return true; // Simulamos que tienen permisos
    } on PlatformException catch (e) {
      debugPrint('Error al verificar permisos: ${e.message}');
      return false;
    }
  }

  /// Procesar una notificación detectada
  static Map<String, dynamic>? procesarNotificacion(
      String titulo, String cuerpo) {
    try {
      // Lógica para extraer monto, fecha, tipo de operación de la notificación
      // Ejemplo: "Pago mediante Yape. Monto: S/ 8.00."
      final monto = _extraerMonto(cuerpo);
      final tipo = _determinarTipo(titulo, cuerpo);

      if (monto != null) {
        return {
          'monto': monto,
          'tipo': tipo, // 'ingreso' o 'egreso'
          'titulo': titulo,
          'descripcion': cuerpo,
          'fecha': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error procesando notificación: $e');
      return null;
    }
  }

  /// Extraer monto del texto de la notificación
  static double? _extraerMonto(String texto) {
    // Expresión regular para encontrar montos como "S/ 8.00" o "S/8.00"
    final regex = RegExp(r'S/[/\s]*[\d]+(?:[.,]\d{1,2})?');
    final match = regex.firstMatch(texto);
    if (match != null) {
      final montoTexto =
          (match.group(0) ?? '').replaceAll(RegExp(r'S/[/]'), '').trim();
      try {
        return double.parse(montoTexto);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Determinar si es ingreso o egreso basándose en el título y cuerpo
  static String _determinarTipo(String titulo, String cuerpo) {
    final textoCompleto = '$titulo $cuerpo'.toLowerCase();

    // Palabras clave para ingresos
    final palabrasIngreso = [
      'recibido',
      'transferencia recibida',
      'regaló',
      'bono'
    ];

    // Palabras clave para egresos
    final palabrasEgreso = ['pago', 'gastó', 'compró', 'transferencia', 'pagó'];

    if (palabrasIngreso.any(textoCompleto.contains)) {
      return 'ingreso';
    }
    if (palabrasEgreso.any(textoCompleto.contains)) {
      return 'egreso';
    }

    // Default a egreso si es una transacción financiera
    return 'egreso';
  }
}
