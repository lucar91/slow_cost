import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Inizializzazione Flutter completata');

  try {
    // Carica le variabili di ambiente
    await dotenv.load(fileName: '.env');
    print('Supabase URL: ${dotenv.env['SUPABASE_URL']}');
    print('Supabase Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']}');

    // Inizializza Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      debug: true, // Debug Supabase
    );
    print('Supabase inizializzato con successo');
  } catch (e) {
    print('Errore nell\'inizializzazione: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Costruzione dell\'app completata');
    return MaterialApp(
      title: 'Gestione Spese',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _decideInitialPage(), // Route dinamica iniziale
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }

  Widget _decideInitialPage() {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      print('Utente loggato: ${user.id}');
      return HomePage(); // Se c'è una sessione, vai a HomePage
    } else {
      print('Nessun utente loggato, vai al login');
      return LoginPage(); // Altrimenti, vai al Login
    }
  }
}
