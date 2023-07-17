import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

// This screen to choose exercise
// And flow will be move accordingly based on exercise choose
class WorkoutSelection extends StatefulWidget {
  static const String routeName = '/WorkoutSelection';

  const WorkoutSelection({Key? key}) : super(key: key);

  @override
  State<WorkoutSelection> createState() => _WorkoutSelectionState();
}

class _WorkoutSelectionState extends State<WorkoutSelection> {
  AppConfig? config;
  final ValueNotifier<bool> _isInstantWorkoutSelected =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _ingroupChallengeSelected =
      ValueNotifier<bool>(false);

  @override
  void dispose() {
    super.dispose();
    _isInstantWorkoutSelected.dispose();
    _ingroupChallengeSelected.dispose();
  }

  @override
  Widget build(BuildContext context) {
    config = AppConfig.of(context);
    return WillPopScope(
      onWillPop: () async => false,
      child: CustomScaffold(
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _instantWorkout(true),
                                _groupChallenge(true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Positioned(
                  //   right: 20,
                  //   bottom: 60,
                  //   child: _restartButton(),
                  // )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: widgetEnergymBottom(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _instantWorkout(bool? aStatus) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isInstantWorkoutSelected,
      builder: (BuildContext? context, isTrue, child) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Container(
                height: 109,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isTrue
                      ? LinearGradient(
                          colors: [
                            config!.btnPrimaryColor,
                            AppColors.greenBlack
                          ],
                        )
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: isTrue
                      ? null
                      : GradientBoxBorder(
                          gradient: LinearGradient(
                            colors: [
                              config!.btnPrimaryColor,
                              AppColors.greenBlack
                            ],
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                          ),
                          width: 4,
                        ),
                ),
                child: TextButton(
                  onPressed: () {
                    _isInstantWorkoutSelected.value = true;
                    _ingroupChallengeSelected.value = false;
                    navigate(ExerciseType.instantWorkout);
                  },
                  child: isTrue
                      ? Text(
                          AppConstants.instantWorkout.toUpperCase(),
                          style: config!.antonio40FontStyle
                              .copyWith(color: Colors.black),
                        )
                      : GradientText(
                          AppConstants.instantWorkout.toUpperCase(),
                          colors: [
                            config!.btnPrimaryColor,
                            AppColors.greenBlack
                          ],
                          gradientDirection: GradientDirection.ttb,
                          style: config!.antonio40FontStyle,
                        ),
                ),
              ),
            ),
            isTrue
                ? Positioned(
                    left: -15,
                    top: 0,
                    bottom: 0,
                    child: Image.asset(
                      ImgConstants.energymSelectionLogo,
                      fit: BoxFit.fill,
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }

  Widget _groupChallenge(bool? aStatus) {
    return ValueListenableBuilder<bool>(
      valueListenable: _ingroupChallengeSelected,
      builder: (BuildContext? context, isTrue, child) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Container(
                height: 109,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: isTrue
                      ? LinearGradient(
                          colors: [
                            config!.btnPrimaryColor,
                            AppColors.greenBlack
                          ],
                        )
                      : null,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  border: isTrue
                      ? null
                      : const GradientBoxBorder(
                          gradient: LinearGradient(
                            colors: [
                              // config!.btnPrimaryColor,
                              // AppColors.greenBlack
                              Color(0xFF40464E),
                              Color(0xFF40464E),
                            ],
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                          ),
                          width: 4,
                        ),
                ),
                child: TextButton(
                  onPressed: null,
                  // onPressed: !aStatus!
                  //     ? () {
                  //         _isInstantWorkoutSelected.value = false;
                  //         _ingroupChallengeSelected.value = true;
                  //         aGeneralBloc.updateAPICalling(true);
                  //         updateFirebaseSelection(
                  //           ExerciseType.groupChallenge,
                  //         );
                  //       }
                  //     : null,
                  child: isTrue
                      ? Text(
                          AppConstants.groupChallenge.toUpperCase(),
                          style: config!.antonio40FontStyle
                              .copyWith(color: Colors.black),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GradientText(
                              AppConstants.groupChallenge.toUpperCase(),
                              colors: const [
                                // config!.btnPrimaryColor,
                                // AppColors.greenBlack
                                Color(0xFFD8D8D8),
                                Color(0xFF40464E),
                              ],
                              gradientDirection: GradientDirection.ttb,
                              style: config!.antonio40FontStyle,
                            ),
                            Text(
                              '(COMING SOON)'.toUpperCase(),
                              style: config!.antonio14FontStyle
                                  .copyWith(color: Colors.white),
                            )
                          ],
                        ),
                ),
              ),
            ),
            isTrue
                ? Positioned(
                    left: -15,
                    top: 0,
                    bottom: 0,
                    child: Image.asset(
                      ImgConstants.energymSelectionLogo,
                      fit: BoxFit.cover,
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }

  navigate(ExerciseType type) async {
    aGeneralBloc.exerciseType = type;
    if (type == ExerciseType.groupChallenge) {
      // Navigate to FTP selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => FTPSelection(type: type),
        ),
      );
    } else if (type == ExerciseType.instantWorkout) {
      // Navigate to FTP selection
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => FTPSelection(type: type),
        ),
      );
    }
  }
}
