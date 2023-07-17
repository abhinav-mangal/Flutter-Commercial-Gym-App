import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

// This screen to add name of user who will do group workout
class YouName extends StatefulWidget {
  const YouName({Key? key}) : super(key: key);

  @override
  State<YouName> createState() => _YouNameState();
}

class _YouNameState extends State<YouName> {
  AppConfig? config;

  final TextEditingController _txtFieldName = TextEditingController();
  final FocusNode _focusNodeName = FocusNode();

  @override
  void initState() {
    super.initState();
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
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 170),
                        child: _topText(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 70,
                          left: 130,
                          right: 130,
                        ),
                        child: _textFieldName(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: _connectButton(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: widgetEnergymBottom(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _topText() {
    return Text(
      AppConstants.whatName,
      style: config?.abel24FontStyle.apply(
        color: config?.whiteColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _textFieldName() {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -2,
        intensity: 0.7,
        surfaceIntensity: 1,
        color: AppColors.greyColor1,
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: CustomTextField(
        isAGradientShadow: true,
        // hindText: 'AppConstants',
        context: context,
        controller: _txtFieldName,
        focusNode: _focusNodeName,
        bgColor: Colors.transparent,
        labelText: 'e.g. GoGreenOrGoHome',
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        inputType: TextInputType.text,
        capitalization: TextCapitalization.words,
        inputAction: TextInputAction.next,
        enableSuggestions: true,
        isAutoCorrect: true,
        maxLength: 100,
        hintTextStyle: config?.interTextField1FontStyle,
        // onSubmit: (name) {
        //   print(name);

        //   if (name.trim().length == 0) {
        //     // alert
        //     return;
        //   }
        //   updateNameAtFirebase();
        // },
      ),
    );
  }

  Widget _connectButton() {
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
        onPressed: () {
          if (_txtFieldName.text.isNotEmpty) {
            aGeneralBloc.userName = _txtFieldName.text;
            navigate();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Please enter your name to continue'),
            ));
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

  navigate() async {
    // Navigate to searching user for challenge
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const GroupWaiting(),
      ),
    );
  }
}
