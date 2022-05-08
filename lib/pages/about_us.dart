import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocalization;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../assets/contact_us_icons.dart';
import 'home_page.dart';

class AboutUsPage extends StatefulWidget {

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {

  int? itemsInCart = 0;
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    getItemsInCartCount();
  }

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      authenticated =
      prefs.getString(Constants.keyAccessToken) != null ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.padding * 4);
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'About Us',
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: authenticated ? true : false,
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
                child: Container(
              margin: EdgeInsets.all(Constants.doublePadding),
              width: containerWidth,
              child: Column(
                children: <Widget>[
                  Container(
                    height: 55,
                    width: containerWidth,
                    child: Stack(
                      children: <Widget>[
                        // Align(
                        //   alignment: Alignment.bottomCenter,
                        //   child: Container(
                        //     height: 50,
                        //     width: MediaQuery.of(context).size.width,
                        //     decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.all(
                        //             Radius.circular(Constants.borderRadius)),
                        //         color: Constants.redColor),
                        //   ),
                        // ),
                        Container(
                          height: 50,
                          width: containerWidth,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Constants.borderRadius)),
                              color: Constants.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[500]!,
                                  blurRadius: 3,
                                  offset: Offset(1, 1),
                                ),
                              ]),
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              'INFORMATION ABOUT US:'.tr(),
                              style: TextStyle(
                                color: Constants.identityColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxFontSize: Constants.fontSize - 2,
                              minFontSize: Constants.fontSize - 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: Constants.doublePadding),
                    width: containerWidth,
                    height: containerWidth,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(Constants.flexSolutionsLogoImage),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Container(
                    width: containerWidth,
                    child: AutoSizeText(
                      'Company About Us Information'.tr(),
                      style: TextStyle(height: 1.5),
                      minFontSize: Constants.fontSize - 2,
                      maxFontSize: Constants.fontSize,
                    ),
                  ),
                  Container(
                    width: containerWidth,
                    margin: EdgeInsets.only(
                        bottom: Constants.padding, top: Constants.padding),
                    alignment: arabicLanguage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: AutoSizeText(
                      'CONTACT US'.tr(),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      ),
                      maxFontSize: Constants.fontSize - 2,
                      minFontSize: Constants.fontSize - 4,
                    ),
                  ),
                  Container(
                      width: containerWidth,
                      height: containerWidth + (containerWidth / 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.phone,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                      margin: arabicLanguage
                                          ? EdgeInsets.only(
                                              right: Constants.padding)
                                          : EdgeInsets.only(
                                              left: Constants.padding),
                                      alignment: arabicLanguage
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company phone number'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ),
                                      ))),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.mail,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(
                                            right: Constants.padding)
                                        : EdgeInsets.only(
                                            left: Constants.padding),
                                    alignment: arabicLanguage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company email address'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        )),
                                  )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.website,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(
                                            right: Constants.padding)
                                        : EdgeInsets.only(
                                            left: Constants.padding),
                                    alignment: arabicLanguage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company website'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        )),
                                  )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.facebook,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(
                                            right: Constants.padding)
                                        : EdgeInsets.only(
                                            left: Constants.padding),
                                    alignment: arabicLanguage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company facebook url'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ))),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.instagram,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                      margin: arabicLanguage
                                          ? EdgeInsets.only(
                                              right: Constants.padding)
                                          : EdgeInsets.only(
                                              left: Constants.padding),
                                      alignment: arabicLanguage
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company instagram url'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ),
                                      ))),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.linkedin,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(
                                            right: Constants.padding)
                                        : EdgeInsets.only(
                                            left: Constants.padding),
                                    alignment: arabicLanguage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company linkedin url'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ))),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.telegram,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(
                                            right: Constants.padding)
                                        : EdgeInsets.only(
                                            left: Constants.padding),
                                    alignment: arabicLanguage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company telegram url'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ))),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Icon(
                                    ContactUsIcons.twitter,
                                    color: Constants.redColor,
                                    size: 22,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(
                                            right: Constants.padding)
                                        : EdgeInsets.only(
                                            left: Constants.padding),
                                    alignment: arabicLanguage
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: AutoSizeText(
                                          'Company twitter url'.tr(),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ))),
                              ),
                            ],
                          )
                        ],
                      )),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
