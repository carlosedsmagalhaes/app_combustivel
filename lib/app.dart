import 'package:flutter/material.dart';

import 'package:app_combustivel/features/combustivel/presentation/screens/tela_principal.dart';

class AppCombustivel extends StatelessWidget {
  const AppCombustivel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Combustível',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(),
    );
  }
}
