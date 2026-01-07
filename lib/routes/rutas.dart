import 'package:flutter/material.dart';
import '../pages/home_page.dart';

// BLOQUE: Rutas centralizadas (aunque solo haya 1 pantalla)
const String initialRoute = '/';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => const HomePage(),
};
