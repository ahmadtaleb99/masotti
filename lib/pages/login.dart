import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/services/DialogService.dart';
import 'package:masotti/services/DialogService.dart';
import 'package:masotti/services/networking/network_helper.dart';
import '../services/DialogService.dart';
import 'package:masotti/utils.dart';
import 'package:masotti/widgets/colored_circular_progress_indicator.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import '../pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'dart:convert';
import './verify_account.dart';
import 'forgot_password.dart';
import '../widgets/alert_dialog.dart';
import '../pages/signup.dart';
import '../constants.dart';
import 'package:masotti/main.dart';
import '../widgets/text_field.dart';

class LoginPage extends StatefulWidget {
  bool redirectToCartPage = false;

  LoginPage();

  LoginPage.withRedirect({required this.redirectToCartPage});

  @override
  State<StatefulWidget> createState() => this.redirectToCartPage != true
      ? LoginPageState()
      : LoginPageState.withRedirect(redirectToCartPage: true);
}

class LoginPageState extends State<LoginPage> {
  bool redirectToCartPage = false;

  LoginPageState();

  LoginPageState.withRedirect({required this.redirectToCartPage});

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var authenticationData = {};
  int isLoading = 0;
  bool arabicLanguage = false;
  bool notVerifiedAccount = false;
  String? notVerifiedAccountMobile = '';

  checkIfThereNotVerifiedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    bool? accountStatus = prefs.getBool(Constants.keyNotVerifiedAccount);
    if (accountStatus != null && accountStatus) {
      setState(() {
        notVerifiedAccount = true;
        notVerifiedAccountMobile =
            prefs.getString(Constants.keyNotVerifiedAccountMobile);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfThereNotVerifiedAccount();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageWidth = containerWidth;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                  left: Constants.doublePadding,
                  top: Constants.padding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTextField(
                      label: 'Mobile Phone',
                      onSaved: (value) => authenticationData['phone'] = value,
                      isRequired: true,
                      isPhone: true,
                      icon: MyFlutterApp.mobile_phone,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      label: 'Password',
                      onSaved: (value) =>
                          authenticationData['password'] = value,
                      isRequired: true,
                      isPassword: true,
                      textInputAction: TextInputAction.go,
                      icon: MyFlutterApp.padlock,
                      onSubmit: (_) {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          login(authenticationData,context);
                        }
                      },
                    ),
                    Container(
                      padding: EdgeInsets.only(top: Constants.padding),
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage())),
                        child: AutoSizeText(
                          'Forgot Password?'.tr(),
                          style: TextStyle(
                            color: Constants.greyColor,
                          ),
                          maxFontSize: Constants.fontSize - 2,
                          minFontSize: Constants.fontSize - 4,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: Constants.doublePadding),
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: containerWidth / 2,
                        height: 50,
                        child: RaisedButton(
                          elevation: 5,
                          color: Constants.redColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Constants.borderRadius)),
                          child: AutoSizeText(
                            'Login'.tr(),
                            style: TextStyle(
                              color: Constants.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxFontSize: Constants.fontSize,
                            minFontSize: Constants.fontSize - 2,
                          ),
                          onPressed: isLoading == 1
                              ? null
                              : () {
                            FocusScope.of(context).unfocus();
                            if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    login(authenticationData,context);
                                  }
                                },
                        ),
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: Constants.padding / 2),
                        alignment: Alignment.center,
                        child: Text(
                          'Or'.tr(),
                          style: TextStyle(
                              color: Constants.identityColor,
                              fontSize: Constants.fontSizeOnSmallScreens,
                              fontWeight: FontWeight.bold),
                        )),
                    notVerifiedAccount
                        ? Container(
                            margin: EdgeInsets.only(top: Constants.padding / 2),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  VerifyAccountPage(
                                                    phoneNumber:
                                                        notVerifiedAccountMobile,
                                                  )));
                                    },
                                    child: AutoSizeText(
                                      'Click here to verify your account'.tr(),
                                      style: TextStyle(
                                        color: Constants.redColor,
                                      ),
                                      maxFontSize: Constants.fontSize - 4,
                                      minFontSize: Constants.fontSize - 6,
                                    ),
                                  ),
                                ]),
                          )
                        : Container(),
                    Container(
                      padding: EdgeInsets.only(top: Constants.padding / 2),
                      alignment: Alignment.center,
                      child: ButtonTheme(
                        minWidth: containerWidth / 2,
                        height: 50,
                        child: RaisedButton(
                          elevation: 5,
                          color: Constants.identityColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Constants.borderRadius)),
                          child: AutoSizeText(
                            'Skip / Continue'.tr(),
                            style: TextStyle(
                              color: Constants.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxFontSize: Constants.fontSize,
                            minFontSize: Constants.fontSize - 2,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SplashScreen()));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                padding: EdgeInsets.only(
                    top: Constants.padding, bottom: Constants.doublePadding),
                width: devicePixelRatio > 1.2
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 3 * 2,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupPage()));
                          },
                          child: Row(
                            children: [
                              AutoSizeText(
                                "Don't have account? ".tr(),
                                style: TextStyle(
                                  color: Constants.greyColor,
                                ),
                                maxFontSize: Constants.fontSize - 2,
                                minFontSize: Constants.fontSize - 4,
                              ),
                              AutoSizeText(
                                'Create Now!'.tr(),
                                style: TextStyle(
                                  color: Constants.redColor,
                                ),
                                maxFontSize: Constants.fontSize - 2,
                                minFontSize: Constants.fontSize - 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
  void showLoadingIndicator({String ? text,required BuildContext  contexts}) {
showDialog(barrierDismissible :false , context: contexts, builder: (context){
  return         Center(
    child: Container(
      width: 110,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        color: Colors.white.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               ColoredCircularProgressIndicator(),
              const SizedBox(
                height: 10,
              ),
              AutoSizeText(
                text ?? 'Please Wait'.tr() ,
                style: TextStyle(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxFontSize: Constants.fontSize,
                minFontSize: Constants.fontSize - 2,
              )
            ],
          ),
        ),
      ),
    ),
  );

});

  }

  resendVerificationSms(phone) async {
    final String url = 'resend-verification-sms';

    final data =await  NetworkingHelper.postData(url, body: {'phone': phone});


      if (data['status']) {
        CustomDialog(
          context: context,
          title: 'Info'.tr(),
          message:
              'A new verification message has been sent. Please check it'.tr(),
          okButtonTitle: 'Verify Account'.tr(),
          cancelButtonTitle: 'Ok'.tr(),
          onPressedOkButton: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyAccountPage(
                          phoneNumber: phone,
                        )));
          },
          color: Color(0xFFFFB300),
          icon: "assets/images/warning.svg",
        ).showCustomDialog();
      }
  }

  Future<void> login(var credentials, BuildContext loginContext) async {
    var _loadingDialog = LoadingService.instance;
    _loadingDialog.show(context, msg: 'Please Wait'.tr());

    try {
      setState(() => isLoading = 1);
      final String url = 'login-customer';
      // final FirebaseMessaging fcm = FirebaseMessaging.instance;
      // final tokenResponse = await (fcm.getToken() as Future<String?>);
      // credentials['device_token'] =
      // tokenResponse != null ? tokenResponse : null;



      final data = await NetworkingHelper.postData( url, body: credentials);
      if (data['status']) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(Constants.keyAccessToken, data['token']);
        prefs.setBool(Constants.keyAccountStatus,
            data['account_status'] == 'Active' ? true : false);
        if (redirectToCartPage == true) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SplashScreen()),
                  (Route<dynamic> route) => false);
        }
      } else if (data['message'] == 'Wrong Credentials') {
        CustomDialog(
          context: context,
          title: 'Wrong Credentials'.tr(),
          message: 'You have entered wrong mobile phone or password!'.tr(),
          okButtonTitle: 'Ok'.tr(),

          onPressedOkButton: () {
            Navigator.pop(loginContext);
          },
          color: Constants.redColor,
          icon: "assets/images/wrong.svg",
        ).showCustomDialog();
      } else if (data['message'] == 'Account Not Confirmed') {
        CustomDialog(
          context: loginContext,
          title: 'Confirmation Account Required'.tr(),
          message: 'You must confirm your account in order to login'.tr(),
          okButtonTitle: 'Verify Account'.tr(),
          cancelButtonTitle: 'Ok'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(loginContext);
          },
          onPressedOkButton: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        VerifyAccountPage(
                          phoneNumber: credentials['phone'],
                        )));
          },
          color: Color(0xFFFFB300),
          icon: "assets/images/warning.svg",
        ).showCustomDialog();
      }
    else if (data['message'] == 'Wrong Credentials') {
    CustomDialog(
    context: context,
    title: 'Wrong Credentials'.tr(),
    message: 'You have entered wrong mobile phone or password!'.tr(),
    okButtonTitle: 'Ok'.tr(),

    onPressedOkButton: () {
    Navigator.pop(loginContext);
    },
    color: Constants.redColor,
    icon: "assets/images/wrong.svg",
    ).showCustomDialog();
    } else if (data['message'] == 'Account Not Confirmed') {
    CustomDialog(
    context: loginContext,
    title: 'Confirmation Account Required'.tr(),
    message: 'You must confirm your account in order to login'.tr(),
    okButtonTitle: 'Verify Account'.tr(),
    cancelButtonTitle: 'Ok'.tr(),
    onPressedCancelButton: () {
    Navigator.pop(loginContext);
    },
    onPressedOkButton: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => VerifyAccountPage(
    phoneNumber: credentials['phone'],
    )));
    },
    color: Color(0xFFFFB300),
    icon: "assets/images/warning.svg",
    ).showCustomDialog();
    } }on TimeoutException {
        showInternetErrorDialog(context);
      } catch (e) {
      print(e);
        print('socket');
        showInternetErrorDialog(context);
      }
      finally {
        setState(() => isLoading = 0);
      }
    _loadingDialog.hide();

  }
  }