import 'dart:async';

import 'package:energym/src/import.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// This screen for waiting for signal for group workout from other person
class GroupWaiting extends StatefulWidget {
  const GroupWaiting({Key? key}) : super(key: key);

  @override
  State<GroupWaiting> createState() => _GroupWaitingState();
}

class _GroupWaitingState extends State<GroupWaiting>
    with SingleTickerProviderStateMixin {
  AppConfig? config;
  late AnimationController _controller;
  StopWatchTimer _stopWatchTimer = StopWatchTimer();
  String msg = '';

  StreamSubscription<List<int>>? totalPowerListner;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _startAnimation();
    _stopWatchTimer = StopWatchTimer(
      onChangeRawSecond: (sec) {
        setState(() {
          if (sec % 10 == 0) {
            msg = AppConstants.searchingForRiders;
          } else if (sec % 10 == 4) {
            msg = AppConstants.sizing;
          } else if (sec % 10 == 8) {
            msg = AppConstants.planning;
          }
        });
      },
    );

    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    aGeneralBloc.blocBluetooth.startWorkoutData();
    totalPowerStream();
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    _controller.stop();
    super.dispose();
  }

  totalPowerStream() {
    totalPowerListner?.cancel();
    totalPowerListner = aGeneralBloc
        .blocBluetooth.bleTotalPowerCharacteristic?.value
        .listen((newEvent) {
      List<int>? dt = newEvent;
      if (dt.isNotEmpty) {
        if (dt.last == 10) {
          // 10 = session running,
          // Navigate to live workout
          navigateToLiveWorkout();
        }
      }
    });
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
                  _searchingUIWithText(),
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

  Widget _animation() {
    return CustomPaint(
      painter: SpritePainter(_controller),
      child: const SizedBox(
        width: double.infinity,
      ),
    );
  }

  Widget _searchingUIWithText() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _animation(),
        Text(msg, style: config?.abel24FontStyle),
      ],
    );
  }

  // Start searching animation
  void _startAnimation() {
    _controller
      ..stop()
      ..reset()
      ..repeat(period: const Duration(seconds: 1));
  }

  // Navigate to waiting timer screen to wait about few sec. to start workout
  navigateToLiveWorkout() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Navigate to  Waiting screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const WaitingTimer(),
        ),
      );
    });
  }
}
