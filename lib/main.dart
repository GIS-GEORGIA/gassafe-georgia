import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/shell.dart';
import 'theme/app_theme.dart';

void main() => runApp(const GasSafeApp());

class GasSafeApp extends StatelessWidget {
  const GasSafeApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          title: 'GasSafe Georgia — DEMO',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          home: const Shell(),
        ),
      );
}
