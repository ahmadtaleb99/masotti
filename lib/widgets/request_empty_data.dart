import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

class RequestEmptyData extends StatelessWidget {
  final String message;

  RequestEmptyData({required this.message});

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight = containerWidth / 5;
    return Container(
      color: Constants.whiteColor,
      child: Column(
        children: [
          Container(
            width: containerWidth,
            height: containerHeight,
            alignment: Alignment.center,
            margin: EdgeInsets.all(Constants.padding),
            decoration: BoxDecoration(
              border: Border.all(color: Constants.borderColor!, width: 2),
              borderRadius:
                  BorderRadius.all(Radius.circular(Constants.borderRadius)),
            ),
            child: AutoSizeText(
              message.tr(),
              minFontSize: Constants.fontSize - 2,
              maxFontSize: Constants.fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
