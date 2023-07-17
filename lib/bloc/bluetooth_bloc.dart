import 'dart:async';

import 'package:energym/bloc/firebase_bloc.dart';
import 'package:energym/src/import.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'package:rxdart/rxdart.dart';

// This class is bluetooth bloc, all business logic are written here
class BluetoothBloc {
  // fitness service UUID
  final String bleFitnessServiceUUID = '00001826-0000-1000-8000-00805f9b34fb';
  final String bleFTPServiceUUID = '00004542-0000-1000-8000-00805f9b34fb';

  // Group workout service UUID
  final String bleTotalPowerServiceUUID =
      '00004542-0000-1000-8000-00805f9b34fb';

  // fitness Characteristics UUID
  final String bleFTMSCharacteristicUUID =
      '00002ad2-0000-1000-8000-00805f9b34fb';

  // Write Characteristics UUID
  final String bleWriteClientCharacteristicUUID =
      '00002ad9-0000-1000-8000-00805f9b34fb';
  final String bleWriteFTPCharacteristicUUID =
      '00005255-0000-1000-8000-00805f9b34fb';
  final String bleReadFTPCharacteristicUUID =
      '00005755-0000-1000-8000-00805f9b34fb';

  // Group Workout Characteristics UUID
  final String bleTotalPowerCharacteristicUUID =
      '00004658-0000-1000-8000-00805f9b34fb';

  BluetoothCharacteristic? bleWriteClientCharacteristic;
  BluetoothCharacteristic? bleWriteFTPCharacteristic;
  BluetoothCharacteristic? bleReadFTPCharacteristic;
  BluetoothCharacteristic? bleFTMSCharacteristic;
  BluetoothCharacteristic? bleTotalPowerCharacteristic;

  Timer? liveIndicatorTimer;

  Timer? healthTimer;

  bool reconnectionDialogShow = false;

  final BehaviorSubject<List<int>> _ftmsDataStream =
      BehaviorSubject<List<int>>();

  ValueStream<List<int>> get ftmsDataStream => _ftmsDataStream.stream;

  StreamSubscription<List<int>>? liveEventListener;
  bool isStateListenerSet = false;
  BuildContext? mainContext;
  FirebaseBloc firebaseBloc = FirebaseBloc();
  bool dataIsLive = false;
  AppConfig? config;
  List<BluetoothService> bleServices = [];

  void dispose() {
    bleWriteFTPCharacteristic = null;
    bleWriteClientCharacteristic = null;
  }

  /// Adding [characteristics] to the global listener
  startWorkoutData() async {
    if (!bleFTMSCharacteristic!.isNotifying) {
      bleFTMSCharacteristic!.setNotifyValue(true);
    }

    if (aGeneralBloc.inLiveWorkout &&
        !bleTotalPowerCharacteristic!.isNotifying) {
      bleTotalPowerCharacteristic!.setNotifyValue(true);
    }
  }

  stopWorkoutData() async {
    bleTotalPowerCharacteristic?.setNotifyValue(false);
    bleFTMSCharacteristic?.setNotifyValue(false);
  }

  startLiveIndicator() {
    if (bleServices.isNotEmpty) {
      startWorkoutData();
      liveEventListener?.cancel();
      liveEventListener = bleFTMSCharacteristic?.value.listen((newEvent) {
        liveIndicatorTimer?.cancel();
        liveIndicatorTimer = Timer(const Duration(seconds: 5), () {
          dataIsLive = false;
          // if (!reconnectionDialogShow) reconnectionDialog();
          firebaseBloc.eventLogs('bt_connection_lost', {});
        });
        _ftmsDataStream.sink.add(newEvent);
        if (newEvent.isNotEmpty) {
          if (!dataIsLive) {
            firebaseBloc.eventLogs('bt_connection_reconnected', {});
          }
          dataIsLive = true;
        } else {
          dataIsLive = false;
        }
      });
    } else {
      dataIsLive = false;
    }
  }

