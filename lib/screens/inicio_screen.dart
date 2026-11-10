import 'package:flutter/material.dart';
import 'package:ahorrant/services/notification_service.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ahorrant'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido a Ahorrant',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Esta aplicación te ayudará a controlar tus gastos hormiga\ny desarrollar hábitos de ahorro saludables.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                // Solicitar permisos de notificaciones
                final tienePermisos = await NotificationService.solicitarPermisos();
                if (tienePermisos) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permisos de notificaciones concedidos'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se concedieron permisos de notificaciones'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Comenzar'),
            ),
          ],
        ),
      ),
    );
  }
}