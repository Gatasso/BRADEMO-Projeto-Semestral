// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brademo_projeto_final/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());
    
    // Aguardar a UI estabilizar
    await tester.pumpAndSettle();

    // Verificar se a tela de login foi carregada
    expect(find.byType(MainApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verificar elementos da tela de login
    // (Ajuste conforme os widgets da sua LoginScreen)
    expect(find.text('IF Equipamentos'), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeast(1));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}