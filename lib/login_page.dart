import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _usernameController.text.trim();
                final password = _passwordController.text.trim();

                if (email.isEmpty || password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email e Password sono obbligatorie')),
                  );
                  return;
                }

                try {
                  print('Tentativo di login con email: $email');

                  // Ottieni la risposta da Supabase
                  final response = await Supabase.instance.client.auth.signInWithPassword(
                    email: email,
                    password: password,
                  );

                  // Usando il null-aware operator ?. per accedere a response.user in modo sicuro
                  final userId = response.user?.id; // Se response.user è null, userId sarà null

                  if (userId != null) {
                    print('Utente loggato: $userId');
                    // Naviga alla HomePage
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    print('Login fallito: Nessun utente trovato');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login fallito: Credenziali non valide')),
                    );
                  }
                } on AuthException catch (e) {
                  // Gestisce errori specifici di autenticazione
                  print('Errore di autenticazione: ${e.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore durante il login: ${e.message}')),
                  );
                } catch (e) {
                  // Gestisce altri errori generici
                  print('Errore durante il login: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore durante il login: ${e.toString()}')),
                  );
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
