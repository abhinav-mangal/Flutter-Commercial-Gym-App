import 'package:energym/src/import.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import '../../bloc/firebase_bloc.dart';
import '../../model/workout_session_model.dart';

// This is workout summary screen
class WorkoutComplete extends StatefulWidget {
  const WorkoutComplete({
    Key? key,
    required this.intWatts,
    required this.data,
    required this.time,
    required this.totalPower,
    required this.highestPower,
  }) : super(key: key);

  final int intWatts;
  final String time;
  final List<LinearWorkout> data;
  final int totalPower;
  final int highestPower;
  @override
  State<WorkoutComplete> createState() => _WorkoutCompleteState();
}

class _WorkoutCompleteState extends State<WorkoutComplete> {
  AppConfig? config;
  StopWatchTimer _stopWatchTimer = StopWatchTimer();
  List<LinearWorkout> arrWattsChart = [];
  FirebaseBloc firebaseBloc = FirebaseBloc();

  @override
  void initState() {
    super.initState();
    arrWattsChart = widget.data;
    _stopWatchTimer = StopWatchTimer(
      onChange: (int value) {},
    );

    _stopWatchTimer.onExecute.add(StopWatchExecute.start);
    updateFirebaseData();
  }

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: _widgetHeaderTitle(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _widgetMaxPower(),
                              _widgetWattsHours(),
                              _widgetMilesCovered(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: _goToHome(),
                        ),
                        Text(
                          'Power Summary'.toUpperCase(),
                          style: config!.abel24FontStyle
                              .copyWith(color: Colors.grey),
                        ),
                        Container(
                          height: 250,
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: chartView(),
                        ),
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
      ),
    );
  }

  // Workout data which will display on charts
  List<charts.Series<LinearWorkout, int>> _createData() {
    List<LinearWorkout> data = [];

    data = arrWattsChart;
    return [
      charts.Series<LinearWorkout, int>(
        id: '',
        colorFn: (_, __) =>
            charts.ColorUtil.fromDartColor(config!.btnPrimaryColor),
        domainFn: (LinearWorkout data, _) => data.second,
        measureFn: (LinearWorkout data, _) => data.workoutData,
        data: data,
      ),
      charts.Series<LinearWorkout, int>(
        id: '',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(Colors.white),
        domainFn: (LinearWorkout data, _) => data.second,
        measureFn: (LinearWorkout data, _) => data.workoutData,
        data: data,
      )..setAttribute(charts.rendererIdKey, 'customPoint'),
    ];
  }

  Widget chartView() {
    return charts.LineChart(
      _createData(),
      defaultRenderer: charts.LineRendererConfig(
        includePoints: true,
        includeArea: true,
        radiusPx: 6,
        areaOpacity: 0.05,
        roundEndCaps: true,
      ),
      customSeriesRenderers: [
        charts.PointRendererConfig(
          customRendererId: 'customPoint',
        )
      ],
      behaviors: [charts.PanAndZoomBehavior()],
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(config!.greyColor),
          ),
          axisLineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(config!.btnPrimaryColor),
          ),
          lineStyle: const charts.LineStyleSpec(
              color: charts.MaterialPalette.transparent),
        ),
        tickProviderSpec:
            const charts.BasicNumericTickProviderSpec(desiredTickCount: 10),
        showAxisLine: true,
      ),
      domainAxis: charts.NumericAxisSpec(
        showAxisLine: true,
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
            color: charts.ColorUtil.fromDartColor(config!.greyColor),
          ),
          axisLineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(config!.btnPrimaryColor),
          ),
          lineStyle: const charts.LineStyleSpec(
              color: charts.MaterialPalette.transparent),
        ),
        tickProviderSpec:
            const charts.BasicNumericTickProviderSpec(desiredTickCount: 10),
      ),
      animate: false,
    );
  }

  Widget _widgetHeaderTitle() {
    return GradientText(
      AppConstants.youSmashedIt.toUpperCase(),
      colors: [AppColors.green, AppColors.greenBlack],
      gradientDirection: GradientDirection.ttb,
      style: config!.antonio40FontStyle,
    );
  }

  Widget _widgetWattsHours() {
    // final double wattGenerated =
    // _workoutData![WorkoutDataKey.wattsGenerated] as double;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Image.asset(ImgConstants.watts, height: 70),
          ),
          _widgetGeneratedValues(widget.totalPower),
          const SizedBox(
            height: 4,
          ),
          Text(
            AppConstants.wattHours,
            style: config!.abelNormalFontStyle.apply(color: config!.greyColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _widgetGeneratedValues(int value) {
    return Text(
      value.toString(),
      style: config!.antonioHeading1FontStyle.apply(color: config!.whiteColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _widgetMaxPower() {
    // final double wattGenerated =
    // _workoutData![WorkoutDataKey.wattsGenerated] as double;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Image.asset(ImgConstants.power, height: 70),
          ),
          _widgetGeneratedMAxPowerValues(widget.highestPower),
          const SizedBox(
            height: 4,
          ),
          Text(
            AppConstants.maxPower,
            style: config!.abelNormalFontStyle.apply(color: config!.greyColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _widgetGeneratedMAxPowerValues(int value) {
    return Text(
      value.toString(),
      style: config!.antonioHeading1FontStyle.apply(color: config!.whiteColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _widgetMilesCovered() {
    // final double wattGenerated =
    // _workoutData![WorkoutDataKey.wattsGenerated] as double;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Image.asset(ImgConstants.stopWatch, height: 70),
          ),
          _widgetGeneratedMilesValues(0),
          const SizedBox(
            height: 4,
          ),
          Text(
            AppConstants.milesCovered,
            style: config!.abelNormalFontStyle.apply(color: config!.greyColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _widgetGeneratedMilesValues(double value) {
    var timeinMin = DateTime.parse('2021-12-23 ${widget.time}').minute;
    var timeinSec = DateTime.parse('2021-12-23 ${widget.time}').second % 60;
    return Text(
      '${timeinMin}m ${timeinSec}s',
      style: config!.antonioHeading1FontStyle.apply(color: config!.whiteColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _goToHome() {
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
        onPressed: _navigation,
        child: GradientText(
          AppConstants.home.toUpperCase(),
          colors: [config!.btnPrimaryColor, AppColors.greenBlack],
          gradientDirection: GradientDirection.ttb,
          style: config!.antonio40FontStyle.copyWith(fontSize: 20),
        ),
      ),
    );
  }

  // Add data in to Hive locally
  Future<void> updateFirebaseData() async {
    var time = _calculatingTimeDifference();
    final workoutSessionDocumentReference =
        firebaseBloc.createWorkoutSessionDoc();
    await addingDataToWorkoutSessionCollection(
        time, workoutSessionDocumentReference.id);
    await addingDataToTenantCollection(workoutSessionDocumentReference.id);
    aGeneralBloc.exerciseType = null;
  }

  /// Upload workout session id to [tenant] collection

  addingDataToTenantCollection(workoutSessionId) async {
    if (locationId != null && tenantId != null) {
      try {
        DocumentReference ref = FirebaseFirestore.instance
            .collection('workout_session')
            .doc(workoutSessionId);
        await firebaseBloc.saveDataInToTenantCollection(
          data: {'workout_session_id': ref},
          context: context,
          onSuccess: (data) {},
        );
      } on Exception {
        rethrow;
      }
    }
  }

  /// Upload workout data to [workout_session] collection
  addingDataToWorkoutSessionCollection(
      DateTime time, workoutSessionDocId) async {
    try {
      DocumentReference ref =
          FirebaseFirestore.instance.collection('bike').doc(bikeId);
      WorkoutSessionModel model = WorkoutSessionModel(
        deviceUuid: ref,
        ftpValue: aGeneralBloc.ftpValue ?? 0,
        peakPower: widget.highestPower,
        totalPower: widget.intWatts,
        workoutType: aGeneralBloc.exerciseType.toString(),
        workoutTimeEnd: DateTime.now(),
        workoutTimeStart: time,
      );
      await aGeneralBloc.firebaseBloc.saveDataInToGymUserCollection(
        docID: workoutSessionDocId,
        data: model.toJson(),
        onSuccess: (data) {},
      );
    } on Exception {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Data has not been uploaded, please check your internet connection')));
    }
  }

  _navigation() {
    if (espDevice != null) {
      // Bike is already connected
      // Navigate to workout selection screen
      Navigator.popAndPushNamed(context, WorkoutSelection.routeName);
    } else {
      // Bike is not connected
      // Navigate to  Home again
      Navigator.popAndPushNamed(context, Connect.routeName);
    }
  }

  _calculatingTimeDifference() {
    var dur = widget.time.split(':');
    var difference = DateTime.now().subtract(Duration(
      hours: int.parse(dur[0]),
      minutes: int.parse(dur[1]),
      seconds: int.parse(dur[2]),
    ));
    return difference;
  }
}

class LinearWorkout {
  final int second;
  final int workoutData;

  LinearWorkout(this.second, this.workoutData);
}
