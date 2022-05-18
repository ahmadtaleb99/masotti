import 'dart:developer';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './add_address.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/address.dart';
import 'add_address_ios.dart';
import 'home_page.dart';

class MyAddressesPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAddressesPageState();
}

class MyAddressesPageState extends State<MyAddressesPage> {
  bool arabicLanguage = false;
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
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'My Addresses'.tr(),
        currentContext: context,
        itemsInCart: itemsInCart,
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
              padding: EdgeInsets.all(Constants.padding),
              child: FutureBuilder(
                  future: getAddresses(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Center(
                            child: ColoredCircularProgressIndicator(),
                          ));
                    }
                    var response = snap.data;
                    if (response is int && response == -1) {
                      return Container(
                        margin: EdgeInsets.only(bottom: Constants.doublePadding, right: Constants.padding, left: Constants.padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            AutoSizeText(
                              'Add new address'.tr(),
                              style: TextStyle(
                                  color: Constants.identityColor,
                                  fontWeight: FontWeight.bold),
                              maxFontSize: Constants.fontSize + 2,
                              minFontSize: Constants.fontSize,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Constants.redColor),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                color: Constants.whiteColor,
                                onPressed: () {

                                  Navigator.push(
                                      context,
                                      Platform.isIOS
                                          ? MaterialPageRoute(
                                          builder: (context) => AddAddressIOS())
                                          : MaterialPageRoute(
                                          builder: (context) => AddAddress()));
                                }
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    if (response is String) {
                      return RequestEmptyData(
                        message: response.tr(),
                      );
                    }
                    List<AddressWidget> addresses =
                        response as List<AddressWidget>;
                    return Container(
                        width: containerWidth,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: Constants.doublePadding, right: Constants.halfPadding, left: Constants.halfPadding),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  AutoSizeText(
                                    'Add new address'.tr(),
                                    style: TextStyle(
                                        color: Constants.identityColor,
                                        fontWeight: FontWeight.bold),
                                    maxFontSize: Constants.fontSize + 2,
                                    minFontSize: Constants.fontSize,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Constants.redColor),
                                    child: IconButton(
                                      icon: Icon(Icons.add),
                                      color: Constants.whiteColor,
                                      onPressed: () {

                                        Platform.isIOS ? Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddAddressIOS()))  :
                                        Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                        builder: (context) =>
                                        AddAddress()));
                                      }
                                    ),
                                  )
                                ],
                              ),
                            ),
                            ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: addresses.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: Constants.padding),
                                    child: addresses[index],
                                  );
                                }),
                          ],
                        ));
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Future getAddresses() async {
    final String url = 'get-customer-addresses';
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(Constants.keyAccessToken);

    if (accessToken != null) {
      final response = await http.get(Uri.parse(Constants.apiUrl + url), headers: {
        'Authorization': 'Bearer ' + accessToken,
        'referer': Constants.apiReferer
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'];
          List<AddressWidget> address =  [];
          for (int i = 0; i < data.length; i++) {
            address.add(AddressWidget(
              id: data[i]['id'].toString(),
              name: data[i]['name'],
              onDelete: () => deleteAddress(data[i]['id'].toString()),
            ));
          }
          return address;
        }
        return -1;
      }
      return Constants.requestErrorMessage;
    }
  }

  deleteAddress(String addressId) async {
    final String url = 'delete-address?address_id=$addressId';
    final response = await http.post(Uri.parse(Constants.apiUrl + url),
        headers: {'referer': Constants.apiReferer});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MyAddressesPage()));
      }
    }
  }
}
