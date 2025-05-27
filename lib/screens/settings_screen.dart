import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme_provider.dart'; // Importa ThemeProvider
import '../models/expense.dart'; // Por si luego se usa
import '../models/income.dart';  // Por si luego se usa

class SettingsScreen extends StatelessWidget {
  final String? userId;

  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final authService = Provider.of<AuthService>(context);
    final TextEditingController supportController = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            const Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 30, color: Colors.blueAccent),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      currentUser?.email ?? 'Usuario no disponible',
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Opción: Cambiar moneda
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.blueAccent),
              title: const Text('Cambiar moneda', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implementar funcionalidad de cambio de moneda
              },
            ),
            const Divider(),

            // Opción: Modo oscuro
            Consumer<ThemeProvider>( // Usa Consumer para escuchar cambios en ThemeProvider
              builder: (context, themeProvider, child) {
                return ListTile(
              leading: const Icon(Icons.brightness_6, color: Colors.blueAccent),
              title: const Text('Modo oscuro', style: TextStyle(fontSize: 18)),
                  trailing: Switch( // Usa un Switch en lugar del icono
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(); // Llama al método para cambiar el tema
                    },
                  ),
            ),
            const Divider(),

            // Opción: Generar reporte
            ListTile(
              leading: const Icon(Icons.insert_chart, color: Colors.blueAccent),
              title: const Text('Generar reporte', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implementar generación de reporte
              },
            ),
            const SizedBox(height: 40),

            // Botón: Cerrar sesión
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                  await Future.delayed(const Duration(milliseconds: 500));
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Cerrar sesión'),
              ),
            ),
            const SizedBox(height: 40),

            // Sección: Soporte
            const Text(
              'Soporte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: supportController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe tu problema o sugerencia aquí',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Botón: Enviar mensaje de soporte
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implementar funcionalidad para enviar mensaje (e.g., correo)
                  print('Support message: ${supportController.text}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mensaje enviado (simulado)')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Enviar mensaje'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
