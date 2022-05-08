import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:masotti/assets/my_flutter_app_icons.dart';
import '../pages/about_us.dart';
import '../constants.dart';

class WhoAreWeButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - (Constants.doublePadding);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) => AboutUsPage()
      )),
      child: Container(
        width: containerWidth / 2,
        height: containerWidth / 8,
        margin: EdgeInsets.only(bottom: Constants.padding),
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              child: Container(
                width: containerWidth / 2,
                height: containerWidth / 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(Constants.borderRadius)),
                  color: Constants.redColor
                ),
              ),
            ),
            Container(
              width: containerWidth / 2,
              height: containerWidth / 8 - 5,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(Constants.borderRadius)),
                color: Constants.whiteColor,
                boxShadow: [
                    BoxShadow(
                      color: Colors.grey[600]!,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                  ),
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 5, right: 10, left: 10),
                    child: AutoSizeText(
                      'WHO ARE WE?'.tr(),
                      style: TextStyle(
                        color: Constants.redColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxFontSize: Constants.fontSize,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 10, left: 10),
                    child: Icon(MyFlutterApp.group_640, size: 12, color: Constants.redColor,),
                  )
                ],
              )
            ),
          ],
        ),
      )
    );
  }
}