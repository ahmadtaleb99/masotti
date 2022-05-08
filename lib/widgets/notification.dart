import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';
import '../assets/flutter_custom_icons.dart';

class NotificationWidget extends StatelessWidget{

  final String id;
  final String? titleEn;
  final String? titleAr;
  final String? contentEn;
  final String? contentAr;
  final bool hasBeenRead;

  NotificationWidget({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.contentEn,
    required this.contentAr,
    required this.hasBeenRead,
  });

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight = containerWidth / 10 * 4;
    double iconPadding = containerHeight / 10 * 3;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool arabicLanguage = Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(Constants.borderRadius)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5,
              offset: Offset(0, 0),
            )
          ],
        // border: Border.all(color: hasBeenRead ? Constants.identityColor : Constants.whiteColor),
        color: hasBeenRead ? Constants.whiteColor : Constants.identityColor
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: containerWidth / 10 * 3,
            padding: EdgeInsets.only(top: iconPadding, bottom: iconPadding, right: 20, left: 20),
            child: Icon(
              hasBeenRead ? MyFlutterApp.group_773 : CustomIcons.unread_notification,
              color: hasBeenRead ? Constants.identityColor : Constants.whiteColor,
              size: hasBeenRead ? 60 : 50,
            )
          ),
          VerticalDivider(
            thickness: 3,
            color: hasBeenRead ? Constants.identityColor : Constants.whiteColor,
          ),
          Container(
            width: containerWidth / 10 * 6,
            padding: EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: containerWidth / 5 * 3,
                  padding: EdgeInsets.only(bottom: 10),
                  child: AutoSizeText(
                    arabicLanguage ? titleAr! : titleEn!,
                    style: TextStyle(
                      color: hasBeenRead ? Constants.identityColor : Constants.whiteColor, 
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 2,
                    minFontSize: Constants.fontSize - (devicePixelRatio > 1.2 ? 4 : 0),
                  )
                ),
                Container(
                  width: containerWidth / 5 * 3,
                  child: AutoSizeText(
                    arabicLanguage ? contentAr! : contentEn!,
                    style: TextStyle(
                      color: hasBeenRead ? Constants.identityColor : Constants.whiteColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: Constants.fontSize - (devicePixelRatio > 1.2 ? 4 : 0),
                  )
                )
              ],
            )
          )
        ],
      ),
    );
  }
}