  stopLiveIndicator() async {
    await liveEventListener?.cancel();
    healthTimer?.cancel();
    liveIndicatorTimer?.cancel();
    liveEventListener = null;
    liveIndicatorTimer = null;
    healthTimer = null;
    bleFTMSCharacteristic?.setNotifyValue(false);
  }

  /// setting timer to send connection report every [one_hour]
  startHealthReport() {
    healthTimer ??= Timer.periodic(const Duration(hours: 1), (timer) {
      firebaseBloc.eventLogs(
          'bt_connection_status', {'bt_connection_status': espDevice != null});
    });
  }

  // Future<dynamic> reconnectionDialog() {
  //   reconnectionDialogShow = true;
  //   return showDialog(
  //       barrierDismissible: false,
  //       context: kNavigatorKey.currentState!.overlay!.context,
  //       builder: (context) {
  //         config = AppConfig.of(context);
  //         return Dialog(
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   "There is an issue in connection with bike, please restart app",
  //                   style: TextStyle(fontSize: 25),
  //                 ),
  //                 SizedBox(height: 20),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     Container(
  //                       height: 50,
  //                       width: 100,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.all(Radius.circular(12)),
  //                         border: GradientBoxBorder(
  //                           gradient: LinearGradient(
  //                             colors: [
  //                               Color(0xFF1DA538),
  //                               Color(0xFF035B15),
  //                             ],
  //                             begin: FractionalOffset.topCenter,
  //                             end: FractionalOffset.bottomCenter,
  //                           ),
  //                           width: 4,
  //                         ),
  //                       ),
  //                       child: TextButton(
  //                         onPressed: () async {
  //                           reconnectionDialogShow = false;
  //                           Navigator.pop(context);
  //                         },
  //                         child: FittedBox(
  //                           child: Padding(
  //                             padding: EdgeInsets.symmetric(
  //                                 horizontal:
  //                                     MediaQuery.of(context).size.width * 0.04),
  //                             child: GradientText(
  //                               AppConstants.back.toUpperCase(),
  //                               colors: [
  //                                 Color(0xFF1DA538),
  //                                 Color(0xFF035B15),
  //                               ],
  //                               gradientDirection: GradientDirection.ttb,
  //                               style: config!.antonio40FontStyle,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Container(
  //                       height: 50,
  //                       width: 100,
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.all(Radius.circular(12)),
  //                         border: GradientBoxBorder(
  //                           gradient: LinearGradient(
  //                             colors: [
  //                               Color(0xFFD41010),
  //                               Color(0xFF5E2700),
  //                             ],
  //                             begin: FractionalOffset.topCenter,
  //                             end: FractionalOffset.bottomCenter,
  //                           ),
  //                           width: 4,
  //                         ),
  //                       ),
  //                       child: TextButton(
  //                         onPressed: () => exit(0),
  //                         child: FittedBox(
  //                           child: Padding(
  //                             padding: EdgeInsets.symmetric(
  //                                 horizontal:
  //                                     MediaQuery.of(context).size.width * 0.04),
  //                             child: GradientText(
  //                               AppConstants.restart.toUpperCase(),
  //                               colors: [
  //                                 Color(0xFFD41010),
  //                                 Color(0xFFD41010),
  //                               ],
  //                               gradientDirection: GradientDirection.ttb,
  //                               style: config!.antonio40FontStyle,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  // Discover bleServices of connected BLE device
  Future<void> discoverServices(BluetoothDevice connectedDevice,
      BuildContext context, bool inLiveWorkout) async {
    try {
      bleServices = await connectedDevice.discoverServices();

      // Request for MTU size
      connectedDevice.requestMtu(50);
      firebaseBloc.eventLogs('discovered_services', {});
      discoverCharacteristics();
      // startLiveIndicator();

      // Navigate to pairing complete screen after received bleServices
      if (!inLiveWorkout) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PairComplete(),
          ),
        );
      }
    } on Exception {
      firebaseBloc.eventLogs('discover_services_failed', {});
      getDeviceId();
      if (bikeId != null) {
        firebaseBloc.eventLogs('reconnecting_after_failure', {});
      }
      connectedDevice.connect().then((value) async {
        firebaseBloc.eventLogs('reconnected_after_failure', {});
        await discoverServices(connectedDevice, context, inLiveWorkout);
      });
    }
  }

