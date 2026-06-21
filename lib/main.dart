import 'package:brademo_projeto_final/providers/suporte_provider.dart';
import 'package:brademo_projeto_final/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/equipment.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      "Aviso: Arquivo .env não encontrado, usando fallbacks configurados.",
    );
  }
  await Hive.initFlutter(); // [cite: 80]

  // Registra o adaptador existente de equipamentos
  Hive.registerAdapter(EquipmentAdapter());

  // Abre todas as caixas necessárias na inicialização do app [cite: 82]
  await Hive.openBox<Equipment>('equipments');
  await Hive.openBox('authBox');
  await Hive.openBox('profile_box');
  await Hive.openBox('solicitations');
  await Hive.openBox('tabelasSuporteBox');

  NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..carregarSessaoUsuario(),
        ),
        ChangeNotifierProvider(
          create: (_) => SuporteProvider()..inicializarTabelasSuporte(),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IF Equipamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1B5E20),
          onPrimary: Colors.white,
          secondary: Color(0xFF4CAF50),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          error: Colors.red,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F3F6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Color(0xFF1B5E20)),
          prefixIconColor: const Color(0xFF1B5E20),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1B5E20),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1B5E20),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
          ),
          labelMedium: TextStyle(color: Colors.grey),
          bodyMedium: TextStyle(color: Colors.grey),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
