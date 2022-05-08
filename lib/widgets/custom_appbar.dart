import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';
import '../assets/flutter_custom_icons.dart';

class CustomAppBarWidget extends PreferredSize{
  
  final String title;
  final BuildContext currentContext;

      CustomAppBarWidget({
    required this.title,
    required this.currentContext
  }) : super(child: currentContext.widget, preferredSize:   Size.fromHeight(80) ) ;


  
  @override
  Widget build(BuildContext currentContext) {
    Radius radius = Radius.circular(Constants.borderRadius);
    bool arabicLanguage = Localizations.localeOf(currentContext).languageCode == 'ar' ? true : false;
    BorderRadius borderRadius = arabicLanguage ? BorderRadius.only(bottomLeft: radius, topLeft: radius) : BorderRadius.only(bottomRight: radius, topRight: radius);
    return AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text(
          title.tr(),
          style: TextStyle(color: Constants.identityColor)
        ),
      ),
      backgroundColor: Constants.whiteColor,
      centerTitle: true,
      leading: Builder(
        builder: (context){
          return Container(
            width: 100,
            margin: EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Constants.identityColor
            ),
            child: IconButton(
              icon: Image.asset('assets/images/Component 1 – 49.png'),
              color: Constants.whiteColor,
              onPressed: () => Scaffold.of(currentContext).openDrawer(),
            )
          );
        },
      ),
      elevation: 0,
    );
  }
}