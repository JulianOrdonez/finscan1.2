import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  // Email recipient for support
  final String supportEmail = 'julian.ordonez01@uceva.edu.co';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte al Usuario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Bienvenido al Centro de Soporte de FinScan!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Estamos aquí para ayudarte con cualquier pregunta o problema que puedas tener con la aplicación FinScan.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Preguntas Frecuentes (FAQs)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // You can add FAQ sections here, e.g.:
            // _buildFAQItem(
            //   question: '¿Cómo añado un nuevo gasto?',
            //   answer: 'Para añadir un gasto, ve a la pantalla de inicio y toca el botón "+" en la esquina inferior derecha. Selecciona "Gasto" y rellena los detalles.',
            // ),
            // _buildFAQItem(
            //   question: '¿Cómo cambio la moneda?',
            //   answer: 'Puedes cambiar la moneda en la sección de Ajustes.',
            // ),
            const SizedBox(height: 24),
            Text(
              'Contacto',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.email),
              onTap: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: supportEmail,
                  queryParameters: {
                    'subject': 'Soporte de FinScan',
                  },
                );

                if (!await launchUrl(emailLaunchUri)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir el cliente de correo.')),
                  );
                }
              },
              title: Text('Correo Electrónico'),
              subtitle: const Text('soporte@finscanapp.com'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: supportEmail,
                  queryParameters: {
                    'subject': 'Soporte FinScan',
                  },
                );

                if (!await launchUrl(emailLaunchUri)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir el cliente de correo.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Enviar Correo de Soporte'),
            ),
            ListTile(
              leading: Icon(Icons.web),
              title: Text('Sitio Web de Soporte'),
              subtitle: Text('www.finscanapp.com/support'),
              onTap: () { // TODO: Implement opening website
                // TODO: Implement opening website
              },
            ),
            // You can add more contact options like phone number, social media, etc.
            const SizedBox(height: 24),
            Text(
              'Recursos Adicionales',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.link),
              title: const Text('Guía de Usuario'),
              onTap: () {
                // TODO: Implement opening user guide
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          child: Text(answer),
        ),
      ],
    );
  }
}