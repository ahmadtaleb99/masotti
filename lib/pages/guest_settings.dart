import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import 'home_page.dart';

class GuestSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GuestSettingsPageState();
}

class GuestSettingsPageState extends State<GuestSettingsPage> {
  bool arabicLanguage = false;
  bool englishLanguageSelection = false;
  int? itemsInCart = 0;

  @override
  void initState() {
    super.initState();
    getItemsInCartCount();
  }

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
    });
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    englishLanguageSelection = !arabicLanguage;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Settings'.tr(),
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: false,
      ),
      drawer: SideMenu(),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName("/Home"));
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
          return Future.value(true);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(Constants.borderRadius * 2),
              topLeft: Radius.circular(Constants.borderRadius * 2)),
          child: Container(
            color: Constants.whiteColor,
            height: double.infinity,
            child: SingleChildScrollView(
                padding: EdgeInsets.all(Constants.padding),
                child: Container(
                  width: containerWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: Constants.padding),
                        child: AutoSizeText(
                          'Language'.tr(),
                          style: TextStyle(
                            color: Constants.identityColor,
                            fontWeight: FontWeight.bold,
                          ),
                          maxFontSize: Constants.fontSize + 4,
                          minFontSize: Constants.fontSize + 2,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: Constants.padding),
                        height: containerWidth / 4,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Constants.identityColor,
                            blurRadius: 10,
                            offset: Offset(1, 1),
                            spreadRadius: -20,
                          ),
                        ]),
                        child: ButtonTheme(
                          minWidth: containerWidth,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                vertical: Constants.buttonsVerticalPadding),
                            color: englishLanguageSelection
                                ? Constants.identityColor
                                : Constants.whiteColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.borderRadius)),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: englishLanguageSelection
                                                ? Constants.whiteColor
                                                : Constants.identityColor),
                                        color: Constants.whiteColor),
                                    child: Icon(
                                      Icons.check,
                                      color: englishLanguageSelection
                                          ? Constants.identityColor
                                          : Constants.whiteColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: AutoSizeText(
                                    'English',
                                    style: TextStyle(
                                        color: englishLanguageSelection
                                            ? Constants.whiteColor
                                            : Constants.identityColor,
                                        fontSize: Constants.fontSize -
                                            (MediaQuery.of(context)
                                                        .devicePixelRatio >
                                                    1.2
                                                ? 4
                                                : 0)),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () => setState(() {
                              englishLanguageSelection = true;
                              context.locale = Locale('en', 'US');
                            }),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: Constants.padding),
                        height: containerWidth / 4,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: Constants.identityColor,
                            blurRadius: 10,
                            offset: Offset(1, 1),
                            spreadRadius: -20,
                          ),
                        ]),
                        child: ButtonTheme(
                          minWidth: containerWidth,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                vertical: Constants.buttonsVerticalPadding),
                            color: englishLanguageSelection
                                ? Constants.whiteColor
                                : Constants.identityColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.borderRadius)),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Container(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: !englishLanguageSelection
                                                ? Constants.whiteColor
                                                : Constants.identityColor),
                                        color: Constants.whiteColor),
                                    child: Icon(
                                      Icons.check,
                                      color: englishLanguageSelection
                                          ? Constants.whiteColor
                                          : Constants.identityColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: AutoSizeText(
                                    'عربي',
                                    style: TextStyle(
                                        color: !englishLanguageSelection
                                            ? Constants.whiteColor
                                            : Constants.identityColor,
                                        fontSize: Constants.fontSize -
                                            (MediaQuery.of(context)
                                                        .devicePixelRatio >
                                                    1.2
                                                ? 4
                                                : 0)),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () => setState(() {
                              englishLanguageSelection = false;
                              context.locale = Locale('ar', 'DZ');
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
