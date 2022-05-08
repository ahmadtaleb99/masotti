import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import 'dart:convert';
import './login.dart';
import '../constants.dart';
import '../widgets/text_field.dart';
import '../widgets/alert_dialog.dart';
import '../models/customer.dart';

class ResetPasswordPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => ResetPasswordPageState();
}

class ResetPasswordPageState extends State<ResetPasswordPage>{
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool arabicLanguage = false;
  int isLoading = 0;
  String emptySelectedGender = ' ';
  String confirmPasswordError = ' ';
  Customer customer = Customer();
  
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageWidth = containerWidth;
    arabicLanguage = Localizations.localeOf(context).languageCode == 'ar' ? true : false;  
    return Scaffold(
      backgroundColor: Constants.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: Constants.doublePadding, top: Constants.padding * 4),
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
              padding: EdgeInsets.only(right: Constants.doublePadding, left: Constants.doublePadding),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: Constants.padding),
                    child: AutoSizeText(
                      'Please enter your reset password code and the new password'.tr(),
                      style: TextStyle(
                        color: Constants.identityColor
                      ),
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
                          label: 'Reset Password Code',
                          icon: MyFlutterApp.mobile_phone,
                          onSaved: (value) => customer.resetPasswordCode = value,
                          isRequired: true,
                          isCode: true,
                        ),
                        SizedBox(height: 15),
                        CustomTextField(
                          label: 'Password',
                          icon: MyFlutterApp.subtraction_1,
                          onSaved: (value) => customer.password= value,
                          onChanged: (value) => customer.password = value,
                          isRequired: true,
                          isPassword: true,
                        ),
                        SizedBox(height: 15),
                        CustomTextField(
                          label: 'Confirm Password',
                          icon: MyFlutterApp.padlock,
                          onSaved: (value) => customer.confirmPassword= value,
                          onChanged: (value) => customer.confirmPassword = value,
                          isRequired: true,
                          isPassword: true,
                        ),
                        Container(
                          padding: EdgeInsets.only(left: Constants.padding, right: Constants.padding, top: confirmPasswordError != ' ' ? 5 : 0),
                          child: Text(
                            confirmPasswordError,
                            style: TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: Constants.padding),
                          alignment: Alignment.center,
                          child: ButtonTheme(
                            minWidth: containerWidth / 3 * 2,
                            height: 50,
                            child: RaisedButton(
                              elevation: 5,
                              padding: EdgeInsets.symmetric(vertical: Constants.buttonsVerticalPadding),
                              color: Constants.redColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Constants.borderRadius)
                              ),
                              child: AutoSizeText(
                                'Reset Password'.tr(),
                                style: TextStyle(
                                  color: Constants.whiteColor,
                                  fontWeight: FontWeight.bold
                                ),
                                maxFontSize: Constants.fontSize,
                                minFontSize: Constants.fontSize - 2,
                              ),
                              onPressed: isLoading == 1 ? null : (){
                                bool checkPassword = customer.password == customer.confirmPassword;
                                if(_formKey.currentState!.validate() && checkPassword){
                                  _formKey.currentState!.save();
                                  resetPassword(customer);
                                }
                                else{
                                  setState(() {
                                    confirmPasswordError = ! checkPassword ? 'Confirm password must match password'.tr() : ' ';
                                    _formKey.currentState!.setState(() => false);
                                  });
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  resetPassword(Customer customer) async {
    setState(() {
      confirmPasswordError = ' ';
      isLoading = 1;
    });

    final String url = 'reset-password';
    final response = await http.post(Uri.parse(Constants.apiUrl + url), body: customer.toJson(), headers: {
      'referer': Constants.apiReferer
    });

    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      if(data['status']){
        CustomDialog(
          context: context,
          title: 'Successful..'.tr(),
          message: 'The password has been reset successfully'.tr(),
          okButtonTitle: 'Login'.tr(),
          cancelButtonTitle: 'Ok'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(context);
          },
          onPressedOkButton: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => LoginPage()
            ));
          },
          color: Constants.greenColor,
          icon: "assets/images/correct.svg",
        ).showCustomDialog();
      }
      else{
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

    setState(() => isLoading = 0);
    return Constants.requestErrorMessage;
  }
}