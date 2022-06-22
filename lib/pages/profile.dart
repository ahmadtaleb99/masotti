import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:async/async.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/widgets/custom_dialog.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import './change_password.dart';
import '../widgets/request_empty_data.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/text_field.dart';
import '../widgets/alert_dialog.dart';
import '../models/customer.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AsyncMemoizer memoizer = AsyncMemoizer();
  bool arabicLanguage = false;
  int isLoading = 0;
  String? selectedGender;
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
        title: 'Profile',
        currentContext: context,
        itemsInCart: itemsInCart,
        showBackButton:  true,
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
              child: Container(
                margin: EdgeInsets.only(
                    bottom: Constants.padding, top: Constants.padding),
                padding: EdgeInsets.only(
                  right: Constants.doublePadding,
                  left: Constants.doublePadding,
                ),
                child: FutureBuilder(
                    future: getCustomerInfo(),
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
                      Customer customer = response as Customer;
                      return Column(children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: Constants.padding),
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
                                label: 'First Name',
                                onSaved: (value) => customer.firstName = value,
                                isRequired: true,
                                initialValue: customer.firstName,
                                icon: MyFlutterApp.group_210,
                              ),
                              SizedBox(height: 15),
                              CustomTextField(
                                label: 'Last Name',
                                onSaved: (value) => customer.lastName = value,
                                isRequired: true,
                                initialValue: customer.lastName,
                                icon: MyFlutterApp.group_210,
                              ),
                              SizedBox(height: 15),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(Constants.borderRadius))),
                                margin: EdgeInsets.zero,
                                child: Center(
                                  child:  DateTimeField(
                                    decoration: InputDecoration(
                                      hintText: 'Birth Date'.tr(),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                        top: 20,
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
                                    initialValue:
                                        customer.birthDate != null ?
                                        DateTime.parse(customer.birthDate!) : null,
                                    format: DateFormat('yyyy-MM-dd'),
                                    onShowPicker: (context, value) async {
                                      final date =
                                          await DatePicker.showDatePicker(context,
                                              theme: DatePickerTheme(
                                                  containerHeight: 210.0,
                                                  itemStyle: TextStyle(
                                                      fontFamily: 'Tajawal')  ,
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
                                                      DateTime.now().year - 10,
                                                      1,
                                                      1),
                                              locale: arabicLanguage
                                                  ? LocaleType.ar
                                                  : LocaleType.en);
                                      return date;
                                    },
                                  ) ,
                                ),
                              ),
                     Container(
                                padding:
                                    EdgeInsets.only(bottom: Constants.padding),
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
                                          hint: Text(
                                            'Gender'.tr(),
                                            style: TextStyle(
                                                color: Constants.identityColor,
                                                fontFamily: 'Tajawal',
                                                fontSize: Constants.fontSize,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          style: TextStyle(
                                              fontFamily: 'Tajawal',
                                              color: Constants.identityColor,
                                              fontSize: Constants.fontSize,
                                              fontWeight: FontWeight.bold),
                                          isExpanded: false,
                                          iconEnabledColor:
                                              Constants.identityColor,
                                          disabledHint: Text('select'),

                                          value: selectedGender?.tr()  ,
                                          items: [
                                            'Male'.tr(),
                                            'Female'.tr(),
                                          ].map((String gender) {
                                            return DropdownMenuItem<String>(
                                                value: gender,
                                                child: Text(
                                                  gender,
                                                  style: TextStyle(
                                                      fontFamily: 'Tajawal',
                                                      color:
                                                          Constants.identityColor,
                                                      fontSize:
                                                          Constants.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ));
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedGender = value;
                                              customer.gender = value;
                                            });
                                          },
                                        ))),
                              ) ,
                              Container(
                                padding: EdgeInsets.only(top: Constants.padding),
                                alignment: Alignment.center,
                                child: ButtonTheme(
                                  minWidth: containerWidth / 2,
                                  height: 50,
                                  child: RaisedButton(
                                    padding: EdgeInsets.symmetric(
                                        vertical:
                                            Constants.buttonsVerticalPadding),
                                    color: Constants.redColor,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Constants.borderRadius)),
                                    child: AutoSizeText(
                                      'Update'.tr(),
                                      style: TextStyle(
                                          color: Constants.whiteColor,
                                          fontWeight: FontWeight.bold),
                                      maxFontSize: Constants.fontSize,
                                      minFontSize: Constants.fontSize - 2,
                                    ),
                                    onPressed: isLoading == 1
                                        ? null
                                        : () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              _formKey.currentState!.save();
                                              updateCustomerInfo(customer);
                                            }
                                          },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: Constants.doublePadding,
                              bottom: Constants.doublePadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ChangePasswordPage()));
                                },
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      '<<',
                                      style: TextStyle(
                                        color: Constants.redColor,
                                      ),
                                      maxFontSize: Constants.fontSize - 2,
                                      minFontSize: Constants.fontSize - 4,
                                    ),
                                    AutoSizeText(
                                      'Change Password'.tr(),
                                      style: TextStyle(
                                          color: Constants.redColor,
                                          decoration: TextDecoration.underline,
                                          decorationThickness: 1),
                                      maxFontSize: Constants.fontSize - 2,
                                      minFontSize: Constants.fontSize - 4,
                                    ),
                                    AutoSizeText(
                                      '>>',
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
                      ]);
                    }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getCustomerInfo() async {
    return memoizer.runOnce(() async {
      final String url = 'get-customer-info';
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString(Constants.keyAccessToken);

      if (accessToken != null) {
        log('access token : $accessToken');

        final response = await http.get(Uri.parse(Constants.apiUrl + url), headers: {
          'Authorization': 'Bearer ' + accessToken,
          'referer': Constants.apiReferer
        });

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          if (data['status']) {
            data = data['data'];
            Customer customer = Customer.getCustomerFromData(data);
            log(customer.toString());
            selectedGender = customer.gender;
            return customer;
          }
        }
      }
      return Constants.requestErrorMessage;
    });
  }

  updateCustomerInfo(Customer customer) async {
    setState(() => isLoading = 1);

    final String url = 'update-customer-info';
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(Constants.keyAccessToken);

    if (accessToken != null) {
      final response = await http.post(Uri.parse(Constants.apiUrl + url),
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
      setState(() => isLoading = 0);
      return Constants.requestErrorMessage;
    }
  }
}
