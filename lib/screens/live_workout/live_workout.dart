import 'dart:async';

import 'package:energym/bloc/firebase_bloc.dart';
import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// This screen is live workout means when user start workout then all data will
// be display in this screen like Resistance, RPM, Total Power, Current Power
class LiveWorkout extends StatefulWidget {
  final int? ftpValue;
  const LiveWorkout({Key? key, this.ftpValue}) : super(key: key);

  @override
  State<LiveWorkout> createState() => _LiveWorkoutState();
}

class _LiveWorkoutState extends State<LiveWorkout>
    with TickerProviderStateMixin {
  AppConfig? config;
  StopWatchTimer _stopWatchTimer = StopWatchTimer();
  double spentMin = 0;
  late TabController _tabController;
  String time = '00:00:00';
  int intCadence = 0;
  int intResistance = 0;
  int intWatts = 0;
  List<LinearWorkout> arrWatts = [];
  int intAvgWatts = 0;
  int _currentZone = 1;
  List<int> power = [];
  int averageCurrentPower = 0;
  var highestGeneratedPower = 0;
  Timer? _idleTimeoutTimer;

  DateTime? startTimeLog;

  double percentageToBeFilled = 0.0;

  Timer? liveIndicatorTimer;

  StreamSubscription<List<int>>? liveEventListener;
  StreamSubscription<List<int>>? totalPowerListner;

  double rangeMin = 0;
  double rangeMax = 0;

  final BehaviorSubject<double> _streamCharValue = BehaviorSubject<double>();

  ValueStream<double> get streamCharValue => _streamCharValue.stream;
  final BehaviorSubject _streamCharValuePower = BehaviorSubject();
  ValueStream get streamCharValuePower => _streamCharValuePower.stream;
  int intSecond = -1;
  int totalPower = 0;
  FirebaseBloc firebaseBloc = FirebaseBloc();
  final BehaviorSubject<String> _workoutTime = BehaviorSubject<String>();
  ValueStream<String> get getWorkoutTime => _workoutTime.stream;

  @override
  void initState() {
    firebaseBloc.eventLogs('live_workout_started', {});
    _tabController = TabController(length: 1, vsync: this);
    _tabController.animateTo(0);
    super.initState();
    aGeneralBloc.inLiveWorkout = true;
    startTimeLog = DateTime.now();
    _init();
  }

  // This is user defined private function to init data
  _init() async {
    _stopWatchTimer = StopWatchTimer(
      onChange: (int value) {
        final String displayTime = StopWatchTimer.getDisplayTime(
          value,
        );

        updateWorkoutTimer(displayTime);
      },
    );

    // Discover characteristics of connected device
    // _blocBluetooth.writeDataCharacteristics();
    await aGeneralBloc.blocBluetooth.startWorkoutData();
    await aGeneralBloc.blocBluetooth.startLiveIndicator();

    Future.delayed(const Duration(seconds: 0), () {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });

    liveWorkOutStream();
    totalPowerStream();
  }

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    _stopWatchTimer.dispose();
    streamCharValuePower.drain();
    streamCharValue.drain();
    firebaseBloc.eventLogs('live_workout_ended', {});
    aGeneralBloc.inLiveWorkout = false;
    _idleTimeoutTimer?.cancel();
    liveIndicatorTimer?.cancel();
    liveEventListener?.cancel();
    totalPowerListner?.cancel();
    totalPowerListner = null;
    liveIndicatorTimer = null;
    liveEventListener = null;
    getWorkoutTime.drain();
    _workoutTime.close();
    aGeneralBloc.blocBluetooth.stopLiveIndicator();
  }

  void updateWorkoutTimer(String timer) {
    _workoutTime.sink.add(timer);
  }

  liveWorkOutStream() {
    liveEventListener?.cancel();
    aGeneralBloc.blocBluetooth.ftmsDataStream.drain();
    liveEventListener =
        aGeneralBloc.blocBluetooth.ftmsDataStream.listen((newEvent) {
      if (newEvent.isNotEmpty) {
        List<int> arrExerciseData =
            aGeneralBloc.blocBluetooth.dataParserAndCalculation(newEvent);

        // 0 index for cadence
        // 1 index for resistance
        // 2 index for watts / power
        // 3 index for avg. watts / power
        // 4 index for calories

        intCadence = arrExerciseData[0];
        intResistance = arrExerciseData[1];
        // intWatts = arrExerciseData[2];
        intWatts = calculateWatts(arrExerciseData[2]);
        intAvgWatts = arrExerciseData[3];
        intSecond = intSecond + 1;
        arrWatts.add(LinearWorkout(intSecond, arrExerciseData[2]));
        if (intWatts > highestGeneratedPower) {
          highestGeneratedPower = intWatts;
        }
        arrExerciseData =
            aGeneralBloc.blocBluetooth.dataParserAndCalculation(newEvent);
        setupZones();
        checkIdleTimeoutTimer();
      }
    });
  }

  /// For first case, if idleTimeoutTimer is not set, we set it else we reset every time we get a value
  checkIdleTimeoutTimer() {
    if (intWatts == 0) {
      _idleTimeoutTimer ??= Timer(const Duration(minutes: 10), () {
        endWorkout();
      });
    } else {
      // Reset timer on getting a value
      _idleTimeoutTimer?.cancel();
      _idleTimeoutTimer = Timer(const Duration(minutes: 10), () {
        endWorkout();
      });
    }
  }

  totalPowerStream() {
    try {
      totalPowerListner?.cancel();
      totalPowerListner = aGeneralBloc
          .blocBluetooth.bleTotalPowerCharacteristic?.value
          .listen((newEvent) {
        List<int>? dt = newEvent;
        if (dt.isNotEmpty) {
          if (dt.last == 14 || dt.last == 2) {
            // 10 = session running,
            // Navigate to live workout
            endWorkout();
          }
        }
        totalPower = aGeneralBloc.blocBluetooth
            .dataParserAndCalculationFromWriteCha(newEvent);
      });
    } on Exception catch (e) {
      firebaseBloc.eventLogs('total_power_error_live_workout', {'error': e.toString()});
    }
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
                  topView(context, isLeftLogoVisible: true),
                  centerPart(
                    context,
                    Column(
                      children: [
                        TabBar(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          unselectedLabelColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          tabs: const [
                            Tab(
                              text: '',
                            ),
                            // Tab(
                            //   text: '',
                            // ),
                          ],
                          isScrollable: true,
                        ),
                        Expanded(
                          child: TabBarView(
                            // physics: NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 100,
                                  bottom: 15,
                                ),
                                child: _liveWorkoutDataUI(),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //     bottom: 50,
                              //   ),
                              //   child: Container(
                              //     child: _setResistance(),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    topPadding: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _liveWorkoutDataUI() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            StreamBuilder(
                              stream: streamCharValue,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: Row(
                                      children: [
                                        // RPM
                                        Expanded(child: _rpm()),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        // Resistance
                                        Expanded(child: _resistance()),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  // Current Power
                                  StreamBuilder(
                                      stream: streamCharValuePower,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Expanded(
                                              child:
                                                  _currentPower(snapshot.data));
                                        } else {
                                          return Expanded(
                                              child: _currentPower(0));
                                        }
                                      }),

                                  const SizedBox(width: 4),

                                  // Total power
                                  StreamBuilder(
                                    stream: streamCharValue,
                                    builder: (context, snapshot) {
                                      return Expanded(
                                          child: _totalPower(totalPower));
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _centerZone()
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50),
                child: SizedBox(
                  height: 150,
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _widgetTimer(),
                        if (aGeneralBloc.exerciseType ==
                            ExerciseType.instantWorkout)
                          _endWorkout()
                        else
                          const SizedBox()
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 140),
          height: double.infinity,
          child: const Center(
            child: SizedBox(width: 50),
          ),
        )
      ],
    );
  }

  Widget _totalPower(int totalPower) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: _setColorsGradient(_currentZone),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$totalPower',
            style: textStyle64(_currentZone),
          ),
          Text(
            AppConstants.totalPower.toUpperCase(),
            style: textStyle22(_currentZone),
          ),
        ],
      ),
    );
  }

  Widget _rpm() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _setColorsGradient(_currentZone),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$intCadence',
            style: textStyle64(_currentZone),
          ),
          Text(
            AppConstants.rpm.toUpperCase(),
            style: textStyle22(_currentZone),
          ),
        ],
      ),
    );
  }

  Widget _resistance() {
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(1);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: _setColorsGradient(_currentZone),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$intResistance',
              style: textStyle64(_currentZone),
            ),
            Text(
              AppConstants.resistances.toUpperCase(),
              style: textStyle22(_currentZone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentPower(data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: _setColorsGradient(_currentZone),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$data',
            style: textStyle64(_currentZone),
          ),
          Text(
            AppConstants.currentPower.toUpperCase(),
            style: textStyle22(_currentZone),
          ),
        ],
      ),
    );
  }

  Widget _centerZone() {
    return StreamBuilder<double>(
      stream: streamCharValue,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        if (snapshot.data != null && snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.width / 3,
            width: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
              border: GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [config!.btnPrimaryColor, AppColors.blackish],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                ),
                width: 1,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width / 1.5),
              ),
              color: Colors.black,
            ),
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  showLabels: false,
                  showTicks: false,
                  startAngle: 270,
                  endAngle: 270,
                  maximum: rangeMax,
                  minimum: rangeMin,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.10,
                    color: Colors.transparent,
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: averageCurrentPower.toDouble(),
                      width: 0.10,
                      sizeUnit: GaugeSizeUnit.factor,
                      cornerStyle: CornerStyle.bothCurve,
                      enableAnimation: true,
                      animationDuration: 500,
                      gradient: SweepGradient(
                        colors: _setColorsGradient(_currentZone),
                        stops: const [0, 0.7, 1],
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      angle: 90,
                      widget: SizedBox(
                        height: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ZONE $_currentZone',
                              style: config!.antonioHeading1FontStyle,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  /// This Block is commented because Resistance Function in not used for now, but can be used in future.

/*
  Widget _centerResistance(BuildContext mainContext) {
    return ValueListenableBuilder<int>(
      valueListenable: _notifierValueChange!,
      builder: (BuildContext? context, int? value, Widget? child) {
        return Container(
          height: MediaQuery.of(mainContext).size.width / 3,
          width: MediaQuery.of(mainContext).size.width / 3,
          decoration: BoxDecoration(
            border: GradientBoxBorder(
              gradient: LinearGradient(
                colors: [config!.btnPrimaryColor, AppColors.blackish],
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
              ),
              width: 1,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(MediaQuery.of(mainContext).size.width / 1.5),
            ),
            color: Colors.black,
          ),
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                showLabels: false,
                showTicks: false,
                startAngle: 270,
                endAngle: 270,
                maximum: 10,
                axisLineStyle: const AxisLineStyle(
                  thickness: 0.10,
                  color: Colors.transparent,
                  thicknessUnit: GaugeSizeUnit.factor,
                ),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: (value ?? 0).toDouble(),
                    width: 0.10,
                    sizeUnit: GaugeSizeUnit.factor,
                    cornerStyle: CornerStyle.bothCurve,
                    enableAnimation: true,
                    gradient: SweepGradient(
                      colors:
                          _setColorsGradient(_currentZone).reversed.toList(),
                      // stops: [0, 0.7, 1],
                    ),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    angle: 90,
                    widget: SizedBox(
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$value',
                            style: config!.antonioHeading1FontStyle,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _setResistance() {
    return Row(
      children: [
        Container(
          width: 100,
          child: Icon(
            Icons.arrow_back_ios,
            size: 50,
            color: AppColors.green,
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(),
                      _btnResistanceUp(),
                      _centerResistance(context),
                      _btnResistanceDown(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 100),
                child: SizedBox(
                  height: 100,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _widgetTimer(),
                      ],
                    ),
                    color: Colors.transparent,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _btnResistanceUp() {
    return Container(
      height: 73,
      width: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          colors: _setColorsGradient(_currentZone),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: TextButton(
        onPressed: () async {
          int aValue = 0;
          if (_notifierValueChange!.value < 10) {
            _notifierValueChange!.value++;
            aValue++;
          } else {
            aValue = 10;
          }
          // Write Resistance in ESP
          _blocBluetooth.writeData(context, aValue);
        },
        child: Text(
          AppConstants.resistanceUp.toUpperCase(),
          style: textStyle34(_currentZone),
        ),
      ),
    );
  }

  Widget _btnResistanceDown() {
    return Container(
      height: 73,
      width: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        gradient: LinearGradient(
          colors: _setColorsGradient(_currentZone),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: TextButton(
        onPressed: () async {
          int aValue = 0;
          if (_notifierValueChange!.value > 0) {
            _notifierValueChange!.value--;
            aValue--;
          } else {
            aValue = 0;
          }
          // Write Resistance in ESP
          _blocBluetooth.writeData(context, aValue);
        },
        child: Text(
          AppConstants.resistanceDown.toUpperCase(),
          style: textStyle34(_currentZone),
        ),
      ),
    );
  }

  Widget _bottomResistanceValue() {
    return ValueListenableBuilder<int>(
      valueListenable: _notifierValueChange!,
      builder: (BuildContext? context, int? value, Widget? child) {
        return Text.rich(
          TextSpan(
            text: '$value',
            style: config?.antonioHeading1FontStyle.copyWith(fontSize: 64),
            children: <InlineSpan>[
              TextSpan(
                text: '   ',
                style: config?.antonio36FontStyle,
              ),
              TextSpan(
                text: AppConstants.resistances.toUpperCase(),
                style: config?.antonio36FontStyle,
              )
            ],
          ),
        );
      },
    );
  }
  */

  Widget _widgetTimer() {
    return StreamBuilder<String>(
      stream: getWorkoutTime,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          time = snapshot.data!;
        }
        return Text(
          time,
          style: config?.antonioHeading1FontStyle
              .apply(color: config?.btnPrimaryColor),
          textAlign: TextAlign.right,
        );
      },
    );
  }

  Widget _endWorkout() {
    return Container(
      height: 60,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [config!.btnPrimaryColor, AppColors.greenBlack],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
          ),
          width: 4,
        ),
      ),
      child: TextButton(
        onPressed: () {
          endWorkout();
        },
        child: GradientText(
          AppConstants.endWorkout.toUpperCase(),
          colors: [config!.btnPrimaryColor, AppColors.greenBlack],
          gradientDirection: GradientDirection.ttb,
          style: config!.antonio40FontStyle.copyWith(fontSize: 20),
        ),
      ),
    );
  }

  // Set gradient color based on zone value
  List<Color> _setColorsGradient(int zone) {
    if (zone == 1) {
      // White
      return [Colors.white, AppColors.whiteBLack, AppColors.blackish];
    } else if (zone == 2) {
      // Blue
      return [AppColors.lightBlue, AppColors.lightDarkBlue, AppColors.blackish];
    } else if (zone == 3) {
      // Green
      return [AppColors.green, AppColors.lightBlackGreen, AppColors.blackish];
    } else if (zone == 4) {
      // Yellow
      return [AppColors.yellow, AppColors.lightBlackYellow, AppColors.blackish];
    } else if (zone == 5) {
      // Red
      return [AppColors.red, AppColors.darkred, AppColors.blackish];
    }

    return [Colors.white, AppColors.whiteBLack, AppColors.blackish];
  }

  // This is common style
  TextStyle textStyle64(int zone) {
    return config!.antonioHeading1FontStyle.copyWith(
      fontSize: 64,
      color: (zone == 1 || zone == 3) ? Colors.black : Colors.white,
    );
  }

  // This is common style
  TextStyle textStyle22(int zone) {
    return config!.abel24FontStyle.copyWith(
      fontSize: 22,
      color: (zone == 1 || zone == 3) ? Colors.black : Colors.white70,
    );
  }

  // This is common style
  TextStyle textStyle34(int zone) {
    return config!.antonio36FontStyle.copyWith(
      color: (zone == 1 || zone == 3) ? Colors.black : Colors.white,
    );
  }

  // Set up zone logic which is provided by Natasha
  setupZones() {
    // FTP
    averageCurrentPower = calculateAverage();
    final int ftp = aGeneralBloc.ftpValue!;

    // < or equal to 55%
    //≤  56-75%
    //≤ 76-90%
    //≤ 91-105%
    //106-150% +
    const double range1Min = 0;
    final double range1Max = ftp * 0.55;
    final double range2Max = ftp * 0.75;
    final double range3Max = ftp * 0.90;
    final double range4Max = ftp * 1.05;
    final double range5Max = ftp * 1.50;

    rangeMin = range1Min;
    rangeMax = range1Max;

    if (checkValueInRange(range1Min, range1Max, averageCurrentPower)) {
      rangeMax = range1Max;
      rangeMin = range1Min;
      _currentZone = 1;
    } else if (checkValueInRange(range1Max, range2Max, averageCurrentPower)) {
      rangeMax = range2Max;
      rangeMin = range1Max;
      _currentZone = 2;
    } else if (checkValueInRange(range2Max, range3Max, averageCurrentPower)) {
      rangeMax = range3Max;
      rangeMin = range2Max;
      _currentZone = 3;
    } else if (checkValueInRange(range3Max, range4Max, averageCurrentPower)) {
      rangeMax = range4Max;
      rangeMin = range3Max;
      _currentZone = 4;
    } else if (checkValueInRange(range4Max, 999999, averageCurrentPower)) {
      // Passing high value in max, so it falls in zone 5 if value more than zone 4
      rangeMax = range5Max;
      rangeMin = range4Max;
      _currentZone = 5;
    }
    percentageToBeFilled =
        ((averageCurrentPower - rangeMin) / (rangeMax - rangeMin)) * 100;
    _streamCharValue.sink.add(averageCurrentPower.toDouble());
    _streamCharValuePower.sink.add(averageCurrentPower);
  }

  /// checking if the given value is in range or not
  bool checkValueInRange(min, max, value) {
    if (value >= min && value < max) {
      return true;
    }
    return false;
  }

  /// calculating watts according to the fixed resistance
  calculateWatts(int currentEspWatts) {
    if (intCadence == 0) return 0;
    double watts;
    switch (intResistance) {
      case 0:
        watts = (0.71887 * intCadence) + 30.92863;
        break;
      case 5:
        watts = (1.84693 * intCadence) - 30.6834;
        break;
      case 10:
        watts = (1.87355 * intCadence) - 30.6834;
        break;
      case 15:
        watts = (3.52972 * intCadence) - 101.55274;
        break;
      case 20:
        watts = (4.43355 * intCadence) - 149.63029;
        break;
      case 25:
        watts = (4.25303 * intCadence) - 115.1706;
        break;
      case 30:
        watts = (5.20005 * intCadence) - 187.74469;
        break;
      case 35:
        watts = (5.31136 * intCadence) - 178.73128;
        break;
      case 40:
        watts = (4.51027 * intCadence) - 79.17981;
        break;
      case 45:
        watts = (4.09253 * intCadence) - 54.68275;
        break;
      case 50:
        watts = (6.76045 * intCadence) - 211.61919;
        break;
      default:
        //this for testing, so we can assign esp watts when resistance does not fall in any above case
        watts = currentEspWatts.toDouble();
    }
    if (watts < 0) return 0;
    return watts.toInt();
  }

  calculateAverage() {
    if (power.length >= 6) {
      power.removeAt(0);
    }
    power.add(intWatts);
    if (power.isNotEmpty) {
      int sum = 0;
      for (int value in power) {
        sum += value;
      }
      averageCurrentPower = sum ~/ power.length;
    }
    return averageCurrentPower;
  }

  /// EndWorkout and Navigate to workout summary screen
  endWorkout() async {
    // Writing Stop session
    await aGeneralBloc.blocBluetooth.writeStopSession();
    // await aGeneralBloc.blocBluetooth.stopWorkoutData();
    navigateToWorkoutSummary();
  }

  /// Navigate to finish workout
  navigateToWorkoutSummary() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => WorkoutComplete(
          totalPower: totalPower,
          highestPower: highestGeneratedPower,
          intWatts: intWatts,
          data: arrWatts,
          time: time,
        ),
      ),
    );
  }
}
