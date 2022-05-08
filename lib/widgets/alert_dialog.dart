import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomAlertDialog extends StatelessWidget{
  
  final String? title;
  final String? content;
  final String btnLabel;
  final Function btnOnPressed;
  final String? secondBtnLabel;
  final Function? secondBtnOnPressed;
  final String? thirdBtnLabel;
  final Function? thirdBtnOnPressed;

  CustomAlertDialog({
    required this.title,
    required this.content,
    required this.btnLabel,
    required this.btnOnPressed,
    this.secondBtnLabel,
    this.secondBtnOnPressed,
    this.thirdBtnLabel,
    this.thirdBtnOnPressed
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title!.tr()),
      content: Text(content!.tr()),
      actions: <Widget>[
        FlatButton(
          child: Text(btnLabel.tr()),
          onPressed: btnOnPressed as void Function()?,
        ),
        secondBtnLabel != null ?
        FlatButton(
          child: Text(secondBtnLabel!.tr()),
          onPressed: secondBtnOnPressed as void Function()?,
        )
        :
        Container(),
        thirdBtnLabel != null ?
        FlatButton(
          child: Text(thirdBtnLabel!.tr()),
          onPressed: thirdBtnOnPressed as void Function()?,
        )
        :
        Container()
      ],
    );
  }
}