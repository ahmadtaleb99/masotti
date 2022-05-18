import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:masotti/main.dart';
import 'package:masotti/pages/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import './login.dart';

class FirstRunPage extends StatefulWidget{
  String?  productId;
  FirstRunPage({this.productId});
  @override
  State<StatefulWidget> createState() => FirstRunPageState();
}

class FirstRunPageState extends State<FirstRunPage>{
  String selectedLanguage = '';

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageWidth = containerWidth;
    return Scaffold(
      backgroundColor: Constants.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              right: Constants.padding, left: Constants.padding),        child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    bottom: Constants.doublePadding, top: Constants.padding * 4),              width: imageWidth,
                height: imageWidth * 47.2 / 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Constants.logoImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    right: Constants.padding, left: Constants.padding),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(top: Constants.padding),
                      child: AutoSizeText(
                        'Choose Language'.tr(),
                        style: TextStyle(
                          color: Constants.identityColor,
                          fontWeight: FontWeight.bold
                        ),
                        maxFontSize: Constants.fontSize + 4,
                        minFontSize: Constants.fontSize + 2,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: Constants.padding),
                      height: containerWidth / 4,
                      decoration: BoxDecoration(
                        boxShadow: [
                            BoxShadow(
                              color: Constants.identityColor,
                              blurRadius: 10,
                              offset: Offset(1, 1),
                              spreadRadius: -20,
                          ),
                        ]
                      ),
                      child: ButtonTheme(
                        minWidth: containerWidth,
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: Constants.buttonsVerticalPadding),
                          color: selectedLanguage == 'EN' ? Constants.identityColor : Constants.whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Constants.borderRadius)
                          ),
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
                                    border: Border.all(color: selectedLanguage == 'EN' ? Constants.whiteColor : Constants.identityColor),
                                    color: Constants.whiteColor
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: selectedLanguage == 'EN' ? Constants.identityColor : Constants.whiteColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: AutoSizeText(
                                  'English',
                                  style: TextStyle(
                                    color: selectedLanguage == 'EN' ? Constants.whiteColor : Constants.identityColor,
                                  ),
                                  maxFontSize: Constants.fontSize,
                                  minFontSize: Constants.fontSize - 4
                                ),
                              ),
                            ],
                          ),
                          onPressed: () => setState(() => selectedLanguage = 'EN'),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: Constants.padding),
                      height: containerWidth / 4,
                      decoration: BoxDecoration(
                        boxShadow: [
                            BoxShadow(
                              color: Constants.identityColor,
                              blurRadius: 10,
                              offset: Offset(1, 1),
                              spreadRadius: -20,
                          ),
                        ]
                      ),
                      child: ButtonTheme(
                        minWidth: containerWidth,
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: Constants.buttonsVerticalPadding),
                          color: selectedLanguage != 'EN' ? Constants.identityColor : Constants.whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Constants.borderRadius)
                          ),
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
                                    border: Border.all(color: selectedLanguage != 'EN' ? Constants.whiteColor : Constants.identityColor),
                                    color: Constants.whiteColor
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: selectedLanguage != 'EN' ? Constants.identityColor : Constants.whiteColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: AutoSizeText(
                                  'عربي',
                                  style: TextStyle(
                                    color: selectedLanguage != 'EN' ? Constants.whiteColor : Constants.identityColor,
                                  ),
                                  maxFontSize: Constants.fontSize,
                                  minFontSize: Constants.fontSize - 4
                                ),
                              ),
                            ],
                          ),
                          onPressed: () => setState(() => selectedLanguage = 'AR'),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: Constants.padding),
                      margin: EdgeInsets.only(top: Constants.padding),
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: containerWidth / 2,
                        height: 50,
                        child: RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: Constants.buttonsVerticalPadding),
                          color: Constants.redColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Constants.borderRadius)
                          ),
                          child: AutoSizeText(
                            'Start shopping'.tr(),
                            style: TextStyle(
                              color: Constants.whiteColor,
                                fontWeight: FontWeight.bold
                            ),
                            maxFontSize: Constants.fontSize,
                            minFontSize: Constants.fontSize - 2,
                          ),
                          onPressed: () => saveLanguage(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.keyFirstRunOfApp, false);
    if(selectedLanguage == 'EN'){
      context.locale = Locale('en', 'US');
    }
    else{
      context.locale = Locale('ar', 'DZ');
    }
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        if(widget.productId != null && widget.productId!.isNotEmpty)
          return ProductPage(id: widget.productId);
        return LoginPage();
      }

    ));
  }
}