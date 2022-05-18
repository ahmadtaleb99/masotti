import 'dart:developer';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/models/city.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/flutter_custom_icons.dart';
import '../assets/my_flutter_app_icons.dart';
import 'dart:convert';
import './my_addresses.dart';
import '../widgets/request_empty_data.dart';
import '../constants.dart';
import '../models/address_ios.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/text_field.dart';
import '../widgets/alert_dialog.dart';

class UpdateAddressIOS extends StatefulWidget {
  final String id;

  UpdateAddressIOS({required this.id});

  @override
  State<StatefulWidget> createState() {
    return UpdateAddressIOSState(id: this.id);
  }
}

class UpdateAddressIOSState extends State<UpdateAddressIOS> {
  final String id;
  AsyncMemoizer memoizer = AsyncMemoizer();

  UpdateAddressIOSState({required this.id});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Address address;
  bool arabicLanguage = false;
  int isLoading = 0;
  int? itemsInCart = 0;

  @override
  void initState() {
    super.initState();
    address = Address();
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
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
        backgroundColor: Constants.identityColor,
        appBar: CustomAppBarWidget(
          title: 'Update Address',
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
              padding: EdgeInsets.only(
                  right: Constants.padding,
                  left: Constants.padding,
                  top: Constants.padding),
              child: FutureBuilder(
                future: getAddress(id),
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
                  Address addressResponse = response as Address;
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: Constants.halfPadding, vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                CustomTextField(
                                  label: 'Address Name',
                                  icon: MyFlutterApp.adress_icons_address_name2,
                                  iconSize: 60,
                                  onSaved: (value) => address.name = value,
                                  isRequired: true,
                                  initialValue: addressResponse.name
                                ),
                                SizedBox(height: 15),
                                CustomTextField(
                                  label: 'City'.tr(),
                                  icon: MyFlutterApp.adress_icons_city2,
                                  iconSize: 50,
                                  onSaved: (value) => address.city = value,
                                  isRequired: true,
                                  initialValue: addressResponse.city,
                                ),
                                SizedBox(height: 15),
                                CustomTextField(
                                  label: 'District',
                                  icon: MyFlutterApp.adress_icons_district2,
                                  iconSize: 60,
                                  onSaved: (value) => address.district = value,
                                  isRequired: true,
                                  initialValue: addressResponse.district,
                                ),
                                SizedBox(height: 15),
                                CustomTextField(
                                  label: 'Street',
                                  icon: MyFlutterApp.adress_icons_street2,
                                  iconSize: 60,
                                  onSaved: (value) => address.street = value,
                                  isRequired: true,
                                  initialValue: addressResponse.street,
                                ),
                                SizedBox(height: 15),
                                CustomTextField(
                                  label: 'Building',
                                  icon: MyFlutterApp.adress_icons_building2,
                                  iconSize: 60,
                                  onSaved: (value) => address.building = value,
                                  isRequired: true,
                                  initialValue: addressResponse.building,
                                ),
                                SizedBox(height: 15),
                                CustomTextField(
                                  label: 'Home',
                                  icon: MyFlutterApp.adress_icons_home2,
                                  iconSize: 60,
                                  onSaved: (value) => address.home = value,
                                  isRequired: true,
                                  initialValue: addressResponse.home,
                                ),
                                SizedBox(height: 15),
                                CustomTextField(
                                  label: 'Floor',
                                  icon: MyFlutterApp.adress_icons_floor2,
                                  iconSize: 60,
                                  onSaved: (value) => address.floor = value,
                                  isRequired: true,
                                  initialValue: addressResponse.floor,
                                ),
                                SizedBox(height: 15),
                                Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              Constants.borderRadius))),
                                  margin: EdgeInsets.zero,
                                  child: Center(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Details'.tr(),
                                        contentPadding: EdgeInsets.all(15),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                      onSaved: (value) =>
                                          address.details = value,
                                      initialValue: addressResponse.details,
                                      onFieldSubmitted: (_) {
                                        if (_formKey.currentState!.validate()) {
                                          _formKey.currentState!.save();
                                          updateAddress(id);
                                        }
                                      },
                                      maxLines: 4,
                                      minLines: 4,
                                      maxLength: 100,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.only(top: Constants.padding),
                                  margin: EdgeInsets.only(
                                      bottom: Constants.padding),
                                  alignment: Alignment.center,
                                  child: ButtonTheme(
                                    minWidth:
                                        MediaQuery.of(context).size.width /
                                            3 *
                                            2,
                                    height: 50,
                                    child: RaisedButton(
                                      elevation: 5,
                                      color: Constants.redColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Constants.borderRadius)),
                                      child: AutoSizeText(
                                        'Update Address'.tr(),
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
                                                updateAddress(id);
                                              }
                                            },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              )),
        ));
  }

  getAddress(String addressId) async {
    return memoizer.runOnce(() async {
      final String url = 'get-address?address_id=$addressId';

      final response = await http.get(Uri.parse(Constants.apiUrl + url),
          headers: {'referer': Constants.apiReferer});
      print('here1');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'];

          log(response.body);
          String cityName = data['city_name'];
          print('here2');
          print('here3');



          Address addressResult = Address.getAddressFromData(data, cityName);

          // City city = City(
          //     id: int.parse(data['city_id'].toString()),
          //     name: cityName
          // );
          // selectedCity = cities.firstWhere((city) => city.id == addressResult.city.id && city.name == addressResult.city.name);
          return addressResult;
        }
      }
      return Constants.requestErrorMessage;
    });
  }

  updateAddress(String addressId) async {
    setState(() => isLoading = 1);

    final String url = 'update-address?address_id=$addressId';
    // address.city = address.city != null ? address.city : selectedCity;
    print('add_address: ' + address.toJson().toString());
    final response = await http.post(Uri.parse(Constants.apiUrl + url),
        body: address.toJson(), headers: {'referer': Constants.apiReferer});
    log(response.body);

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
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => MyAddressesPage()));
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
  }
}
