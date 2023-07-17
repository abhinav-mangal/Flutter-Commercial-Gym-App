import 'package:energym/src/import.dart';

bool isLoading = false;

class CustomAlertDialog {
  const CustomAlertDialog();

  Future<void> showExceptionErrorMessage(
      {BuildContext? context,
      String? title,
      TextStyle? titleStyle,
      String? message,
      TextStyle? messageStyle,
      String? buttonTitle,
      Widget? errorIcon,
      Function? onPress}) async {
    showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (BuildContext context) {
        AppConfig config = AppConfig.of(context);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            //height: MediaQuery.of(context).size.height * 0.34,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
                color: config.borderColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 18, 0, 0),
                    child: Text(
                      title,
                      style: titleStyle ??
                          config.calibriHeading2FontStyle
                              .apply(color: config.whiteColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (errorIcon != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: errorIcon,
                  ),
                if (message != null && message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: messageStyle ??
                          config.calibriHeading4FontStyle
                              .apply(color: config.whiteColor),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onPress != null) {
                      onPress();
                    }
                  },
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
                        buttonTitle!,
                        style: config.linkNormalFontStyle
                            .apply(color: config.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
