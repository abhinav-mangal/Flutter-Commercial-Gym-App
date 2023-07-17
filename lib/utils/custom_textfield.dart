import 'package:energym/src/import.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final BuildContext? context;
  final EdgeInsetsDirectional? padding;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final String? labelText;
  final String? hindText;
  final String? errorText;
  final TextInputType? inputType;
  final TextCapitalization? capitalization;
  final TextInputAction? inputAction;
  final bool? isObscureText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final EdgeInsetsDirectional? contentPadding;
  final Function(String)? onChange;
  final Function(String)? onSubmit;
  final int? maxLine;
  final int? maxLength;
  final bool? isEnable;
  final bool? isShowBorderOnUnFocus;
  final bool? isAutoCorrect;
  final bool? enableSuggestions;
  final bool? isMobileField;
  final bool? showHint;
  final bool? showFloatingHint;
  final bool? isCircleCorner;
  final Color? bgColor;
  final Alignment? stackAlignment;
  final TextStyle? mainTextStyle;
  final TextStyle? hintTextStyle;
  final bool? isAutoFocused;
  final String? prefixTxt;
  final bool? isShowCounter;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final bool isAGradientShadow;
  const CustomTextField(
      {Key? key,
      this.context,
      this.padding,
      this.controller,
      this.focusNode,
      this.nextFocus,
      this.labelText,
      this.hindText,
      this.errorText,
      this.inputType,
      this.capitalization,
      this.inputAction,
      this.isObscureText,
      this.prefixWidget,
      this.suffixWidget,
      this.contentPadding,
      this.onChange,
      this.onSubmit,
      this.maxLine,
      this.maxLength,
      this.isEnable = true,
      this.isShowBorderOnUnFocus = true,
      this.isAutoCorrect = false,
      this.enableSuggestions = false,
      this.isMobileField = false,
      this.showHint = true,
      this.showFloatingHint = false,
      this.isCircleCorner = false,
      this.bgColor,
      this.stackAlignment,
      this.mainTextStyle,
      this.hintTextStyle,
      this.isAutoFocused = false,
      this.prefixTxt = '',
      this.isShowCounter = false,
      this.floatingLabelBehavior = FloatingLabelBehavior.never,
      this.isAGradientShadow = false})
      : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    AppConfig config = AppConfig.of(context);
    double cornerRadius = widget.isCircleCorner! ? 12.0 : 4.0;
    return Container(
      decoration: widget.isAGradientShadow ? decoration() : null,
      padding:
          widget.padding ?? const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Stack(
        alignment: widget.stackAlignment != null
            ? widget.stackAlignment!
            : widget.prefixWidget != null
                ? Alignment.topLeft
                : Alignment.topRight,
        children: [
          TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            keyboardType: widget.inputType ?? TextInputType.text,
            keyboardAppearance: config.brightness,
            textCapitalization:
                widget.capitalization ?? TextCapitalization.none,
            textInputAction: widget.inputAction ?? TextInputAction.next,
            obscureText: widget.isObscureText ?? false,
            onChanged: widget.onChange,
            onSubmitted: widget.onSubmit,
            maxLines: widget.maxLine,
            enabled: widget.isEnable,
            maxLength: widget.maxLength,
            // maxLengthEnforced: widget.maxLength != null,
            enableInteractiveSelection: true,
            autocorrect: widget.isAutoCorrect!,
            autofocus: widget.isAutoFocused!,
            enableSuggestions: widget.enableSuggestions!,
            buildCounter: (BuildContext? context,
                {int? currentLength, int? maxLength, bool? isFocused}) {
              if (widget.isShowCounter!) {
                return Text(
                  '$currentLength/$maxLength',
                  style: config.calibriHeading3FontStyle.apply(
                    color: config.greyColor,
                  ),
                );
              } else {
                return null;
              }
            },

            //enabled: controller != _txtFieldCountryCode,
            style: widget.mainTextStyle ??
                config.calibriHeading3FontStyle.apply(
                  color: config.whiteColor,
                ),
            inputFormatters: <TextInputFormatter>[
              if (widget.maxLength != null)
                LengthLimitingTextFieldFormatterFixed(widget.maxLength!),
              if (widget.inputType == TextInputType.phone ||
                  widget.inputType == TextInputType.number)
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9-]+$')),
              // if (widget.isMobileField!)
              //   MaskedTextInputFormatter(
              //       mask: 'xxx-xxx-xxxxxx', separator: '-'),
            ],
            decoration: InputDecoration(
              fillColor: widget.bgColor ?? Colors.transparent,
              filled: widget.bgColor != null,
              labelText: widget.labelText,
              hintText: widget.showHint! ? '' : widget.hindText,
              //hasFloatingPlaceholder: widget?.showFloatingHint ?? false,
              errorText: widget.errorText,
              labelStyle: widget.hintTextStyle ??
                  config.abel20FontStyle.apply(
                    color: config.greyColor,
                  ),
              hintStyle: widget.hintTextStyle ??
                  config.paragraphExtraSmallFontStyle
                      .apply(color: config.greyColor),
              errorMaxLines: 4,
              prefixText: widget.prefixTxt,
              //hintStyle: ,
              prefixIcon:
                  widget.prefixTxt!.isNotEmpty ? Text(widget.prefixTxt!) : null,
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              //suffixIcon: widget.suffixWidget,
              floatingLabelBehavior: widget.floatingLabelBehavior,
              contentPadding: widget.contentPadding ??
                  const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              border: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
              disabledBorder: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
              enabledBorder: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
              focusedBorder: widget.bgColor != null
                  ? OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(cornerRadius),
                      ),
                    )
                  : UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.bgColor != null
                            ? Colors.transparent
                            : config.borderColor,
                      ),
                      //borderRadius: BorderRadius.circular(10.0),
                    ),
            ),
          ),
          if (widget.prefixWidget != null)
            Positioned(
              left: 0,
              child: widget.prefixWidget!,
            )
          else
            const SizedBox(),
          if (widget.suffixWidget != null)
            Positioned(
              right: 0,
              child: widget.suffixWidget!,
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }

  BoxDecoration? decoration() {
    return BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      gradient: LinearGradient(
        colors: [AppColors.black, AppColors.greyColor2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 1],
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.white24,
          blurRadius: 2,
          offset: Offset(1, 1),
          spreadRadius: 1,
        ),
      ],
    );
  }
}

/// TextInputFormatter that fixes the regression.
/// https://github.com/flutter/flutter/issues/67236
///
/// Remove it once the issue above is fixed.
class LengthLimitingTextFieldFormatterFixed
    extends LengthLimitingTextInputFormatter {
  LengthLimitingTextFieldFormatterFixed(int maxLength) : super(maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (maxLength != null &&
        maxLength! > 0 &&
        newValue.text.characters.length > maxLength!) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValue.text.characters.length == maxLength) {
        return oldValue;
      }
      // ignore: invalid_use_of_visible_for_testing_member
      return LengthLimitingTextInputFormatter.truncate(newValue, maxLength!);
    }
    return newValue;
  }
}
