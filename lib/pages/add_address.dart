import 'package:async/async.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:masotti/services/DialogService.dart';
import 'package:masotti/services/networking.dart';
import 'package:masotti/utils.dart';
import 'package:masotti/widgets/colored_circular_progress_indicator.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../assets/flutter_custom_icons.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cart.dart';
import '../widgets/request_empty_data.dart';
import './my_addresses.dart';
import '../constants.dart';
import '../models/city.dart';
import '../models/address.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/text_field.dart';
import '../widgets/alert_dialog.dart';

class AddAddress extends StatefulWidget {
  bool redirectToCartPage = false;

  AddAddress();

  AddAddress.withRedirect({required this.redirectToCartPage});

  @override
  State<StatefulWidget> createState() => this.redirectToCartPage != true
      ? AddAddressState()
      : AddAddressState.withRedirect(redirectToCartPage: true);
}

class AddAddressState extends State<AddAddress> {
  bool redirectToCartPage = false;

  AddAddressState();

  AddAddressState.withRedirect({required this.redirectToCartPage});

  AsyncMemoizer memoizer = AsyncMemoizer();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Address address;
  City? selectedCity;
  String emptySelectedCity = ' ';
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
        title: 'Add Address',
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
            future: getCities(),
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
              List<City> cities = response as List<City>;
              return Container(
                color: Constants.whiteColor,
                height: double.infinity,
                child: SingleChildScrollView(
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
                              DropdownButtonHideUnderline(
                                  child: Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: Constants.halfPadding),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            Constants.borderRadius * 3))),
                                child: Center(
                                    child: Container(
                                        padding: EdgeInsets.only(
                                            left: Constants.padding,
                                            right: Constants.padding),
                                        child: DropdownButton<City>(
                                          iconSize: 30,
                                          style: TextStyle(
                                              color: Constants.identityColor),
                                          isExpanded: true,
                                          iconEnabledColor:
                                              Constants.identityColor,
                                          hint: Text(
                                            'Select City'.tr(),
                                            style: TextStyle(
                                                color: Constants.identityColor,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Tajawal',
                                                fontSize:
                                                    Constants.fontSize - 4),
                                          ),
                                          value: selectedCity,
                                          items: cities.map((City city) {
                                            return DropdownMenuItem<City>(
                                              value: city,
                                              child: Text(
                                                city.name!,
                                                style: TextStyle(
                                                    color:
                                                        Constants.identityColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Tajawal',
                                                    fontSize:
                                                        Constants.fontSize - 4),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (City? value) {
                                            setState(() {
                                              selectedCity = value;
                                              address.city = value;
                                              emptySelectedCity = ' ';
                                            });
                                          },
                                        ))),
                              )),
                              Container(
                                padding: EdgeInsets.only(
                                    top: emptySelectedCity != ' ' ? 5 : 0,
                                    bottom: emptySelectedCity != ' ' ? 15 : 0,
                                    left: Constants.padding,
                                    right: Constants.padding),
                                child: Text(
                                  emptySelectedCity,
                                  style: TextStyle(
                                      color: Colors.redAccent.shade700,
                                      fontSize: 12.0),
                                ),
                              ),
                              CustomTextField(
                                label: 'Address Name'.tr(),
                                onSaved: (value) => address.name = value,
                                icon: MyFlutterApp.adress_icons_address_name2,
                                iconSize: 60,
                                isRequired: true,
                              ),
                              SizedBox(height: 15),
                              CustomTextField(
                                label: 'District'.tr(),
                                onSaved: (value) => address.district = value,
                                icon: MyFlutterApp.adress_icons_district2,
                                iconSize: 60,
                                isRequired: true,
                              ),
                              SizedBox(height: 15),
                              CustomTextField(
                                label: 'Street'.tr(),
                                onSaved: (value) => address.street = value,
                                icon: MyFlutterApp.adress_icons_street2,
                                iconSize: 60,
                                isRequired: true,
                              ),
                              SizedBox(height: 15),
                              CustomTextField(
                                label: 'Building'.tr(),
                                onSaved: (value) => address.building = value,
                                icon: MyFlutterApp.adress_icons_building2,
                                iconSize: 60,
                                isRequired: true,
                              ),
                              SizedBox(height: 15),
                              CustomTextField(
                                label: 'Home'.tr(),
                                onSaved: (value) => address.home = value,
                                icon: MyFlutterApp.adress_icons_home2,
                                iconSize: 60,
                                isRequired: true,
                              ),
                              SizedBox(height: 15),
                              CustomTextField(
                                label: 'Floor'.tr(),
                                onSaved: (value) => address.floor = value,
                                icon: MyFlutterApp.adress_icons_floor2,
                                iconSize: 60,
                                isRequired: true,
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
                                    onSaved: (value) => address.details = value,
                                    onFieldSubmitted: (_) {
                                      if (_formKey.currentState!.validate() &&
                                          selectedCity != null) {
                                        _formKey.currentState!.save();
                                        addAddress();
                                      } else if (selectedCity == null) {
                                        setState(() {
                                          emptySelectedCity =
                                              'City can\'t be empty'.tr();
                                          _formKey.currentState!
                                              .setState(() => false);
                                        });
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
                                margin:
                                    EdgeInsets.only(bottom: Constants.padding),
                                alignment: Alignment.center,
                                child: ButtonTheme(
                                  minWidth:
                                      MediaQuery.of(context).size.width / 3 * 2,
                                  height: 50,
                                  child: RaisedButton(
                                    elevation: 5,
                                    color: Constants.redColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            Constants.borderRadius)),
                                    child: AutoSizeText(
                                      'Add Address'.tr(),
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
                                                    .validate() &&
                                                selectedCity != null) {
                                              _formKey.currentState!.save();
                                              addAddress();
                                            } else if (selectedCity == null) {
                                              setState(() {
                                                emptySelectedCity =
                                                    'City can\'t be empty'.tr();
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
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  addAddress() async {
    LoadingService.instance.show(context);
    setState(() => isLoading = 1);
      try {final String url = 'add-address';
      final prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString(Constants.keyAccessToken);

      if (accessToken != null) {
        final data = await NetworkingHelper.postData(  url ,body: address.toJson(),
            headers: {
              'Authorization': 'Bearer ' + accessToken,
              'referer': Constants.apiReferer
            });

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
              if (redirectToCartPage == true) {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartPage(
                          fromSideMenu: false,
                        ))).then(
                      (value) => setState(() {
                    itemsInCart =
                        prefs.getInt(Constants.keyNumberOfItemsInCart);
                  }),
                );
              } else {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyAddressesPage()));
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

      setState(() => isLoading = 0);}
      catch (e){
        showInternetErrorDialog(context);
      }

    LoadingService.instance.hide();

  }

  getCities() async {
    return memoizer.runOnce(() async {
      final String url = 'get-cities';
      final response = await http.get(Uri.parse(Constants.apiUrl + url) ,
          headers: {'referer': Constants.apiReferer});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          List<City> cities =[];
          data = data['data'];
          for (int i = 0; i < data.length; i++) {
            cities.add(City(
                id: int.parse(data[i]['id'].toString()),
                name: data[i]['name']));
          }
          return cities;
        }
      }
      return Constants.requestErrorMessage;
    });
  }
}
