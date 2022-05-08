import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './intro_page.dart';
import '../widgets/alert_dialog.dart';
import '../constants.dart';
import '../widgets/text_field.dart';

class VerifyAccountPage extends StatefulWidget {
  final String? phoneNumber;

  VerifyAccountPage({required this.phoneNumber});

  @override
  State<StatefulWidget> createState() =>
      VerifyAccountPageState(phoneNumber: this.phoneNumber);
}

class VerifyAccountPageState extends State<VerifyAccountPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String? phoneNumber;
  String? code;
  int isLoading = 0;
  bool canResendVerificationCode = true;

  VerifyAccountPageState({required this.phoneNumber});

  @override
  void initState() {
    super.initState();
    checkTimeToAllowResendVerificationCode();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageWidth = containerWidth / 4 * 3;
    return Scaffold(
      backgroundColor: Constants.whiteColor,
      body: SingleChildScrollView(
        padding:
            EdgeInsets.only(right: Constants.padding, left: Constants.padding),
        child: Column(children: <Widget>[
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
            margin: EdgeInsets.symmetric(
                vertical: Constants.padding, horizontal: Constants.padding),
            child: AutoSizeText(
              'Please enter the code that you have received'.tr(),
              style: TextStyle(
                color: Constants.identityColor,
              ),
              maxFontSize: Constants.fontSize,
              minFontSize: Constants.fontSize - 4,
            ),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextField(
                  label: 'Code',
                  onSaved: (value) => code = value,
                  isRequired: true,
                  isCode: true,
                  textInputAction: TextInputAction.done,
                ),
                Container(
                  padding: EdgeInsets.only(top: Constants.padding),
                  alignment: Alignment.center,
                  child: ButtonTheme(
                    minWidth: containerWidth / 2,
                    height: 50,
                    child: RaisedButton(
                      color: Constants.identityColor,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Constants.borderRadius)),
                      child: AutoSizeText(
                        'Verify'.tr(),
                        style: TextStyle(
                          color: Constants.whiteColor,
                        ),
                        maxFontSize: Constants.fontSize,
                      ),
                      onPressed: isLoading == 1
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                verifyAccount(code);
                              }
                            },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: Constants.padding, bottom: Constants.doublePadding),
            width: containerWidth / 3 * 2,
            alignment: Alignment.center,
            child: canResendVerificationCode
                ? InkWell(
                    onTap:
                        isLoading == 1 ? null : () => resendVerificationSms(),
                    child: AutoSizeText(
                      'Resend Verification Code'.tr(),
                      style: TextStyle(
                        color: Constants.linkColor,
                      ),
                      maxFontSize: Constants.fontSize - 4,
                    ),
                  )
                : AutoSizeText(
                    'You will be able to send a new code after a few minutes'
                        .tr(),
                    style: TextStyle(
                      color: Constants.identityColor,
                    ),
                    maxFontSize: Constants.fontSize - 4,
                  ),
          ),
        ]),
      ),
    );
  }

  directLogin() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final tokenResponse = await fcm.getToken();
    var deviceToken = tokenResponse != null && tokenResponse.isNotEmpty
        ? tokenResponse
        : null;
    final String url = 'direct-login-customer';

    final response = await http.post(Uri.parse(Constants.apiUrl + url ),
        body: {'phone': phoneNumber, 'device_token': deviceToken},
        headers: {'referer': Constants.apiReferer});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(Constants.keyAccessToken, data['token']);
        prefs.setBool(Constants.keyAccountStatus, true);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SplashScreen()),
            (Route<dynamic> route) => false);

        return true;
      }
    }
    return false;
  }

  verifyAccount(code) async {
    setState(() => isLoading = 1);

    final String url = 'verify-account';
    final response = await http.post(Uri.parse(Constants.apiUrl + url ),
        body: {'code': code, 'phone': phoneNumber},
        headers: {'referer': Constants.apiReferer});

    setState(() => isLoading = 0);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool(Constants.keyNotVerifiedAccount, false);
        prefs.setString(Constants.keyNotVerifiedAccountMobile, '');

        CustomDialog(
          context: context,
          title: 'Account Verified'.tr(),
          message: 'Your account has been verified successfully'.tr(),
          okButtonTitle: 'Ok'.tr(),
          cancelButtonTitle: 'Cancel'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(context);
          },
          onPressedOkButton: () async {
            Navigator.pop(context);
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: Text('Signing in'),
                      content: LinearProgressIndicator());
                });
            if (!await directLogin()) {
              Navigator.pop(context);
              CustomDialog(
                context: context,
                title: 'Couldn\'t sign in'.tr(),
                message: 'Something went wrong, please try again later'.tr(),
                okButtonTitle: 'Ok'.tr(),
                cancelButtonTitle: 'Cancel'.tr(),
                onPressedCancelButton: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                onPressedOkButton: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                color: Constants.redColor,
                icon: "assets/images/wrong.svg",
              ).showCustomDialog();
            }
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

  resendVerificationSms() async {
    setState(() {
      isLoading = 1;
      canResendVerificationCode = false;
    });

    final String url = 'resend-verification-sms';
    final response = await http.post(Uri.parse(Constants.apiUrl + url ),
        body: {'phone': phoneNumber},
        headers: {'referer': Constants.apiReferer});

    setState(() => isLoading = 0);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        final prefs = await SharedPreferences.getInstance();
        DateTime dateWithAdditional5Minutes =
            DateTime.now().add(Duration(minutes: 4));
        prefs.setString(Constants.keyRegisteringMinutiesTime,
            dateWithAdditional5Minutes.toString());

        CustomDialog(
          context: context,
          title: 'Info'.tr(),
          message: 'A new verification message has been sent. Please check it'.tr(),
          okButtonTitle: 'Ok'.tr(),
          cancelButtonTitle: 'Cancel'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(context);
          },
          onPressedOkButton: () {
            Navigator.pop(context);
          },
          color: Color(0xFFFFB300),
          icon: "assets/images/warning.svg",
        ).showCustomDialog();
        return true;
      }
    }

    setState(() => canResendVerificationCode = true);
  }

  checkTimeToAllowResendVerificationCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? registeringInAppTime =
        prefs.getString(Constants.keyRegisteringMinutiesTime);
    if (registeringInAppTime != null) {
      int difference = DateTime.now()
          .difference(DateTime.parse(registeringInAppTime))
          .inMinutes;
      if (difference.abs() <= 2) {
        setState(() => canResendVerificationCode = false);
      }
    }
  }
}
