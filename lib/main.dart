import 'dart:async';

import 'package:energym/bootstrap.dart';
import 'package:energym/src/import.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info/package_info.dart';

class Helper {
  static final RouteObserver<ModalRoute> routeObserver =
      RouteObserver<ModalRoute>();
}

GetIt? serviceLocator = GetIt.instance; //Singleton helper //Register
Environment appEnv = Environment.dev;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PackageInfo.fromPlatform();
  await EasyLocalization.ensureInitialized(); // Localization
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown]);

  Firebase.initializeApp().whenComplete(() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    runApp(
      EasyLocalization(
        supportedLocales: const <Locale>[
          Locale('en'),
        ],
        useOnlyLangCode: true,
        path: SizeConfig.localizationPath,
        child: const Bootstrap(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    //setLocalNotification();
    aGeneralBloc.resetTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        aGeneralBloc.resetTimer();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: EasyLocalization.of(context)!.supportedLocales,
        locale: EasyLocalization.of(context)!.locale,
        theme: darkTheme,
        initialRoute: Routers.initialRoute,
        onGenerateRoute: Routers.onGenerateRoute,
        navigatorObservers: [Helper.routeObserver],
        localizationsDelegates: [
          EasyLocalization.of(context)!.delegate,
        ],
        navigatorKey: kNavigatorKey,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: child ?? const SizedBox(),
          );
        },
      ),
    );
  }
}