// Discover characteristics
  discoverCharacteristics() {
    for (BluetoothService service in bleServices) {
      if (service.uuid.toString() == bleTotalPowerServiceUUID ||
          service.uuid.toString() == bleFitnessServiceUUID) {
        // Discover group workout characteristics
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              bleTotalPowerCharacteristicUUID) {
            bleTotalPowerCharacteristic = characteristic;
          }

          if (characteristic.uuid.toString() == bleFTMSCharacteristicUUID) {
            bleFTMSCharacteristic = characteristic;
          }
        }
        if (bleFTMSCharacteristic != null &&
            bleTotalPowerCharacteristic != null) {
          firebaseBloc.eventLogs('discovered_characteristics', {});
        }
      }
    }
  }

  // Discover characteristics
  writeDataCharacteristics() async {
    for (BluetoothService service in bleServices) {
      if (service.uuid.toString() == bleFitnessServiceUUID) {
        // live workout characteristics
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              bleWriteClientCharacteristicUUID) {
            bleWriteClientCharacteristic = characteristic;
          }
        }
      }
    }
  }

  writeFtpCharacteristics() async {
    for (BluetoothService service in bleServices) {
      if (service.uuid.toString() == bleFTPServiceUUID) {
        // live workout characteristics
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == bleWriteFTPCharacteristicUUID) {
            bleWriteFTPCharacteristic = characteristic;
          }
        }
      }
    }
  }

  writeFtpData({int ftpValue = 0, int bikeId = 0}) async {
    try {
      var bikeHex = bikeId.toRadixString(16);
      var bikeHexString = bikeHex.padLeft(6, '0').split('');

      var ftpHex = ftpValue.toRadixString(16);
      var ftpHexString = ftpHex.padLeft(4, '0').split('');

      int? bikePart1 =
          int.parse(bikeHexString[0] + bikeHexString[1], radix: 16);
      int? bikePart2 =
          int.parse(bikeHexString[2] + bikeHexString[3], radix: 16);
      int? bikePart3 =
          int.parse(bikeHexString[4] + bikeHexString[5], radix: 16);

      int? ftpPart1 = int.parse(ftpHexString[0] + ftpHexString[1], radix: 16);
      int? ftpPart2 = int.parse(ftpHexString[2] + ftpHexString[3], radix: 16);

      await bleWriteFTPCharacteristic!.write([
        bikePart1,
        bikePart2,
        bikePart3,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        ftpPart1,
        ftpPart2,
        0x00,
        0x00,
      ]);
    } catch (e) {
      debugPrint('listen after write value2 ${e.toString()}');
    }
  }

  /// writing the [Start] session command
  writeStartSession() async {
    if (bleWriteClientCharacteristic?.value == null) {
      await writeDataCharacteristics();
    }
    bleWriteClientCharacteristic!.write([0x07]);
  }

  /// writing the [Stop] session command
  writeStopSession() async {
    if (bleWriteClientCharacteristic?.value == null) {
      await writeDataCharacteristics();
    }
    bleWriteClientCharacteristic!.write([0x08]);
  }

  /// Write resistance data into ESP
  writeData(BuildContext context, int value) async {
    try {
      await bleWriteClientCharacteristic!.write(
        [0x04, value],
        withoutResponse: false,
      );
    } catch (e) {
      debugPrint('listen after write value2 ${e.toString()}');
    }
  }

  int dataParserAndCalculationFromWriteCha(List<int> data) {
    try {
      if (data.length < 12) {
        return 0;
      }

      // Total power
      var msb = (data[10].toRadixString(16)).padLeft(2, '0');
      var lsb = (data[11].toRadixString(16)).padLeft(2, '0');

      final totalPower = int.parse('$msb$lsb', radix: 16);

      return totalPower;
    } on Exception catch (e) {
      firebaseBloc.eventLogs('total_power_error', {'error': e.toString()});
      return 0;
    }
  }

  // ESP data parsing calculation
  List<int> dataParserAndCalculation(List<int> data) {
    if (data.length == 15) {
      return [0, 0, 0, 0, 0];
    }
    // 0 index for cadence / rpm
    // 1 index for resistance
    // 2 index for watts
    // 3 index for Av. watts / power
    // 4 index for calories / Energy

    List<String>? arrTempHexa = [];
    List<int>? arrActualValues = [];
    data.asMap().forEach((index, value) {
      var hexaValue = (value.toRadixString(16)).padLeft(2, '0');
      arrTempHexa.add(hexaValue);

      if (index == 1) {
        // Flag
      } else if (index == 7) {
        // Cadence
        final instCadence =
            int.parse('${arrTempHexa[7]}${arrTempHexa[6]}', radix: 16) ~/ 2;
        arrActualValues.add(instCadence);
      } else if (index == 14) {
        // Resistance
        final instRes =
            int.parse('${arrTempHexa[14]}${arrTempHexa[13]}', radix: 16);
        arrActualValues.add(instRes);
      } else if (index == 16) {
        // Inst. Power / Watts
        final instPower =
            int.parse('${arrTempHexa[16]}${arrTempHexa[15]}', radix: 16);
        arrActualValues.add(instPower);
      } else if (index == 18) {
        // Avg. power / Avg. Watts
        final avWatts =
            int.parse('${arrTempHexa[18]}${arrTempHexa[17]}', radix: 16);
        arrActualValues.add(avWatts);
      } else if (index == 20) {
        // Calories / Energy
        final instEnergy =
            int.parse('${arrTempHexa[20]}${arrTempHexa[19]}', radix: 16);
        arrActualValues.add(instEnergy);
      }
    });
    return arrActualValues.isNotEmpty ? arrActualValues : [0, 0, 0, 0, 0];
  }

  /// This function creates a common [device_state] Stream.
  /// Also [Connected] and [Disconnect] functionality is been handled here.
  setStateListener(BluetoothDevice? bleDevice) {
    if (isStateListenerSet) {
      return null;
    }

    late StreamSubscription stateSubscription;

    stateSubscription = bleDevice!.state.listen(
      (state) async {
        switch (state) {
          case BluetoothDeviceState.connected:
            if (espDevice == null) {
              firebaseBloc.eventLogs('connection_state_connected', {});
              aGeneralBloc.selectedBike(bleDevice);
              await discoverServices(
                  bleDevice!, mainContext!, aGeneralBloc.inLiveWorkout);
              flutterInstance.stopScan();
              startHealthReport();
              firebaseBloc.fetchBikeInfo();
            }
            break;

          case BluetoothDeviceState.disconnected:
            if (espDevice != null) {
              firebaseBloc.eventLogs('connection_state_disconnected', {
                'isDisconnectedManually': aGeneralBloc.isDisconnectedManually,
                'inLiveWorkout': aGeneralBloc.inLiveWorkout,
              });
              bleDevice = null;
              bleServices = [];
              aGeneralBloc.selectedBike(null);
              bleFTMSCharacteristic = null;
              bleTotalPowerCharacteristic = null;
              // stopLiveIndicator();

              // If user disconnected manually, then delete bike id from local storage too
              if (aGeneralBloc.isDisconnectedManually) {
                await removeBikeId();
                aGeneralBloc.isDisconnectedManually = false;
              }

              // Navigate only if not in live workout
              if (!aGeneralBloc.inLiveWorkout) {
                aGeneralBloc.exerciseType = null;

                Future.delayed(const Duration(seconds: 2), () async {
                  // Clear all device related variables
                  await stateSubscription.cancel();
                  isStateListenerSet = false;
                  Navigator.popAndPushNamed(mainContext!, Connect.routeName);
                });
              } else {
                // Clear all device related variables
                stateSubscription.cancel();
                isStateListenerSet = false;
              }
            }
            break;
          case BluetoothDeviceState.connecting:
            break;
          case BluetoothDeviceState.disconnecting:
            debugPrint('Disconnecting');
            break;
          default:
        }
      },
    );
    isStateListenerSet = true;
  }
}
