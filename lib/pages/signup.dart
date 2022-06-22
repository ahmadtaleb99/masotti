import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../widgets/text_field.dart';
import '../models/customer.dart';
import './login.dart';
import './verify_account.dart';
import '../widgets/alert_dialog.dart';

class SignupPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SignupPageState();
  }
}

class SignupPageState extends State<SignupPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Customer customer;
  String? selectedGender;
  String emptySelectedGender = ' ';
  String confirmPasswordError = ' ';
  int isLoading = 0;
  bool arabicLanguage = false;

  @override
  void initState() {
    super.initState();
    customer = Customer();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageWidth = containerWidth;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: BackButton(
            color: Constants.identityColor,
          ),
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Constants.whiteColor,
        body: SingleChildScrollView(
            padding: EdgeInsets.only(
                right: Constants.padding, left: Constants.padding),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: Constants.doublePadding,
                      top: Constants.padding * 4),
                  width: imageWidth,
                  height: imageWidth * 47.2 / 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Constants.logoImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Column(children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        right: Constants.padding, left: Constants.padding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CustomTextField(
                            label: 'First Name',
                            icon: MyFlutterApp.group_210,
                            onSaved: (value) => customer.firstName = value,
                            isRequired: true,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: 'Last Name',
                            icon: MyFlutterApp.group_210,
                            onSaved: (value) => customer.lastName = value,
                            isRequired: true,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: 'Password',
                            icon: MyFlutterApp.subtraction_1,
                            onSaved: (value) => customer.password = value,
                            onChanged: (value) => customer.password = value,
                            isRequired: true,
                            isPassword: true,
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: 'Confirm Password',
                            icon: MyFlutterApp.padlock,
                            onSaved: (value) =>
                                customer.confirmPassword = value,
                            onChanged: (value) =>
                                customer.confirmPassword = value,
                            isRequired: true,
                            isPassword: true,
                          ),
                          confirmPasswordError != ' '
                              ? Container(
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
                                )
                              : Container(),
                          SizedBox(height: 15),
                          CustomTextField(
                            label: 'Mobile Phone',
                            icon: MyFlutterApp.mobile_phone,
                            onSaved: (value) => customer.mobilePhone = value,
                            isRequired: true,
                            isPhone: true,
                          ),
                          SizedBox(height: 15),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(Constants.borderRadius))),
                            margin: EdgeInsets.zero,
                            child: Center(
                              child: DateTimeField(
                                decoration: InputDecoration(
                                  hintText: 'Birth Date'.tr(),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    top: 20, // HERE THE IMPORTANT PART
                                  ),
                                  prefixIcon: Card(
                                    elevation: 3,
                                    margin: arabicLanguage
                                        ? EdgeInsets.only(left: 10)
                                        : EdgeInsets.only(right: 10),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                Constants.borderRadius))),
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      child: Icon(
                                        MyFlutterApp.page_1,
                                        color: Constants.redColor,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  // return value == null
                                  //     ? 'Birth Date can\'t be empty'
                                  //     : null;
                                },
                                format: DateFormat('yyyy-MM-dd'),
                                onShowPicker: (context, value) async {
                                  final date = await DatePicker.showDatePicker(
                                      context,
                                      theme: DatePickerTheme(
                                          containerHeight: 210.0,
                                          itemStyle:
                                              TextStyle(fontFamily: 'Tajawal'),
                                          cancelStyle: TextStyle(
                                              color: Constants.linkColor,
                                              fontFamily: 'Tajawal'),
                                          doneStyle: TextStyle(
                                              color: Constants.linkColor,
                                              fontFamily: 'Tajawal')),
                                      showTitleActions: true,
                                      minTime: DateTime(1900, 1, 1),
                                      maxTime: DateTime(
                                          DateTime.now().year - 5, 1, 1),
                                      onConfirm: (date) {
                                    customer.birthDate = date.toString();
                                    setState(() {});
                                  },
                                      currentTime: value ??
                                          DateTime(
                                              DateTime.now().year - 10, 1, 1),
                                      locale: arabicLanguage
                                          ? LocaleType.ar
                                          : LocaleType.en);
                                  return date;
                                },
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: Constants.padding),
                            child: DropdownButtonHideUnderline(
                                child: Container(
                                    padding: EdgeInsets.only(
                                      top: Constants.halfPadding,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              Constants.borderRadius)),
                                    ),
                                    child: DropdownButton<String>(
                                      icon: Container(
                                        margin: EdgeInsets.all(5),
                                        alignment: Alignment.topCenter,
                                        child: Icon(
                                          MyFlutterApp.group_218,
                                          size: 8,
                                        ),
                                      ),
                                      style: TextStyle(
                                          color: Constants.identityColor,
                                          fontFamily: 'Tajawal'),
                                      isExpanded: false,
                                      iconEnabledColor: Constants.identityColor,
                                      hint: Text(
                                        'Select Gender'.tr(),
                                        style: TextStyle(
                                            color: Constants.identityColor,
                                            fontFamily: 'Tajawal',
                                            fontSize: Constants.fontSize,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      value: selectedGender,
                                      items: [
                                        'Male'.tr(),
                                        'Female'.tr(),
                                      ].map((String gender) {
                                        return DropdownMenuItem<String>(
                                            value: gender,
                                            child: Text(
                                              gender,
                                              style: TextStyle(
                                                  color:
                                                      Constants.identityColor,
                                                  fontFamily: 'Tajawal',
                                                  fontSize: Constants.fontSize,
                                                  fontWeight: FontWeight.bold),
                                            ));
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedGender = value;
                                          customer.gender = value;
                                          emptySelectedGender = ' ';
                                        });
                                      },
                                    ))),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: Constants.padding,
                                right: Constants.padding,
                                top: emptySelectedGender != ' ' ? 5 : 0),
                            child: Text(
                              emptySelectedGender,
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
                                elevation: 5,
                                color: Constants.redColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Constants.borderRadius)),
                                child: AutoSizeText(
                                  'Signup'.tr(),
                                  style: TextStyle(
                                    color: Constants.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                            // selectedGender != null &&
                                            checkPassword) {
                                          _formKey.currentState!.save();
                                          log('here');
                                          signup(customer);
                                        } else if (
                                            !checkPassword) {
                                          setState(() {
                                            // if (selectedGender == null) {
                                            //   emptySelectedGender =
                                            //       'Gender can\'t be empty'.tr();
                                            // }
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
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: Constants.padding,
                        bottom: Constants.doublePadding),
                    width: containerWidth / 3 * 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          },
                          child: Row(
                            children: [
                              AutoSizeText(
                                'Already have account? '.tr(),
                                style: TextStyle(
                                  color: Constants.identityColor,
                                ),
                                maxFontSize: Constants.fontSize - 2,
                                minFontSize: Constants.fontSize - 4,
                              ),
                              AutoSizeText(
                                'Sign in'.tr(),
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
                  )
                ]),
              ],
            )));
  }

  Future<void> signup(Customer customer) async {
    setState(() {
      confirmPasswordError = ' ';
      isLoading = 1;
    });

    final String url = 'signup-customer';
    final response = await http.post(Uri.parse(Constants.apiUrl + url),
        body: customer.toJson(), headers: {'referer': Constants.apiReferer});

    setState(() => isLoading = 0);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        // Save the time in order to detect the available time to resend verification code
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(
            Constants.keyRegisteringMinutiesTime, DateTime.now().toString());
        prefs.setBool(Constants.keyNotVerifiedAccount, true);
        prefs.setString(Constants.keyNotVerifiedAccountMobile,
            customer.mobilePhone.toString());

        CustomDialog(
          context: context,
          title: 'Welcome'.tr(),
          message: 'Signup confirmation account message'.tr(),
          okButtonTitle: 'Verify Account'.tr(),
          cancelButtonTitle: 'Ok'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(context);
          },
          onPressedOkButton: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerifyAccountPage(
                          phoneNumber: customer.mobilePhone,
                        )));
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
