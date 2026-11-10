import 'package:flutter/material.dart';

class HormigueroScreen extends StatelessWidget {
  const HormigueroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hormiguero'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.looks_one,
              size: 80,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tu Hormiguero',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Nivel 1: Hormiguero Inicial',
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Ver estado de la mascota y Hormigasoles
              },
              child: const Text('Ver mascota'),
            ),
          ],
        ),
      ),
    );
  }
}