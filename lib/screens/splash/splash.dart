import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Splash screen when app start and init then first time always this screen will be opened
class Splash extends StatefulWidget {
  static const String routeName = '/Splash';

  const Splash({Key? key}) : super(key: key);
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  AppConfig? config;
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    packageInfo = info;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppKeyConstant.version, packageInfo.version);
    await prefs.setString(AppKeyConstant.buildNumber, packageInfo.buildNumber);
  }

  @override
  void initState() {
    super.initState();
    initPackageInfo();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        moveToScreen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    config = AppConfig.of(context);
    return CustomScaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            decoration: _setBackGroundImage(),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(
                  ImgConstants.energymSelectionLogo,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 10,
                  child: widgetEnergymBottom(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _setBackGroundImage() {
    return const BoxDecoration(
      image: DecorationImage(
        image: AssetImage(ImgConstants.background),
        fit: BoxFit.fill,
      ),
    );
  }

  void moveToScreen() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Connect.routeName,
      ModalRoute.withName('/'),
    );
  }
}
