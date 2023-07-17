import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';

// This screen will open after splash screen
// Contains 'connect' button from this screen user will navigate into app
// And after finish workout user will jump to this screen if bike is not connect
class Connect extends StatefulWidget {
  static const String routeName = '/Connect';

  const Connect({Key? key}) : super(key: key);
  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  AppConfig? config;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      moveToScreen();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    config = AppConfig.of(context);
    return CustomScaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SafeArea(
          child: Container(
            decoration: setBackGroundImage(context),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [topView(context), _connectButton()],
            ),
          ),
        ),
      ),
      floatingActionButton: widgetEnergymBottom(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Tap on connect button user will be redirected to BLE searching screen
  Widget _connectButton() {
    return centerPart(
      context,
      GestureDetector(
        onTap: null,
        child: Center(
          child: Container(
            width: 440,
            height: 109,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImgConstants.connect),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      bottomPadding: 70,
    );
  }

  // Navigate to searching BLE screen, if bike is not connected
  // Navigate to workout selection screen, if bike is connected
  void moveToScreen() {
    if (espDevice != null) {
      // Push to workout selection, if bike is already connected
      Navigator.pushReplacementNamed(context, WorkoutSelection.routeName);
    } else {
      // Push to scanning screen, if bike is not connected
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const ScanningBLE(),
        ),
      );
    }
  }
}
