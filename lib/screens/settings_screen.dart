import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme_provider.dart'; // Importa ThemeProvider
import '../models/expense.dart'; // Por si luego se usa
import '../models/income.dart';  // Por si luego se usa
import '../services/auth_service.dart'; // Asegúrate de tener este archivo con AuthService


class SettingsScreen extends StatelessWidget {
  final String? userId;

  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final authService = Provider.of<AuthService>(context);
    final TextEditingController supportController = TextEditingController();
    String selectedCurrency = 'USD'; // Variable para la moneda seleccionada

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
                color: Colors.black,
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
                  const Icon(Icons.person, size: 30, color: Colors.black),
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
              leading: const Icon(Icons.monetization_on, color: Colors.black),
              title: const Text('Cambiar moneda', style: TextStyle(fontSize: 18, color: Colors.black)),
              trailing: DropdownButton<String>(
                value: selectedCurrency,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.black),
                underline: Container(
                  height: 2,
                  color: Colors.transparent,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // TODO: Implementar lógica para cambiar la moneda
                    selectedCurrency = newValue;
                  }
                },
                items: <String>['USD', 'EUR', 'COP']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const Divider(),

            // Opción: Modo oscuro
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.brightness_6, color: Colors.black),
                  title: const Text('Modo oscuro', style: TextStyle(fontSize: 18, color: Colors.black)),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            ),
            const Divider(),

            // Opción: Modo oscuro
            // Opción: Generar reporte
            ListTile(
              leading: const Icon(Icons.insert_chart, color: Colors.black),
              title: const Text('Generar reporte', style: TextStyle(fontSize: 18, color: Colors.black)),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.brightness_6, color: Colors.blueAccent),
                  title: const Text('Modo oscuro', style: TextStyle(fontSize: 18)),
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            ),
            const Divider(),

            // Opción: Generar reporte
            ListTile(
              leading: const Icon(Icons.insert_chart, color: Colors.blueAccent),
              title: const Text('Generar reporte', style: TextStyle(fontSize: 18)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'Julian.ordonez01@uceva.edu.co',
                  queryParameters: {
                    'subject': 'Reporte de Gastos/Ingresos',
                  },
                );
                launchUrl(emailLaunchUri);
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
                  backgroundColor: Colors.blueAccent, // Fondo azul
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), // Texto negro
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Cerrar sesión', style: TextStyle(color: Colors.black)), // Texto negro en el botón
              ),
            ),
            const SizedBox(height: 40),

            // Sección: Soporte
            const Text(
              'Soporte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 15),
            // Botón para soporte
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/support'); // Navegar a SupportScreen
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Ir a Soporte'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
