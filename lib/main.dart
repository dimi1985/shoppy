import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/providers/dark_theme_provider.dart';
import 'package:shoppy/utils/styles.dart';
import 'screens/home_page.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:device_preview/device_preview.dart';

// void main() => runApp(DevicePreview(
//     enabled: true,
//     tools: const [...DevicePreview.defaultTools],
//     builder: (context) => const MyApp()));

//turn back to default withouut preview
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('el')],
      path: 'assets/lang',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
              themeChangeProvider.darkTheme,
              context,
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }
}
