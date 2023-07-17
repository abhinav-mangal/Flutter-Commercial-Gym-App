import 'package:energym/bloc/firebase_bloc.dart';
import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

// This is static screen to intimate BLE device pairing is completed
class PairComplete extends StatefulWidget {
  const PairComplete({Key? key}) : super(key: key);

  @override
  State<PairComplete> createState() => _PairCompleteState();
}

class _PairCompleteState extends State<PairComplete> {
  AppConfig? config;
  FirebaseBloc firebaseBloc = FirebaseBloc();

  @override
  void initState() {
    super.initState();
    firebaseBloc.eventLogs('pairing_complete', {});
    Future.delayed(
      const Duration(seconds: 2),
      () {
        Navigator.pushReplacementNamed(context, WorkoutSelection.routeName);
      },
    );
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
              children: [
                topView(context),
                centerPart(
                  context,
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientText(
                          AppConstants.pairingComplete.toUpperCase(),
                          colors: [
                            config!.btnPrimaryColor,
                            AppColors.greenBlack
                          ],
                          gradientDirection: GradientDirection.ttb,
                          style: config!.antonio40FontStyle,
                        ),
                        const SizedBox(
                          height: 32,
                        ),
                        Text(
                          AppConstants.readyToRide,
                          style: config!.abel24FontStyle,
                        ),
                      ],
                    ),
                  ),
                  bottomPadding: 70,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: widgetEnergymBottom(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
