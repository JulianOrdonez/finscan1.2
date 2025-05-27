import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart'; // Assuming you might need expense data here
import '../models/income.dart'; // Assuming you might need income data here

class SettingsScreen extends StatelessWidget {
  final String? userId;

  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);
    final TextEditingController supportController = TextEditingController();

    return Scaffold(
 body: SingleChildScrollView(
 child: Padding(
 padding: const EdgeInsets.all(20.0),
 child: Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: <Widget>[
 const SizedBox(height: 40), // Espacio superior
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
 offset: Offset(0, 3),
 ),
 ],
 ),
 child: Row(
 children: [
 Icon(Icons.person, size: 30, color: Colors.blueAccent),
 SizedBox(width: 15),
 Expanded(
 child: Text(
 currentUser?.email ?? 'Usuario no disponible',
 style: TextStyle(fontSize: 18),
 overflow: TextOverflow.ellipsis,
 ),
 ),
 ],
 ),
 ),
 const SizedBox(height: 30),
 ListTile(
 leading: Icon(Icons.monetization_on, color: Colors.blueAccent),
 title: Text('Cambiar moneda', style: TextStyle(fontSize: 18)),
 trailing: Icon(Icons.arrow_forward_ios),
 onTap: () {
                  // TODO: Implement currency change functionality
 },
 ),
 Divider(),
 ListTile(
 leading: Icon(Icons.brightness_6, color: Colors.blueAccent),
 title: Text('Modo oscuro', style: TextStyle(fontSize: 18)),
 trailing: Icon(Icons.arrow_forward_ios),
 onTap: () {
                  // TODO: Implement dark mode toggle
 },
 ),
 Divider(),
 ListTile(
 leading: Icon(Icons.insert_chart, color: Colors.blueAccent),
 title: Text('Generar reporte', style: TextStyle(fontSize: 18)),
 trailing: Icon(Icons.arrow_forward_ios),
 onTap: () {
                  // TODO: Implement report generation
 },
 ),
 const SizedBox(height: 40),
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
 backgroundColor: Colors.redAccent, // Color del botón de cerrar sesión
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
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
 child: ElevatedButton(
 onPressed: () {
                  // TODO: Implement sending email functionality
                  // You can use a package like 'url_launcher' to open the mail app
                  // with the recipient and subject pre-filled.
 print('Support message: ${supportController.text}');
 },
 style: ElevatedButton.styleFrom(
 backgroundColor: Colors.green, // Color del botón de enviar
 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
 textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
 shape: RoundedRectangleBorder(
 borderRadius: BorderRadius.circular(30.0),
 ),
 ),
 child: const Text('Enviar mensaje'),
 ),
            ],
          ),
        ),
      ),
    );
  }
}