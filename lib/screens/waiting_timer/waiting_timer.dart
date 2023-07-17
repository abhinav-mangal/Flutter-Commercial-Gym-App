import 'package:energym/src/import.dart';

import 'package:flutter/services.dart';

// This screen is timer screen to start workout for Group workout
class WaitingTimer extends StatefulWidget {
  const WaitingTimer({Key? key}) : super(key: key);

  @override
  State<WaitingTimer> createState() => _WaitingTimerState();
}

class _WaitingTimerState extends State<WaitingTimer> {
  AppConfig? config;
  final CountDownController _controller = CountDownController();

  @override
  void initState() {
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
              children: [
                topView(context),
                centerPart(
                  context,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 70),
                        child: SizedBox(
                          width: 200,
                          child: Text(
                            AppConstants.workoutStarting.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: config!.antonio40FontStyle,
                          ),
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 2,
                        child: SizedBox(
                          height: double.infinity,
                          child: CircularCountDownTimer(
                            duration: 5,

                            initialDuration: 0,

                            controller: _controller,

                            width: double.infinity,

                            height: double.infinity,

                            ringColor: config!.borderColor,

                            fillColor: config!.btnPrimaryColor,
                            fillGradient: LinearGradient(
                              colors: [
                                AppColors.green,
                                AppColors.lightBlackGreen,
                                AppColors.blackish
                              ],
                            ),

                            strokeWidth: 10.0,

                            strokeCap: StrokeCap.round,

                            textStyle: config!.antonioTimerFontStyle,

                            textFormat: CountdownTextFormat.S,

                            isReverse: true,

                            isReverseAnimation: true,

                            autoStart: true,

                            // This Callback will execute when the Countdown Ends.
                            onComplete: () {
                              // Navigate to  Live workout
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const LiveWorkout(),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
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
