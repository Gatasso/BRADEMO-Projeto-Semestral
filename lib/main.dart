import 'package:brademo_projeto_final/providers/suporte_provider.dart';
import 'package:brademo_projeto_final/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/equipment.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<Box<T>> _openBoxWithTimeoutAndRetry<T>(String name) async {
  try {
    return await Hive.openBox<T>(name).timeout(const Duration(seconds: 2));
  } catch (e) {
    try {
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openBox<T>(name).timeout(const Duration(seconds: 2));
    } catch (_) {
      rethrow;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização das dependências do app
  try {
    try {
      await dotenv.load(fileName: ".env");
    } catch (_) {}
    
    await Hive.initFlutter();

    // Registro de adaptadores
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(EquipmentAdapter());
    }

    // Abertura de caixas do Hive
    await Future.wait([
      _openBoxWithTimeoutAndRetry<Equipment>('equipments'),
      _openBoxWithTimeoutAndRetry('authBox'),
      _openBoxWithTimeoutAndRetry('profile_box'),
      _openBoxWithTimeoutAndRetry('solicitations'),
      _openBoxWithTimeoutAndRetry('tabelasSuporteBox'),
    ]);

    try {
      await NotificationService.init();
    } catch (_) {}
  } catch (e, stackTrace) {
    debugPrint("Erro na inicialização: $e");
    debugPrint(stackTrace.toString());
  }

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
      home: const SplashScreen(),
    );
  }
}
