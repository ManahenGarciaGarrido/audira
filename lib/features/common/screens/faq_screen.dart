import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preguntas Frecuentes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'FAQs',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            context,
            '¿Cómo creo una cuenta?',
            'Puedes crear una cuenta desde la pantalla de registro. Solo necesitas un email válido, un nombre de usuario y una contraseña.',
          ),
          _buildFAQItem(
            context,
            '¿Cómo compro música?',
            'Puedes agregar canciones o álbumes al carrito y proceder al pago. Necesitas tener una cuenta registrada para completar la compra.',
          ),
          _buildFAQItem(
            context,
            '¿Puedo crear playlists?',
            'Sí, los usuarios registrados pueden crear playlists personalizadas y agregar sus canciones favoritas.',
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.help_outline,
                  size: 48,
                  color: AppTheme.textGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  '¿No encuentras tu pregunta?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contacto próximamente'),
                      ),
                    );
                  },
                  child: const Text('Contacta con nosotros'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textGrey,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
