import 'package:flutter/material.dart';

class ArmarioScreen extends StatelessWidget {
  const ArmarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Armario'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 80,
              color: Colors.brown,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tienda Virtual',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Personaliza a tu mascota con accesorios',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildArticulo('Sombrero de explorador', 50, Icons.),
            _buildArticulo('Mochila aventurera', 80, Icons.bag),
            _buildArticulo('Gafas de sol', 40, Icons),
          ],
        ),
      ),
    );
  }

  Widget _buildArticulo(String nombre, int precio, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.brown[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.brown),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children [
                Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$precio HS'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}