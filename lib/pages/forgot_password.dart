import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import 'dart:convert';
import '../widgets/alert_dialog.dart';
import '../constants.dart';
import '../widgets/text_field.dart';
import 'reset_password.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? mobilePhone;
  int isLoading = 0;

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageWidth = containerWidth;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(icon: Icon(Icons.add), onPressed: () {  },color: Colors.blue,),
      ),
      backgroundColor: Constants.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(
                  bottom: Constants.doublePadding, top: Constants.padding * 4),
              width: imageWidth,
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
                  right: Constants.doublePadding,
                  left: Constants.doublePadding),
              child: Column(children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: Constants.padding),
                  child: AutoSizeText(
                    'Please enter your mobile phone in order to send you reset password code'
                        .tr(),
                    style: TextStyle(color: Constants.identityColor),
                    maxFontSize: Constants.fontSize,
                    minFontSize: Constants.fontSize - 2,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CustomTextField(
                        label: 'Mobile Phone',
                        onSaved: (value) => mobilePhone = value,
                        isRequired: true,
                        isPhone: true,
                        icon: MyFlutterApp.mobile_phone,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: Constants.padding),
                        alignment: Alignment.center,
                        child: ButtonTheme(
                          minWidth: containerWidth / 2,
                          height: 50,
                          child: RaisedButton(
                            color: Constants.redColor,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.borderRadius)),
                            child: AutoSizeText(
                              'Send'.tr(),
                              style: TextStyle(
                                  color: Constants.whiteColor,
                                  fontWeight: FontWeight.bold),
                              maxFontSize: Constants.fontSize,
                              minFontSize: Constants.fontSize - 2,
                            ),
                            onPressed: isLoading == 1
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      sendResetPasswordCode(mobilePhone);
                                    }
                                  },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Constants.whiteColor,
                  thickness: 2,
                ),
                Container(
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    'Or'.tr(),
                    style: TextStyle(color: Constants.identityColor),
                    minFontSize: Constants.fontSize - 2,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: Constants.halfPadding),
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    'Enter the sent code'.tr(),
                    style: TextStyle(color: Constants.identityColor),
                    maxFontSize: Constants.fontSize,
                    minFontSize: Constants.fontSize - 2,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: Constants.halfPadding),
                  alignment: Alignment.center,
                  child: ButtonTheme(
                    minWidth: containerWidth / 2,
                    height: 50,
                    child: RaisedButton(
                        elevation: 5,
                        color: Constants.identityColor,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(Constants.borderRadius)),
                        child: AutoSizeText(
                          'Enter Code'.tr(),
                          style: TextStyle(
                              color: Constants.whiteColor,
                              fontWeight: FontWeight.bold),
                          maxFontSize: Constants.fontSize,
                          minFontSize: Constants.fontSize - 2,
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ResetPasswordPage()))),
                  ),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  sendResetPasswordCode(mobilePhone) async {
    setState(() => isLoading = 1);

    final String url = 'forgot-password';
    final response = await http.post(Uri.parse(Constants.apiUrl + url) ,
        body: {'phone': mobilePhone},
        headers: {'referer': Constants.apiReferer});

    setState(() => isLoading = 0);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        CustomDialog(
          context: context,
          title: 'Code Sent'.tr(),
          message:
              'A code has been sent to you in order to reset password'.tr(),
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
      } else {
        CustomDialog(
          context: context,
          title: 'Error'.tr(),
          message: data['message'].toString().tr(),
          okButtonTitle: 'Ok'.tr(),
          cancelButtonTitle: 'Cancel'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(context);
          },
          onPressedOkButton: () {
            Navigator.pop(context);
          },
          color: Constants.redColor,
          icon: "assets/images/wrong.svg",
        ).showCustomDialog();
      }
    }
  }
}
