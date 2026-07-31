import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(ChangeNotifierProvider(create: (_) => AppState()..load(), child: const HalaqatiApp()));
}

class HalaqatiApp extends StatelessWidget {
  const HalaqatiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'حَلَقَتي',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    supportedLocales: const [Locale('ar')],
    theme: AppTheme.theme,
    home: const HomeScreen(),
  );
}
