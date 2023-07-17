import 'dart:async';

import 'package:energym/screens/secret_menu/secret_menu.dart';
import 'package:energym/src/import.dart';
import 'package:flutter_blue/flutter_blue.dart';

Widget topView(BuildContext maincontext, {bool isLeftLogoVisible = false}) {
  aGeneralBloc.blocBluetooth.mainContext = maincontext;

  getBikeId();
  getVersion();
  getDeviceId();

  return Stack(
    alignment: Alignment.center,
    children: [
      const Image(
        image: AssetImage(ImgConstants.topView),
        fit: BoxFit.cover,
      ),
      StreamBuilder<List<BluetoothDevice?>?>(
        stream: Stream.periodic(const Duration(seconds: 1))
            .asyncMap((_) => flutterInstance.connectedDevices),
        builder: (c, snapshot) {
          if (snapshot.hasData) {
            BluetoothDevice? bleDevice;

            for (final BluetoothDevice? data in snapshot.data!) {
              if (bikeId == data?.id.id) {
                bleDevice = data;
                break;
              }
            }

            if (bleDevice != null && bleDevice != espDevice) {
              aGeneralBloc.blocBluetooth.setStateListener(bleDevice);
            }
          }
          if (espDevice != null) {
            return GestureDetector(
              onLongPress: () {
                Timer(
                    const Duration(seconds: 5),
                    () => Navigator.push(maincontext,
                        MaterialPageRoute(builder: (_) => const SecretMenu())));
              },
              child: Image.asset(
                ImgConstants.logoWithGreen, // logo_with_green
              ),
            );
          }
          return Image.asset(
            ImgConstants.logoWithGrey,
          );
        },
      ),
      // Positioned(
      //   bottom: 5,
      //   child: StreamBuilder(
      //     stream: Stream.periodic(const Duration(seconds: 1)),
      //     builder: (BuildContext context, AsyncSnapshot snapshot) {
      //       return espDevice != null
      //           ? Container(
      //               height: 8,
      //               width: 8,
      //               decoration: BoxDecoration(
      //                   color: aGeneralBloc.blocBluetooth.dataIsLive
      //                       ? Colors.green
      //                       : Colors.red,
      //                   borderRadius: BorderRadius.circular(20)),
      //             )
      //           : SizedBox();
      //     },
      //   ),
      // ),
      espDevice?.name != null
          ? Positioned(
              top: 10,
              right: 10,
              child: shortBikeId != null
                  ? Text('${espDevice?.name.toUpperCase()}# $shortBikeId')
                  : const Text(''))
          : const SizedBox(),
      if (isLeftLogoVisible)
        Positioned(
          top: 10,
          left: 10,
          child: Image.asset(
            ImgConstants.energymLogo,
            width: 141,
            height: 28,
          ),
        )
      else
        version != null
            ? Positioned(
                top: 10,
                left: 10,
                child: Text('v$version+$buildNumber'),
              )
            : const SizedBox(),
    ],
  );
}

Widget widgetEnergymBottom(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Image.asset(
      ImgConstants.energymLogo,
      width: 230,
    ),
  );
}

BoxDecoration setBackGroundImage(BuildContext context) {
  return const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(ImgConstants.background),
      fit: BoxFit.fill,
    ),
  );
}

Widget centerPart(BuildContext context, Widget? widget,
    {double bottomPadding = 0, double topPadding = 120}) {
  return Center(
    child: Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      child: SizedBox(
        height: double.infinity,
        child: widget,
      ),
    ),
  );
}

Future<bool> isTablet(BuildContext context) async {
  var shortestSide = MediaQuery.of(context).size.shortestSide;

  // Determine if we should use mobile layout or not, 600 here is
  // a common breakpoint for a typical 7-inch tablet.
  return shortestSide >= 600;
}
