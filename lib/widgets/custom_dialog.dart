import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../constants.dart';

class CustomDialog {
  final BuildContext? context;
  final String? title;
  final String? message;
  final String? okButtonTitle;
  final String? cancelButtonTitle;
  final Function? onPressedOkButton;
  final Function? onPressedCancelButton;
  final Color? color;
  final String? icon;

  CustomDialog(
      {this.context,
      this.title,
      this.message,
      this.okButtonTitle,
      this.cancelButtonTitle,
      this.onPressedOkButton,
      this.onPressedCancelButton,
      this.color,
      this.icon});

  showCustomDialog() {
    double containerWidth =
        MediaQuery.of(context!).size.width - (Constants.doublePadding);
    showDialog(
        context: context!,
        builder: (context) {
          return ButtonBarTheme(
            data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(Constants.borderRadius))),
              titlePadding: EdgeInsets.symmetric(horizontal: 30),
              title: Container(
                height: 150,
                // width: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(300),
                      bottomRight: Radius.circular(300),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[400]!,
                        blurRadius: 5,
                        offset: Offset(1, 1),
                      ),
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: color,
                          fontSize: Constants.fontSize,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SvgPicture.asset(
                      icon!,
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: color,
                            fontSize: Constants.fontSize - 2,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: onPressedCancelButton == null
                        ? [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 40),
                                child: ButtonTheme(
                                  minWidth: containerWidth / 3,
                                  height: 40,
                                  child: RaisedButton(
                                    child: Text(okButtonTitle!,
                                        style: TextStyle(
                                            color: Constants.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Constants.fontSize - 2)),
                                    onPressed: onPressedOkButton as void
                                        Function()?,
                                    color: color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Constants.borderRadius),
                                    ),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                            ),
                          ]
                        : [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 40),
                                child: ButtonTheme(
                                  minWidth: containerWidth / 3,
                                  height: 40,
                                  child: RaisedButton(
                                    child: Text(cancelButtonTitle!,
                                        style: TextStyle(
                                            color: Constants.identityColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Constants.fontSize - 2)),
                                    onPressed: onPressedCancelButton as void
                                        Function()?,
                                    color: Constants.whiteColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Constants.borderRadius),
                                    ),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 40),
                                child: ButtonTheme(
                                  minWidth: containerWidth / 3,
                                  height: 40,
                                  child: RaisedButton(
                                    child: Text(okButtonTitle!,
                                        style: TextStyle(
                                            color: Constants.whiteColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: Constants.fontSize - 2)),
                                    onPressed:
                                        onPressedOkButton as void Function()?,
                                    color: color,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Constants.borderRadius),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
