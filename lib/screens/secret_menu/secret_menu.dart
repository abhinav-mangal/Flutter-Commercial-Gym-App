import 'package:energym/bloc/firebase_bloc.dart';
import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class SecretMenu extends StatefulWidget {
  const SecretMenu({Key? key}) : super(key: key);

  @override
  State<SecretMenu> createState() => _SecretMenuState();
}

class _SecretMenuState extends State<SecretMenu> {
  AppConfig? config;
  final TextEditingController _txtController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeTenantId = FocusNode();

  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  FirebaseBloc firebaseBloc = FirebaseBloc();

  // var bikeId;
  @override
  void initState() {
    initPackageInfo();
    super.initState();
  }

  Future<void> initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    config = AppConfig.of(context);
    // bikeId = box.read(AppKeyConstant.bikeID);
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
              child: Stack(children: [
                topView(context),
                centerPart(
                  context,
                  Column(
                    children: [
                      Container(
                        height: 54,
                        width: 224,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          gradient: LinearGradient(
                            colors: [
                              config!.btnPrimaryColor,
                              AppColors.greenBlack
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.connected.toUpperCase(),
                            style: config!.antonio14FontStyle
                                .copyWith(fontSize: 28, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.08),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 109,
                                width: 224,
                                // width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  border: GradientBoxBorder(
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
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      GradientText(
                                        '${espDevice?.name.toUpperCase()}',
                                        colors: [
                                          config!.btnPrimaryColor,
                                          AppColors.greenBlack
                                        ],
                                        gradientDirection:
                                            GradientDirection.ttb,
                                        style: config!.antonio40FontStyle,
                                      ),
                                      FittedBox(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04),
                                          child: Text('${espDevice?.id.id}',
                                              style: config!.abel20FontStyle
                                                  .copyWith(
                                                color: AppColors.lightWhite,
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            Expanded(
                              child: Container(
                                height: 109,
                                width: 224,
                                // width: double.infinity,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12)),
                                  border: GradientBoxBorder(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF5E2700),
                                        Color(0xFFD41010),
                                      ],
                                      begin: FractionalOffset.topCenter,
                                      end: FractionalOffset.bottomCenter,
                                    ),
                                    width: 4,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return popUp(context,
                                              AppConstants.disconnecting);
                                        });
                                    // Disconnect bike
                                    aGeneralBloc.isDisconnectedManually = true;
                                    await espDevice!.disconnect();
                                    setState(() {});
                                  },
                                  child: FittedBox(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      child: GradientText(
                                        AppConstants.disconnect.toUpperCase(),
                                        colors: const [
                                          Color(0xFFD41010),
                                          Color(0xFF5E2700),
                                        ],
                                        gradientDirection:
                                            GradientDirection.ttb,
                                        style: config!.antonio40FontStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * 0.03,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.08),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 109,
                                width: 224,
                                // width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  border: GradientBoxBorder(
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
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: shortBikeId != null
                                        ? MainAxisAlignment.spaceEvenly
                                        : MainAxisAlignment.center,
                                    children: [
                                      FittedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: GradientText(
                                            AppConstants.setBikeId
                                                .toUpperCase(),
                                            colors: [
                                              config!.btnPrimaryColor,
                                              AppColors.greenBlack
                                            ],
                                            gradientDirection:
                                                GradientDirection.ttb,
                                            style: config!.antonio40FontStyle,
                                          ),
                                        ),
                                      ),
                                      shortBikeId != null
                                          ? FittedBox(
                                              child: Text(shortBikeId!,
                                                  style: config!.abel20FontStyle
                                                      .copyWith(
                                                    color: AppColors.lightWhite,
                                                  )),
                                            )
                                          : Container()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.05),
                            Expanded(
                              child: Container(
                                height: 109,
                                width: 224,
                                // width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                  border: GradientBoxBorder(
                                    gradient: LinearGradient(
                                      colors: shortBikeId != null
                                          ? [
                                              const Color(0xFFFFEC40),
                                              const Color(0xFFD99F0C),
                                            ]
                                          : [
                                              const Color(0xFFE7FCEB),
                                              const Color(0xFFA2A7A3),
                                            ],
                                      begin: FractionalOffset.topCenter,
                                      end: FractionalOffset.bottomCenter,
                                    ),
                                    width: 4,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                            context: context,
                                            builder: (context) {
                                              AppConfig config =
                                                  AppConfig.of(context);
                                              return _customDialog(
                                                  context, config, [
                                                _customDialogTitle(
                                                    config,
                                                    AppConstants.enterBikeId
                                                        .toUpperCase()),
                                                _customTextField(context,
                                                    _txtController, _focusNode),
                                                const SizedBox(height: 20),
                                                _customButton(context, config,
                                                    onPressed: () async {
                                                  var ftp = 0;
                                                  await aGeneralBloc
                                                      .blocBluetooth
                                                      .writeFtpCharacteristics();
                                                  if (aGeneralBloc.ftpValue !=
                                                      null) {
                                                    ftp =
                                                        aGeneralBloc.ftpValue!;
                                                  }
                                                  await aGeneralBloc
                                                      .blocBluetooth
                                                      .writeFtpData(
                                                    bikeId: int.parse(
                                                        _txtController.text),
                                                    ftpValue: ftp,
                                                  );
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  await prefs.setString(
                                                      AppKeyConstant
                                                          .shortBikeId,
                                                      _txtController.text);
                                                  await getBikeId();
                                                  final bikeDocumentReference =
                                                      firebaseBloc
                                                          .createBikeDoc();
                                                  firebaseBloc
                                                      .addingDataToBikeCollection(
                                                          bikeDocumentReference
                                                              .id);
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                })
                                              ]);
                                            })
                                        .then((valueTenantidcontroller) =>
                                            setState(
                                              () {},
                                            ));
                                  },
                                  child: FittedBox(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.04),
                                      child: GradientText(
                                        shortBikeId != null
                                            ? AppConstants.change
                                            : AppConstants.enterBikeId
                                                .toUpperCase(),
                                        colors: shortBikeId != null
                                            ? [
                                                const Color(0xFFFFEC40),
                                                const Color(0xFFD99F0C),
                                              ]
                                            : [
                                                const Color(0xFFE7FCEB),
                                                const Color(0xFFA2A7A3),
                                              ],
                                        gradientDirection:
                                            GradientDirection.ttb,
                                        style: config!.antonio40FontStyle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              // height: 109,
              // width: 224,
              // width: double.infinity,
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
                onPressed: espDevice == null
                    ? null
                    : () {
                        Navigator.pushReplacementNamed(
                            context, '/WorkoutSelection');
                      },
                child: FittedBox(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04),
                    child: GradientText(
                      AppConstants.home.toUpperCase(),
                      colors: [
                        config!.btnPrimaryColor,
                        AppColors.greenBlack,
                      ],
                      gradientDirection: GradientDirection.ttb,
                      style: config!.antonio40FontStyle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('v${packageInfo.version}+${packageInfo.buildNumber}'),
            const SizedBox(height: 10),
            widgetEnergymBottom(context),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  _customTextField(BuildContext context, TextEditingController controller,
      FocusNode focusNode) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE7FCEB),
              Color(0xFFA2A7A3),
            ],
            begin: FractionalOffset.topCenter,
            end: FractionalOffset.bottomCenter,
          ),
          width: 4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CustomTextField(
          stackAlignment: Alignment.centerRight,
          context: context,
          controller: controller,
          focusNode: focusNode,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          capitalization: TextCapitalization.none,
          inputAction: TextInputAction.go,
          enableSuggestions: true,
          isAutoCorrect: true,
          onChange: (String value) {},
          onSubmit: (String value) {
            _focusNodeTenantId.unfocus();
          },
        ),
      ),
    );
  }

  _customDialogTitle(AppConfig config, String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
      child: Text(
        title,
        style: config.calibriHeading2FontStyle.apply(color: config.whiteColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _customButton(BuildContext context, AppConfig config,
      {required void Function()? onPressed}) {
    return MaterialButton(
      padding: const EdgeInsets.all(0),
      onPressed: onPressed,
      child: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
            color: config.btnPrimaryColor,
            border: Border.all(
              color: config.btnPrimaryColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            AppConstants.confirm,
            style: config.linkNormalFontStyle.apply(color: config.whiteColor),
          ),
        ),
      ),
    );
  }

  Widget _customDialog(
      BuildContext context, AppConfig config, List<Widget> children) {
    _focusNode.requestFocus();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        //height: MediaQuery.of(context).size.height * 0.34,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
            color: config.borderColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Dialog popUp(BuildContext context, String text) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
