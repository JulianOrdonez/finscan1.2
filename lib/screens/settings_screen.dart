import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/expense.dart'; // Assuming you might need expense data here
import '../models/income.dart'; // Assuming you might need income data here

class SettingsScreen extends StatelessWidget {
  final String? userId;

  const SettingsScreen({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (userId != null) ...[
                Text(
                  'User ID: ${userId!}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                // You can add more user-specific information here
                // For example, fetching user data from Firestore
                // StreamBuilder<UserModel>(
                //   stream: firestoreService.getUser(userId!),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator();
                //     }
                //     if (snapshot.hasData && snapshot.data != null) {
                //       final user = snapshot.data!;
                //       return Text('Email: ${user.email}');
                //     }
                //     return SizedBox.shrink(); // Or an error message
                //   },
                // ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                  // Navigate to the login screen and remove all previous routes
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (Route<dynamic> route) => false);
                },
                child: const Text('Logout'),
              ),
              // Add other settings options here
            ],
          ),
        ),
      ),
    );
  }
}