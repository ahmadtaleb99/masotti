import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/setting.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/alert_dialog.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import 'home_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  AsyncMemoizer memoizer = AsyncMemoizer();
  Setting? settings;
  bool arabicLanguage = false;
  late bool englishLanguageSelection;
  int isLoading = 0;
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
    englishLanguageSelection =   Localizations.localeOf(context).languageCode == 'en' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Settings',
        currentContext: context,
        itemsInCart: itemsInCart,
        showBackButton: true,

        cartIconExist: true,
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
              child: FutureBuilder(
                  future: getSettings(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: ColoredCircularProgressIndicator(),
                          ));
                    }
                    var response = snap.data;
                    if (response is String) {
                      return RequestEmptyData(
                        message: response,
                      );
                    }
                    Setting settings = response as Setting;
                    return Container(
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
                                  settings.language = 0;
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
                                  settings.language = 1;
                                  context.locale = Locale('ar', 'DZ');
                                }),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                top: Constants.doublePadding,
                                bottom: Constants.padding),
                            alignment: arabicLanguage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: AutoSizeText(
                              'Notifications'.tr(),
                              style: TextStyle(
                                  color: Constants.identityColor,
                                  fontWeight: FontWeight.bold),
                              minFontSize: Constants.fontSize + 2,
                              maxFontSize: Constants.fontSize + 4,
                            ),
                          ),
                          Container(
                            child: Column(
                              children: <Widget>[
                                SwitchListTile(
                                  title: AutoSizeText(
                                    "Add Offer".tr(),
                                    minFontSize: Constants.fontSize,
                                  ),
                                  value: settings.offerNotifications == 0
                                      ? false
                                      : true,
                                  activeColor: Constants.redColor,
                                  onChanged: (value) => setState(() =>
                                      settings.offerNotifications =
                                          value == true ? 1 : 0),
                                ),
                                SwitchListTile(
                                  title: AutoSizeText(
                                    "Add Category".tr(),
                                    minFontSize: Constants.fontSize,
                                  ),
                                  value: settings.categoryNotifications == 0
                                      ? false
                                      : true,
                                  activeColor: Constants.redColor,
                                  onChanged: (value) => setState(() =>
                                      settings.categoryNotifications =
                                          value == true ? 1 : 0),
                                ),
                                SwitchListTile(
                                  title: AutoSizeText(
                                    "Receive Coupon".tr(),
                                    minFontSize: Constants.fontSize,
                                  ),
                                  value: settings.couponNotifications == 0
                                      ? false
                                      : true,
                                  activeColor: Constants.redColor,
                                  onChanged: (value) => setState(() =>
                                      settings.couponNotifications =
                                          value == true ? 1 : 0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: Constants.padding),
                            alignment: Alignment.center,
                            child: ButtonTheme(
                              minWidth: containerWidth / 2,
                              child: RaisedButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Constants.buttonsVerticalPadding),
                                  color: Constants.redColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          Constants.borderRadius)),
                                  child: AutoSizeText('Save'.tr(),
                                      style: TextStyle(
                                        color: Constants.whiteColor,
                                        fontWeight: FontWeight.bold
                                      ),
                                      minFontSize: Constants.fontSize - 2,
                                      maxFontSize: Constants.fontSize),
                                  onPressed: isLoading == 1
                                      ? null
                                      : () => saveSettings()),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  getSettings() async {
    return memoizer.runOnce(() async {
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString(Constants.keyAccessToken);

      if (accessToken != null) {
        final String url = 'get-customer-settings';
        final response = await http.get(Uri.parse(Constants.apiUrl + url), headers: {
          'Authorization': 'Bearer ' + accessToken,
          'referer': Constants.apiReferer
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status']) {
            print('asdasd');
            print(data['data']['language']);
            data = data['data'];
            settings = Setting();
            settings!.language = data['language'];
            // englishLanguageSelection = data['language'] == 0 ? true : false;
            //taking the value from the context
            settings!.offerNotifications = data['add_offer_notifications'];
            settings!.categoryNotifications = data['add_category_notifications'];
            settings!.couponNotifications = data['receive_coupon_notifications'];
            return settings;
          }
        }
      }
      return false;
    });
  }

  saveSettings() async {
    setState(() => isLoading = 1);

    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(Constants.keyAccessToken);

    if (accessToken != null) {
      final String url = 'change-customer-settings';
      final response = await http.post(Uri.parse(Constants.apiUrl + url),
          body: settings!.toJson(),
          headers: {
            'Authorization': 'Bearer ' + accessToken,
            'referer': Constants.apiReferer
          });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          CustomDialog(
            context: context,
            title: 'Successful..'.tr(),
            message: data['data'].toString().tr(),
            okButtonTitle: 'Ok'.tr(),
            cancelButtonTitle: 'Cancel'.tr(),
            onPressedCancelButton: () {
              Navigator.pop(context);
            },
            onPressedOkButton: () {
              Navigator.pop(context);
            },
            color: Constants.greenColor,
            icon: "assets/images/correct.svg",
          ).showCustomDialog();
        }
      }
    }

    setState(() => isLoading = 0);
  }
}
