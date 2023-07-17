import 'dart:async';
import 'package:energym/bloc/firebase_bloc.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/src/import.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

BluetoothDevice? espDevice;
String? shortBikeId;
String? version;
String? buildNumber;
String? tenantId;
String? locationId;
String? deviceId;
String? bikeId;

class GeneralBloc {
  bool isDevicePad = false;
  final BehaviorSubject<int> _intSelection = BehaviorSubject<int>.seeded(-1);

  ValueStream<int> get intSelection => _intSelection.stream;

  ExerciseType? exerciseType;
  FirebaseBloc firebaseBloc = FirebaseBloc();
  Timer? timer;
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  bool isDisconnectedManually = false;
  bool inLiveWorkout = false;
  BluetoothBloc blocBluetooth = BluetoothBloc();
  int? ftpValue;
  String? userName;

  void resetTimer() async {
    if (timer != null) {
      timer!.cancel();
    }
    if (inLiveWorkout) {
      await ScreenBrightness().resetScreenBrightness();
    } else {
      timer = Timer(const Duration(minutes: 5), () async {
        await ScreenBrightness().setScreenBrightness(0.05);
      });
    }
    await ScreenBrightness().resetScreenBrightness();
  }

  cellSelection(int index) {
    _intSelection.sink.add(index);
  }

  selectedBike(BluetoothDevice? connectedDevice) {
    if (connectedDevice == null) {
      espDevice = null;
    } else {
      espDevice = connectedDevice;
    }
  }

  BluetoothDevice? getSelectedBike() {
    return espDevice;
  }
}

/// here we are fetching [bike_id] from local storage
Future<String?> getBikeId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  shortBikeId = prefs.getString(AppKeyConstant.shortBikeId);
  return shortBikeId;
}

///  Store [tenantId] and [locationId] to local storage

setTenantAndLocationId(String tenantId, String locationId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(AppKeyConstant.tenantId, tenantId);
  await prefs.setString(AppKeyConstant.locationId, locationId);
}

/// Fetch [tenantId] and [locationId] from local storage

Future<String?> getTenantAndLocationId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  tenantId = prefs.getString(AppKeyConstant.tenantId);
  locationId = prefs.getString(AppKeyConstant.locationId);
  return null;
}

/// here we are storing [device_id] to local storage
saveDeviceId(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(AppKeyConstant.deviceId, id);
  bikeId = id;
}

/// here we are fetching [device_id] from local storage
getDeviceId() async {
  if (bikeId == null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    FirebaseBloc firebaseBloc = FirebaseBloc();
    bikeId = prefs.getString(AppKeyConstant.deviceId);
    if (bikeId != null) {
      firebaseBloc.eventLogs('found_bike_id', {});
    }
  }
  return bikeId;
}

/// here we are removing [device_id] and [bike_id] from local storage
///
Future<String?> removeBikeId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(AppKeyConstant.deviceId);
  prefs.remove(AppKeyConstant.shortBikeId);
  bikeId = null;
  return null;
}

/// here we are fetching [version_no] from local storage
Future<String?> getVersion() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  version = prefs.getString(AppKeyConstant.version);
  buildNumber = prefs.getString(AppKeyConstant.buildNumber);
  return null;
}

final GeneralBloc aGeneralBloc = GeneralBloc();
