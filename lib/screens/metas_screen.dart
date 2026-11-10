import 'package:flutter/material.dart';

class MetasScreen extends StatelessWidget {
  const MetasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Metas'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flag,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Mis Metas',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Objetivo: S/ 500',
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Progreso: 60%',
              style: TextStyle(fontSize: 18),
            ),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.green[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
