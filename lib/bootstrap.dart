import 'package:energym/src/import.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class Bootstrap extends StatelessWidget {
  const Bootstrap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InternetConnection>(
          create: (_) => InternetConnection(),
        ),
        ChangeNotifierProvider<AppConfig>(
          create: (_) => _getConfig(appEnv),
        ),
      ],
      child: FutureBuilder<dynamic>(
        future: Future.wait([
          _getPackageInfo(),
          _getDeviceInfo(),
          _getSharedPreferences(),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final PackageInfo packageInfo = snapshot.data![0] as PackageInfo;
            final DeviceInfo deviceInfo = snapshot.data![1] as DeviceInfo;
            final SharedPreferences sharedPreferences =
                snapshot.data![2] as SharedPreferences;

            return MultiProvider(
              providers: [
                Provider.value(value: packageInfo),
                Provider.value(value: deviceInfo),
                Provider.value(value: sharedPreferences),
              ],
              child: const MyApp(),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Future<PackageInfo> _getPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }

  Future<DeviceInfo?> _getDeviceInfo() async {
    final DeviceInfo? deviceInfo = await DeviceInfo.create();
    return deviceInfo;
  }

  Future<SharedPreferences> _getSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences;
  }

  AppConfig _getConfig(Environment environment) {
    EnvironmentService environmentService = EnvironmentService(environment);

    return AppConfig(
      fireStoreDB: environmentService.getValue(
        dev: 'gym_dev',
        staging: 'gym_staging',
        prod: 'gym_production',
      ),
      brightness: Brightness.dark,
      defaultThemeData: AppThemeData(
        accentColor: const Color(0xff314b39),
        textAccentColor: const Color(0xff314b39),
        accentBrightness: Brightness.dark,
        primaryButtonColor: const Color(0xff314b39),
      ),
      lightThemeData: AppThemeData(
        accentColor: const Color(0xff314b39),
        textAccentColor: const Color(0xff314b39),
        accentBrightness: Brightness.light,
        primaryButtonColor: const Color(0xff314b39),
      ),
      darkThemeData: AppThemeData(
        accentColor: const Color(0xff314b39),
        textAccentColor: const Color(0xff314b39),
        accentBrightness: Brightness.dark,
        primaryButtonColor: const Color(0xff314b39),
      ),
    );
  }
}
