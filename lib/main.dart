import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/theme_service.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);  // AGREGAR ESTA LÍNEA
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();

  // Método estático para cambiar tema desde cualquier parte
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  bool _esOscuro = false;

  @override
  void initState() {
    super.initState();
    _cargarTema();
  }

  // Cargar tema guardado
  void _cargarTema() async {
    bool temaOscuro = await ThemeService.obtenerTema();
    setState(() {
      _esOscuro = temaOscuro;
    });
  }

  // Cambiar tema
  void cambiarTema() async {
    setState(() {
      _esOscuro = !_esOscuro;
    });
    await ThemeService.guardarTema(_esOscuro);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COMIL6 - Sistema de Soporte',
      theme: ThemeService.temaClaro,
      darkTheme: ThemeService.temaOscuro,
      themeMode: _esOscuro ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,

    );
  }
}