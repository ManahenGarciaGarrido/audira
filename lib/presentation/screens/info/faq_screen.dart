import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preguntas Frecuentes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('FAQs', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Encuentra respuestas a las preguntas más comunes',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          _buildFaqItem(
            context,
            '¿Cómo compro música?',
            'Navega por nuestra tienda, añade canciones o álbumes al carrito y procede al pago. Una vez completada la compra, la música estará disponible en tu biblioteca.',
          ),
          _buildFaqItem(
            context,
            '¿Puedo descargar las canciones?',
            'Sí, todas las canciones compradas pueden descargarse en formatos MP3, WAV, FLAC o MIDI según disponibilidad.',
          ),
          _buildFaqItem(
            context,
            '¿Cómo me convierto en artista?',
            'Durante el registro, selecciona la opción "Artista". Podrás subir tu música y gestionar tu contenido desde el Studio.',
          ),
          _buildFaqItem(
            context,
            '¿Qué comisión cobra Audira?',
            'Audira cobra una comisión del 15% sobre cada venta. El artista recibe el 85% de cada transacción.',
          ),
          _buildFaqItem(
            context,
            '¿Puedo escuchar música gratis?',
            'Los usuarios invitados pueden escuchar previews de 10 segundos. Los miembros que compren canciones pueden escucharlas completamente.',
          ),
          _buildFaqItem(
            context,
            '¿Cómo funcionan las listas de reproducción?',
            'Puedes crear listas personalizadas con las canciones que has comprado y organizarlas según tus preferencias.',
          ),
          _buildFaqItem(
            context,
            '¿Qué métodos de pago aceptan?',
            'Aceptamos tarjetas de crédito/débito, PayPal y otros métodos de pago móvil según tu región.',
          ),
          _buildFaqItem(
            context,
            '¿Puedo valorar canciones?',
            'Sí, puedes valorar y comentar cualquier canción o álbum que hayas comprado.',
          ),

          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.help_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '¿No encuentras lo que buscas?',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Contáctanos y te ayudaremos con cualquier duda',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/contact');
                    },
                    child: const Text('Ir a Contacto'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(question, style: Theme.of(context).textTheme.titleMedium),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
