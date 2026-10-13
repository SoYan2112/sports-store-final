import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDependencies();
  runApp(const SportsStoreApp());
}
