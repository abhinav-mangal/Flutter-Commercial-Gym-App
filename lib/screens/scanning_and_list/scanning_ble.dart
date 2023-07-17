// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:energym/bloc/firebase_bloc.dart';
import 'package:energym/src/import.dart';

import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

// This screen to scan BLE device and BLE to app connection
class ScanningBLE extends StatefulWidget {
  const ScanningBLE({Key? key}) : super(key: key);

  @override
  State<ScanningBLE> createState() => _ScanningBLEState();
}

class _ScanningBLEState extends State<ScanningBLE>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  AppConfig? config;
  List<ScanResult>? resultDevice = [];
  FirebaseBloc firebaseBloc = FirebaseBloc();
  String? connectedBikeId;
  bool startedConnecting = false;
  StreamSubscription<List<ScanResult>>? scanResultListener;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    aGeneralBloc.cellSelection(-1);
    _startAnimation();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      connectedBikeId = await getDeviceId();
      setState(() {});
    });
    _permission();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    scanResultListener?.cancel();
    flutterInstance.stopScan();
    // _stopAnimation();
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
              children: [topView(context), center(context)],
            ),
          ),
        ),
      ),
      floatingActionButton: _widgetEnergymBottom(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _widgetEnergymBottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _refreshButton(),
                Text(connectedBikeId != null ? '$connectedBikeId' : ''),
                _restartButton(),
              ],
            ),
          ),
          Image.asset(
            ImgConstants.energymLogo,
            width: 230,
          ),
        ],
      ),
    );
  }

  Widget _refreshButton() {
    return Container(
      height: 50,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1DA538),
              Color(0xFF035B15),
            ],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
          ),
          width: 4,
        ),
      ),
      child: TextButton(
        onPressed: () async => await refreshScanning(),
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: GradientText(
              AppConstants.refresh.toUpperCase(),
              colors: const [
                Color(0xFF1DA538),
                Color(0xFF035B15),
              ],
              gradientDirection: GradientDirection.ttb,
              style: config!.antonio40FontStyle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _restartButton() {
    return Container(
      height: 50,
      width: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD41010),
              Color(0xFF5E2700),
            ],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
          ),
          width: 4,
        ),
      ),
      child: TextButton(
        onPressed: () => exit(0),
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: GradientText(
              AppConstants.restart.toUpperCase(),
              colors: const [
                Color(0xFFD41010),
                Color(0xFF5E2700),
              ],
              gradientDirection: GradientDirection.ttb,
              style: config!.antonio40FontStyle,
            ),
          ),
        ),
      ),
    );
  }

  Future scanResultStream() async {
    if (scanResultListener != null) {
      scanResultListener!.cancel();
    }
    firebaseBloc.eventLogs('setting_bt_scan_listener', {});
    scanResultListener =
        flutterInstance.scanResults.listen((scanResults) async {
      setState(() => resultDevice = scanResults);

      if (resultDevice!.isNotEmpty) {
        List<String>? tempDevices = [];
        for (var device in scanResults) {
          tempDevices.add(device.device.id.id);
        }
        if (connectedBikeId != null) {
          if (!startedConnecting) {
            for (int i = 0; i < resultDevice!.length; i++) {
              try {
                if (resultDevice![i].device.id.id == connectedBikeId) {
                  if (espDevice == null) {
                    setState(() => startedConnecting = true);
                    firebaseBloc.eventLogs('connecting_to_device', {
                      'bike_name': resultDevice![i].device.name,
                      'bike_id': resultDevice![i].device.id.id,
                    });
                    scanResultListener!.cancel();
                    await resultDevice![i].device.connect();
                    firebaseBloc.eventLogs('connected_to_device', {
                      'bike_name': resultDevice![i].device.name,
                      'bike_id': resultDevice![i].device.id.id,
                    });
                    flutterInstance.stopScan();
                  } else {
                    firebaseBloc
                        .eventLogs('found_bike_but_already_connected', {});
                  }
                }
              } on Exception catch (e) {
                firebaseBloc.eventLogs('connecting_to_device_error', {
                  'error': e.toString(),
                });
                setState(() => startedConnecting = false);
                await _startScanning();
              }
            }
          }
        }
      }
    });
  }

  Widget center(BuildContext context) {
    return centerPart(
      context,
      SizedBox(
          height: double.infinity,
          child: resultDevice!.isNotEmpty && connectedBikeId == null
              ? _listView()
              : _scanningUIWithText()),
      bottomPadding: 70,
    );
  }

  // Permission for BLuetooth
  _permission() async {
    firebaseBloc.eventLogs('checking_bt_permission', {});
    final PermissionStatus status = await Permission.bluetooth.request();
    if (Platform.isIOS) {
      if (status.isGranted) {
        _startScanning();
      }
    } else {
      final PermissionStatus status1 = await Permission.bluetoothScan.request();
      final PermissionStatus status2 =
          await Permission.bluetoothConnect.request();
      final PermissionStatus status3 =
          await Permission.bluetoothAdvertise.request();
      if (status.isGranted &&
          status1.isGranted &&
          status2.isGranted &&
          status3.isGranted) {
        if (await flutterInstance.isOn) {
          _startScanning();
        } else {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return popUp(context, AppConstants.bluetoothOffMessage);
              });
        }
      } else {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return popUp(context, AppConstants.bluetoothPermissionMessage);
            });
        _scanningUIWithText();
      }
    }
  }

  /// Start scanning for BT devices
  _startScanning() async {
    firebaseBloc.eventLogs('starting_bt_scan', {});
    scanResultStream();
    await flutterInstance.startScan(allowDuplicates: true, withServices: [
      Guid(aGeneralBloc.blocBluetooth.bleFitnessServiceUUID)
    ]).timeout(
      const Duration(seconds: 10),
      onTimeout: () => _startScanning(),
    );
  }

  Dialog popUp(BuildContext context, String text) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(height: 30),
            Container(
              height: 50,
              width: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: GradientBoxBorder(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1DA538),
                      Color(0xFF035B15),
                    ],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                  ),
                  width: 4,
                ),
              ),
              child: TextButton(
                onPressed: () async => await openAppSettings()
                    .then((value) => Navigator.pop(context)),
                child: FittedBox(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: GradientText(
                      AppConstants.goToSettings.toUpperCase(),
                      colors: const [
                        Color(0xFF1DA538),
                        Color(0xFF035B15),
                      ],
                      gradientDirection: GradientDirection.ttb,
                      style: config!.antonio40FontStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  refreshScanning() async {
    await flutterInstance.stopScan();
    Future.delayed(const Duration(seconds: 1), () async {
      await _startScanning();
    });
  }

  Widget _animation() {
    return CustomPaint(
      painter: SpritePainter(_controller),
      child: const SizedBox(
        width: double.infinity,
      ),
    );
  }

  Widget _scanningUIWithText() {
    String scanningText = AppConstants.searching;

    if (connectedBikeId != null) {
      if (startedConnecting) {
        scanningText = 'Reconnecting to previous bike';
      } else {
        scanningText = 'Searching for previous bike';
      }
    } else if (startedConnecting) {
      scanningText = 'Connecting to bike';
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        _animation(),
        Text(
          scanningText,
          style: config!.abel24FontStyle,
        ),
      ],
    );
  }

  // Start searching BLE device animation
  void _startAnimation() {
    _controller
      ..stop()
      ..reset()
      ..repeat(period: const Duration(seconds: 1));
  }

  Widget _listView() {
    return StreamBuilder<int>(
      stream: aGeneralBloc.intSelection,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final int intSelected = snapshot.hasData ? snapshot.data! : -1;
        return Column(
          children: [
            if (intSelected >= 0)
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 30),
                child: Container(
                  height: 54,
                  width: 224,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    gradient: LinearGradient(
                      colors: [config!.btnPrimaryColor, AppColors.greenBlack],
                    ),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final ScanResult? selectedDevice =
                          resultDevice?[intSelected];
                      if (selectedDevice != null) {
                        if (selectedDevice.advertisementData.connectable) {
                          await saveDeviceId(selectedDevice.device.id.id);
                          setState(() => startedConnecting = true);
                          flutterInstance.stopScan();
                          await selectedDevice.device.connect();
                        }
                      } else {}
                    },
                    child: Text(
                      AppConstants.connect.toUpperCase(),
                      style: config!.antonio14FontStyle
                          .copyWith(fontSize: 28, color: Colors.black),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: GradientText(
                  AppConstants.selectRegen,
                  colors: [config!.btnPrimaryColor, AppColors.greenBlack],
                  gradientDirection: GradientDirection.ttb,
                  style: config!.antonio14FontStyle.copyWith(fontSize: 28),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: resultDevice?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  ScanResult? device = resultDevice?[index];

                  return GestureDetector(
                    onTap: () {
                      aGeneralBloc.cellSelection(index);
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: aGeneralBloc.isDevicePad ? 80 : 10,
                          vertical: 10,
                        ),
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            border: GradientBoxBorder(
                              gradient: LinearGradient(
                                colors: intSelected == index
                                    ? [
                                        config!.btnPrimaryColor,
                                        AppColors.greenBlack
                                      ]
                                    : [Colors.white24, Colors.black26],
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                              ),
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GradientText(
                                device!.device.name,
                                colors: [
                                  config!.btnPrimaryColor,
                                  AppColors.greenBlack
                                ],
                                gradientDirection: GradientDirection.ttb,
                                style: config!.antonio14FontStyle
                                    .copyWith(fontSize: 28),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                device.device.id.id,
                                style: config!.abel24FontStyle
                                    .copyWith(color: AppColors.lightWhite),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
