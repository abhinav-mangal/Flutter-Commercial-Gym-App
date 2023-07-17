import 'package:energym/src/import.dart';

AppBar getMainAppBar(
  BuildContext? context,
  AppConfig? appConfig, {
  VoidCallback? onBack,
  String? title,
  Widget? widget,
  Widget? leadingWidget,
  List<Widget>? actions,
  double? elevation,
  bool? isBackEnable = true,
  bool? centerTitle = true,
  Color? backgroundColor,
  Color? textColor,
}) {
  assert(context != null);

  final TextStyle textStyle = appConfig!.calibriHeading3FontStyle
      .apply(color: textColor ?? context!.theme.colorScheme.secondary);

  // ignore: parameter_assignments
  isBackEnable ??= ModalRoute.of(context!)!.canPop;

  return AppBar(
    automaticallyImplyLeading: false,
    centerTitle: centerTitle,
    backgroundColor: backgroundColor ?? context!.theme.colorScheme.secondary,
    title: title != null ? Text(title, style: textStyle) : widget,
    actions: actions,
    elevation: elevation,
    flexibleSpace: const Image(
      image: AssetImage(ImgConstants.topView),
      fit: BoxFit.cover,
    ),
  );
}
