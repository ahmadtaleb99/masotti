import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/text_field.dart';
import '../widgets/alert_dialog.dart';
import '../models/customer.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool arabicLanguage = false;
  int isLoading = 0;
  String emptySelectedGender = ' ';
  String confirmPasswordError = ' ';
  Customer customer = Customer();
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
    double imageWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding * 2);
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Change Password',
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: true,
      ),
      drawer: SideMenu(),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(Constants.borderRadius * 2),
            topLeft: Radius.circular(Constants.borderRadius * 2)),
        child: Container(
          color: Constants.whiteColor,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(
                  right: Constants.doublePadding,
                  left: Constants.doublePadding,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          bottom: Constants.padding, top: Constants.padding),
                      width: imageWidth,
                      height: imageWidth * 47.2 / 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Constants.logoImage),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomTextField(
                            label: 'Old Password',
                            onSaved: (value) => customer.oldPassword = value,
                            isRequired: true,
                            isPassword: true,
                            icon: MyFlutterApp.subtraction_1,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: 'Password',
                            onSaved: (value) => customer.password = value,
                            onChanged: (value) => customer.password = value,
                            isRequired: true,
                            isPassword: true,
                            icon: MyFlutterApp.subtraction_1,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: 'Confirm Password',
                            onSaved: (value) =>
                                customer.confirmPassword = value,
                            onChanged: (value) =>
                                customer.confirmPassword = value,
                            isRequired: true,
                            isPassword: true,
                            icon: MyFlutterApp.padlock,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: Constants.padding,
                                right: Constants.padding,
                                top: confirmPasswordError != ' ' ? 5 : 0),
                            child: Text(
                              confirmPasswordError,
                              style: TextStyle(
                                  color: Colors.redAccent.shade700,
                                  fontSize: 12.0),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: Constants.padding),
                            alignment: Alignment.center,
                            child: ButtonTheme(
                              minWidth: containerWidth / 2,
                              height: 50,
                              child: RaisedButton(
                                padding: EdgeInsets.symmetric(
                                    vertical: Constants.buttonsVerticalPadding),
                                color: Constants.redColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Constants.borderRadius)),
                                child: AutoSizeText(
                                  'Change Password'.tr(),
                                  style: TextStyle(
                                      color: Constants.whiteColor,
                                      fontWeight: FontWeight.bold),
                                  maxFontSize: Constants.fontSize,
                                  minFontSize: Constants.fontSize - 2,
                                ),
                                onPressed: isLoading == 1
                                    ? null
                                    : () {
                                        bool checkPassword =
                                            customer.password ==
                                                customer.confirmPassword;
                                        if (_formKey.currentState!.validate() &&
                                            checkPassword) {
                                          _formKey.currentState!.save();
                                          changePassword(customer);
                                        } else {
                                          setState(() {
                                            confirmPasswordError = !checkPassword
                                                ? 'Confirm password must match password'
                                                    .tr()
                                                : ' ';
                                            _formKey.currentState!
                                                .setState(() => false);
                                          });
                                        }
                                      },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  changePassword(Customer customer) async {
    setState(() {
      confirmPasswordError = ' ';
      isLoading = 1;
    });

    final String url = 'change-password';
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(Constants.keyAccessToken);

    if (accessToken != null) {
      final response = await http.post( Uri.parse(Constants.apiUrl + url) ,
          body: customer.toJson(),
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
        } else if (data['message'].toString() == 'Incorrect old password') {
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

    setState(() => isLoading = 0);
    return Constants.requestErrorMessage;
  }
}
