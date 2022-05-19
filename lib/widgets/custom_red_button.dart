import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class CustomRedButton extends StatelessWidget {
  final String text;
  final  void Function ()? onPressed;
  const CustomRedButton({
    required this.text,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) {
    return  RaisedButton(
      color: Constants.redColor,
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
              Constants
                  .borderRadius)),
      child: AutoSizeText(
        text.tr(),
        style: TextStyle(
            color: Constants
                .whiteColor,
            fontWeight:
            FontWeight.bold),
        minFontSize:
        Constants.fontSize - 2,
        maxFontSize: Constants
            .fontSize,
      ),
      onPressed: onPressed
    );
  }


}
