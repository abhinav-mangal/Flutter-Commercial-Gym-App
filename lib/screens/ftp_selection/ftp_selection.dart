import 'package:energym/bloc/firebase_bloc.dart';
import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

enum ExerciseType { instantWorkout, groupChallenge }

// This is to select FTP before start workout
class FTPSelection extends StatefulWidget {
  const FTPSelection({Key? key, this.type = ExerciseType.instantWorkout})
      : super(key: key);
  final ExerciseType? type;
  @override
  State<FTPSelection> createState() => _FTPSelectionState();
}

class _FTPSelectionState extends State<FTPSelection>
    with TickerProviderStateMixin {
  AppConfig? config;
  TextEditingController? _txtController;
  FocusNode? _focusNode;
  TabController? _tabController;
  late ExerciseType _workoutType;
  FirebaseBloc bloc = FirebaseBloc();

  int index = 0;
  final int beginnerFtp = 130;
  final int intermediateFtp = 160;
  final int expertFtp = 190;

  int? _selectedFTP;

  bool isNavigated = false;

  @override
  void initState() {
    super.initState();
    _txtController = TextEditingController();
    _selectedFTP = beginnerFtp;
    _txtController!.text = _selectedFTP.toString();
    _focusNode = FocusNode();
    _tabController = TabController(length: 3, vsync: this);
    _workoutType = widget.type!;
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    _txtController!.dispose();
    _tabController!.dispose();
    super.dispose();
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 55),
                              child: _topText(),
                            ),
                            Row(
                              children: [
                                Text(
                                  AppConstants.hintFTP,
                                  style: config!.abel36FontStyle
                                      .copyWith(color: config?.greyColor),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                            _widgetTypeFTP(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 55),
                              child: _widgetorSelect(),
                            ),
                            _widgetTabBar(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 55),
                              child: _widgetDescription(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _connectButton(index),
                            )
                          ],
                        ),
                      ),
                    ),
                    bottomPadding: 50,
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: _backButton(index),
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

  Widget _topText() {
    return Text(
      AppConstants.titleFTP,
      style: config?.abel36FontStyle.apply(
        color: config?.whiteColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _widgetTypeFTP() {
    return CustomTextField(
      mainTextStyle: const TextStyle(fontSize: 36),
      stackAlignment: Alignment.centerRight,
      context: context,
      controller: _txtController,
      focusNode: _focusNode,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      // labelText: AppConstants.hintFTP,
      inputType: TextInputType.number,
      capitalization: TextCapitalization.none,
      inputAction: TextInputAction.go,
      enableSuggestions: true,
      isAutoCorrect: true,
      suffixWidget: _widgetDownArrow(),
      maxLength: 10,
      onChange: (String value) {
        try {
          _selectedFTP = int.parse(value);
        } on Exception catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter numbers only.')));
        }
      },
      onSubmit: (String value) {
        _focusNode!.unfocus();

        if (value.isEmpty) {
          return;
        }

        // updateFTPValueAtFirebase();
      },
    );
  }

  Widget _widgetDownArrow() {
    return Container(
      height: 48,
      width: 10,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: SvgPicture.asset(
        ImgConstants.downArrow,
        color: config?.whiteColor,
        //width: 8,
        //height: 4,
      ),
    );
  }

  Widget _widgetorSelect() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        AppConstants.orSelectFTP,
        textAlign: TextAlign.left,
        style: config?.abel36FontStyle.apply(
          color: config?.greyColor,
        ),
      ),
    );
  }

  Widget _widgetTabBar() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: config?.borderColor,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: config?.whiteColor,
        labelStyle: config?.abel14FontStyle,
        unselectedLabelColor: config?.greyColor,
        unselectedLabelStyle: config?.calibriHeading5FontStyle,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: config!.lightBorderColor,
          ),
          color: config?.darkGreyColor,
        ),
        tabs: <Tab>[
          Tab(
            height: 100,
            child: Text(
              AppConstants.beginnerFTP,
              style: const TextStyle(fontSize: 25),
            ),
          ),
          Tab(
            height: 100,
            child: Text(
              AppConstants.intermediateFTP,
              style: const TextStyle(fontSize: 25),
            ),
          ),
          Tab(
            height: 100,
            child: Text(
              AppConstants.athleteFTP,
              style: const TextStyle(fontSize: 25),
            ),
          ),
        ],
        onTap: (i) async {
          setState(() {
            index = i;
          });
          if (index == 0) {
            _selectedFTP = beginnerFtp;
          } else if (index == 1) {
            _selectedFTP = intermediateFtp;
          } else if (index == 2) {
            _selectedFTP = expertFtp;
          }
          _txtController!.text = _selectedFTP.toString();
          // _blocProfileSetUp!.onChangeFTP(value: _txtController!.text);
          // updateFTPValueAtFirebase();
        },
      ),
    );
  }

  Widget _widgetDescription() {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        AppConstants.ftpDescription,
        style: config?.abel24FontStyle.apply(
          color: config?.greyColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _connectButton(int index) {
    return Container(
      height: 109,
      width: 224,
      // width: double.infinity,
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
        onPressed: () async {
          if (!isNavigated) {
            isNavigated = true;
            if (_txtController!.text.isNotEmpty && _selectedFTP! > 0) {
              String newBikeId = shortBikeId ?? '0';
              await aGeneralBloc.blocBluetooth.writeFtpCharacteristics();
              await aGeneralBloc.blocBluetooth.writeFtpData(
                  ftpValue: _selectedFTP!, bikeId: int.parse(newBikeId));
              aGeneralBloc.ftpValue = _selectedFTP!;
              await aGeneralBloc.blocBluetooth.writeStartSession();
              navigateTo();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter FTP value')));
            }
          }
        },
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: GradientText(
              AppConstants.confirm.toUpperCase(),
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

  Widget _backButton(int index) {
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
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (c) => const WorkoutSelection()));
        },
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.04),
            child: GradientText(
              AppConstants.back.toUpperCase(),
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

  /// Navigate to screen according workout selection
  navigateTo() {
    // if (tenantId != null && locationId != null) {
    if (_workoutType == ExerciseType.instantWorkout) {
      // Navigate to Instant workout flow
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LiveWorkout(ftpValue: _selectedFTP)),
      );
    } else if (_workoutType == ExerciseType.groupChallenge) {
      // Navigate to Instant workout flow
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const YouName()),
      );
    }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content:
    //           Text("Please add TenantId and LocationId from secret menu")));
    // }
  }
}
