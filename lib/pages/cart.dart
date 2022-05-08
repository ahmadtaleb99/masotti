import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import '../widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import '../pages/orders_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_order.dart';
import '../models/coupon.dart';
import '../models/cart_address.dart';
import '../models/cart_delivering_costs_message.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/alert_dialog.dart';
import '../widgets/request_empty_data.dart';
import 'add_address.dart';
import 'add_address_ios.dart';
import 'home_page.dart';

class CartPage extends StatefulWidget {
  final bool fromSideMenu;

  CartPage({required this.fromSideMenu});

  @override
  State<StatefulWidget> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  double itemContainerHeight = 0.0;
  double colorSizeContainerWidth = 0.0;
  double containerWidth = 0.0;
  bool arabicLanguage = false;
  bool cartHasItems = false;
  late String confirmOrderButtonLabel;
  CartOrder cartOrder = CartOrder();
  List<Coupon>? availableCoupons;
  String couponValue = '0';
  String? _coupon = '0';
  List<CartAddress>? addresses;
  String? _address;
  late CartDeliveringCostsMessage costsMessage;
  bool isEnabled = false;
  int isLoading = 0;
  String? orderIdToUpdate;
  TextEditingController notesController = new TextEditingController();
  int notesTemp = -1;
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
    containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    itemContainerHeight = containerWidth / 100 * 85;
    colorSizeContainerWidth = containerWidth / 100 * 14;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'My Cart',
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: false,
        isCartPage: true,
        cartFromSideMenu: widget.fromSideMenu,
      ),
      drawer: SideMenu(),
      body: widget.fromSideMenu
          ? WillPopScope(
              onWillPop: () {
                Navigator.pop(context);
                Navigator.popUntil(context, ModalRoute.withName("/Home"));
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
                return Future.value(true);
              },
              child: getBody(),
            )
          : getBody(),
    );
  }

  Widget getBody() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(Constants.borderRadius * 2),
          topLeft: Radius.circular(Constants.borderRadius * 2)),
      child: Container(
        color: Constants.whiteColor,
        height: double.infinity,
        child: SingleChildScrollView(
            padding: EdgeInsets.only(top: Constants.halfPadding),
            child: FutureBuilder(
              future: getCartPageContent(),
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

                // ADDRESSES
                final keysValuesAddresses = [];
                keysValuesAddresses
                    .add({'key': 0, 'value': 'Select address'.tr()});

                if (addresses != null) {
                  for (int i = 0; i < addresses!.length; i++) {
                    keysValuesAddresses.add({
                      'key': addresses![i].id,
                      'value': addresses![i].name
                      // + ": \n" +
                      // addresses[i].details
                    });
                  }
                }

                // COUPONS
                final keysValuesCoupons = [];
                keysValuesCoupons.add({
                  'key': 0,
                  'code': '+ add voucher'.tr(),
                  'discount_value': 0,
                  'is_percentage': 0
                });

                if (availableCoupons != null) {
                  for (int i = 0; i < availableCoupons!.length; i++) {
                    keysValuesCoupons.add({
                      'key': availableCoupons![i].id,
                      'code': availableCoupons![i].code,
                      'discount_value': availableCoupons![i].discountValue,
                      'is_percentage': availableCoupons![i].isPercentage
                    });
                  }
                }

                return Container(
                  child: Column(
                    children: <Widget>[
                      /**
                       *
                       *
                       * Clear cart content
                       *
                       *
                       */

                      Container(
                        margin: EdgeInsets.only(bottom: Constants.halfPadding),
                        padding: EdgeInsets.symmetric(
                            vertical: Constants.halfPadding,
                            horizontal: Constants.padding),
                        alignment: arabicLanguage
                            ? Alignment.topRight
                            : Alignment.topLeft,
                        child: ButtonTheme(
                          minWidth: containerWidth / 3.6,
                          child: RaisedButton(
                            elevation: 5,
                            padding: EdgeInsets.symmetric(
                                vertical: Constants.buttonsVerticalPadding / 2),
                            color: Constants.redColor,
                            disabledColor: Constants.identityColor,
                            textColor: Constants.whiteColor,
                            disabledTextColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    Constants.borderRadius)),
                            child: AutoSizeText(
                              "Clear all".tr(),
                              maxFontSize: Constants.fontSize - 2,
                              minFontSize: Constants.fontSize - 4,
                            ),
                            onPressed: !cartHasItems
                                ? null
                                : isLoading == 1
                                    ? null
                                    : () {
                                        CustomDialog(
                                          context: context,
                                          title: "Warning".tr(),
                                          message:
                                              "Are you sure you want to clear all products from your cart?"
                                                  .tr(),
                                          okButtonTitle: 'Ok'.tr(),
                                          cancelButtonTitle: 'Cancel'.tr(),
                                          onPressedCancelButton: () {
                                            Navigator.pop(context);
                                          },
                                          onPressedOkButton: () {
                                            clearCart();
                                          },
                                          color: Color(0xFFFFB300),
                                          icon: "assets/images/warning.svg",
                                        ).showCustomDialog();
                                      },
                          ),
                        ),
                      ),
                      cartOrder.products == null
                          ? Container()
                          : Container(
                              width: containerWidth,
                              padding: EdgeInsets.only(
                                  bottom: Constants.halfPadding,
                                  right: Constants.halfPadding),
                              margin:
                                  EdgeInsets.only(bottom: Constants.padding),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Constants.borderRadius)),
                                  color: Constants.whiteColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      offset: Offset(0, 0),
                                    ),
                                  ]),
                              child: ListView.separated(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartOrder.products!.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    if (index !=
                                        cartOrder.products!.length - 1) {
                                      // Display `AdmobBanner` every 5 'separators'.
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal:
                                                Constants.doublePadding),
                                        child: Divider(
                                          color: Constants.redColor,
                                          thickness: 1,
                                        ),
                                      );
                                    }
                                    return Container();
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: containerWidth,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 1,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  margin: arabicLanguage
                                                      ? cartOrder.products![
                                                                      index][
                                                                      'name_ar']
                                                                  .toString()
                                                                  .length <
                                                              12
                                                          ? EdgeInsets.only(
                                                              right: Constants
                                                                  .halfPadding,
                                                              left: Constants
                                                                  .halfPadding,
                                                              top: Constants
                                                                  .halfPadding,
                                                            )
                                                          : EdgeInsets.only(
                                                              right: Constants
                                                                  .halfPadding,
                                                              left: Constants
                                                                  .halfPadding,
                                                              bottom: Constants
                                                                  .halfPadding,
                                                            )
                                                      : cartOrder.products![
                                                                      index][
                                                                      'name_en']
                                                                  .toString()
                                                                  .length <
                                                              12
                                                          ? EdgeInsets.only(
                                                              right: Constants
                                                                  .halfPadding,
                                                              left: Constants
                                                                  .halfPadding,
                                                              top: Constants
                                                                  .halfPadding,
                                                            )
                                                          : EdgeInsets.only(
                                                              right: Constants
                                                                  .halfPadding,
                                                              left: Constants
                                                                  .halfPadding,
                                                              bottom: Constants
                                                                  .halfPadding,
                                                            ),
                                                  child: AutoSizeText(
                                                    arabicLanguage
                                                        ? cartOrder.products![index]['name_ar']
                                                                    .toString()
                                                                    .length <
                                                                12
                                                            ? cartOrder.products![index][
                                                                    'name_ar'] +
                                                                "\n"
                                                            : cartOrder
                                                                    .products![index]
                                                                ['name_ar']
                                                        : cartOrder.products![index]['name_en']
                                                                    .toString()
                                                                    .length <
                                                                12
                                                            ? cartOrder
                                                                    .products![index][
                                                                        'name_en']
                                                                    .toString() +
                                                                "\n"
                                                            : cartOrder
                                                                .products![index]
                                                                    ['name_en']
                                                                .toString(),
                                                    style: TextStyle(
                                                        color: Constants
                                                            .identityColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxFontSize:
                                                        Constants.fontSize,
                                                    minFontSize:
                                                        Constants.fontSize - 2,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                      right:
                                                          Constants.halfPadding,
                                                      left:
                                                          Constants.halfPadding,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .all(Radius.circular(
                                                                Constants
                                                                    .borderRadius)),
                                                        color: Constants
                                                            .whiteColor,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors
                                                                .grey[400]!,
                                                            blurRadius: 5,
                                                            offset:
                                                                Offset(0, 1),
                                                          ),
                                                        ]),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius
                                                          .all(Radius.circular(
                                                              Constants
                                                                  .borderRadius)),
                                                      child: Image.network(
                                                        Constants.apiFilesUrl +
                                                            cartOrder.products![
                                                                index]['image'],
                                                        fit: BoxFit.fill,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          }
                                                          return Center(
                                                            child: CircularProgressIndicator(
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                valueColor: new AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Constants
                                                                        .redColor),
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null),
                                                          );
                                                        },
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.symmetric(
                                                      // horizontal:
                                                      //     Constants
                                                      //         .padding,
                                                      vertical: Constants
                                                          .halfPadding),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Container(
                                                            // width:
                                                            //     colorSizeContainerWidth /
                                                            //         2,
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 5,
                                                                    right: 5,
                                                                    left: 5),
                                                            margin: arabicLanguage
                                                                ? EdgeInsets.only(
                                                                    left: Constants
                                                                        .halfPadding)
                                                                : EdgeInsets.only(
                                                                    right: Constants
                                                                        .halfPadding),
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Constants
                                                                      .identityColor),
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(
                                                                      Constants
                                                                              .borderRadius /
                                                                          2)),
                                                              color: Constants
                                                                  .whiteColor,
                                                            ),
                                                            child: AutoSizeText(
                                                              cartOrder.products![
                                                                          index]
                                                                      [
                                                                      'variant']
                                                                  ['size'],
                                                              style: TextStyle(
                                                                color: Constants
                                                                    .identityColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                              maxFontSize: Constants
                                                                      .fontSize -
                                                                  2,
                                                              minFontSize: Constants
                                                                      .fontSize -
                                                                  4,
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            margin: arabicLanguage
                                                                ? EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            5)
                                                                : EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            5),
                                                            child: Stack(
                                                              children: [
                                                                Positioned(
                                                                  child: Icon(
                                                                      Icons
                                                                          .brightness_1,
                                                                      size: 26,
                                                                      color: Colors
                                                                              .grey[
                                                                          400]),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .brightness_1,
                                                                  size: 25,
                                                                  color: Color(int.parse('0xFF' +
                                                                      cartOrder.products![index]
                                                                              [
                                                                              'variant']
                                                                          [
                                                                          'color'])),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          MyFlutterApp
                                                              .group_245,
                                                          color: Constants
                                                              .redColor,
                                                          size: 25,
                                                        ),
                                                        onPressed: () async {
                                                          final prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          CustomDialog(
                                                            context: context,
                                                            title:
                                                                "Warning".tr(),
                                                            message:
                                                                "Are you sure you want to delete this product from your cart?"
                                                                    .tr(),
                                                            okButtonTitle:
                                                                'Ok'.tr(),
                                                            cancelButtonTitle:
                                                                'Cancel'.tr(),
                                                            onPressedCancelButton:
                                                                () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            onPressedOkButton:
                                                                () {
                                                              List<String>?
                                                                  tempProductsIDs =
                                                                  prefs.getStringList(
                                                                      Constants
                                                                          .keyProductsIDsInCart);
                                                              List<String>?
                                                                  tempProductsQuantities =
                                                                  prefs.getStringList(
                                                                      Constants
                                                                          .keyProductsQuantitiesInCart);
                                                              List<String>?
                                                                  tempProductsVariants =
                                                                  prefs.getStringList(
                                                                      Constants
                                                                          .keyProductsVariantsInCart);
                                                              int itemsInCart =
                                                                  prefs.getInt(
                                                                          Constants
                                                                              .keyNumberOfItemsInCart) ??
                                                                      0;
                                                              setState(() {
                                                                tempProductsIDs!
                                                                    .removeAt(
                                                                        index);
                                                                tempProductsQuantities!
                                                                    .removeAt(
                                                                        index);
                                                                tempProductsVariants!
                                                                    .removeAt(
                                                                        index);
                                                                itemsInCart =
                                                                    itemsInCart >
                                                                            0
                                                                        ? --itemsInCart
                                                                        : 0;

                                                                prefs.setStringList(
                                                                    Constants
                                                                        .keyProductsIDsInCart,
                                                                    tempProductsIDs);
                                                                prefs.setStringList(
                                                                    Constants
                                                                        .keyProductsQuantitiesInCart,
                                                                    tempProductsQuantities);
                                                                prefs.setStringList(
                                                                    Constants
                                                                        .keyProductsVariantsInCart,
                                                                    tempProductsVariants);
                                                                prefs.setInt(
                                                                    Constants
                                                                        .keyNumberOfItemsInCart,
                                                                    itemsInCart);
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            },
                                                            color: Color(
                                                                0xFFFFB300),
                                                            icon:
                                                                "assets/images/warning.svg",
                                                          ).showCustomDialog();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius
                                                            .circular(Constants
                                                                .borderRadius),
                                                        bottomRight: Radius
                                                            .circular(Constants
                                                                .borderRadius)),
                                                  ),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              // padding: EdgeInsets.symmetric(
                                                              //     horizontal:
                                                              //         Constants
                                                              //             .padding),
                                                              child:
                                                                  AutoSizeText(
                                                                'Unit Price'
                                                                    .tr(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Constants
                                                                      .identityColor,
                                                                ),
                                                                maxFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        2,
                                                                minFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        4,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          Constants
                                                                              .halfPadding),
                                                              alignment: arabicLanguage
                                                                  ? Alignment
                                                                      .centerLeft
                                                                  : Alignment
                                                                      .centerRight,
                                                              child:
                                                                  AutoSizeText(
                                                                cartOrder.products![index]['sales_price'] !=
                                                                            'null' &&
                                                                        cartOrder.products![index]['sales_price'] !=
                                                                            null
                                                                    ? cartOrder
                                                                            .products![index][
                                                                                'sales_price']
                                                                            .toString() +
                                                                        'Currency'
                                                                            .tr()
                                                                    : (cartOrder.products![index]['price'].toString().endsWith('.0')
                                                                            ? cartOrder.products![index]['price'].toString().replaceAll('.0',
                                                                                '')
                                                                            : cartOrder.products![index][
                                                                                'price']) +
                                                                        'Currency'
                                                                            .tr(),
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .identityColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                maxFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        2,
                                                                minFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        4,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                              // padding: EdgeInsets.symmetric(
                                                              //     horizontal:
                                                              //         Constants
                                                              //             .padding),
                                                              child:
                                                                  AutoSizeText(
                                                                'Quantity'.tr(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Constants
                                                                      .identityColor,
                                                                ),
                                                                maxFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        2,
                                                                minFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        4,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: <
                                                                    Widget>[
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: int.parse(cartOrder.products![index]['quantity'].toString()) >
                                                                            1
                                                                        ? IconButton(
                                                                            icon:
                                                                                Icon(
                                                                              Icons.remove,
                                                                              color: Constants.identityColor,
                                                                              size: 20,
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              final prefs = await SharedPreferences.getInstance();
                                                                              List<String>? tempProductsQuantities = prefs.getStringList(Constants.keyProductsQuantitiesInCart);
                                                                              setState(() {
                                                                                int val = int.parse(tempProductsQuantities![index]);
                                                                                tempProductsQuantities[index] = (val - 1 >= 1 ? val - 1 : 1).toString();
                                                                                prefs.setStringList(Constants.keyProductsQuantitiesInCart, tempProductsQuantities);
                                                                              });
                                                                            },
                                                                          )
                                                                        : Container(
                                                                            width:
                                                                                50,
                                                                          ),
                                                                  ),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    height:
                                                                        colorSizeContainerWidth /
                                                                            2,
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            15,
                                                                        vertical:
                                                                            Constants.padding /
                                                                                4),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(Constants
                                                                                .borderRadius)),
                                                                        color: Constants
                                                                            .identityColor),
                                                                    child:
                                                                        AutoSizeText(
                                                                      cartOrder
                                                                          .products![
                                                                              index]
                                                                              [
                                                                              'quantity']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color: Constants
                                                                              .whiteColor,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                      maxFontSize:
                                                                          Constants.fontSize -
                                                                              2,
                                                                      minFontSize:
                                                                          Constants.fontSize -
                                                                              4,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: Constants
                                                                            .identityColor,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        final prefs =
                                                                            await SharedPreferences.getInstance();
                                                                        List<String>?
                                                                            tempProductsQuantities =
                                                                            prefs.getStringList(Constants.keyProductsQuantitiesInCart);
                                                                        setState(
                                                                            () {
                                                                          tempProductsQuantities![index] =
                                                                              (int.parse(tempProductsQuantities[index]) + 1).toString();
                                                                          prefs.setStringList(
                                                                              Constants.keyProductsQuantitiesInCart,
                                                                              tempProductsQuantities);
                                                                        });
                                                                      },
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                              // padding: EdgeInsets.symmetric(
                                                              //     horizontal:
                                                              //         Constants
                                                              //             .padding),
                                                              child:
                                                                  AutoSizeText(
                                                                'Total'.tr(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Constants
                                                                      .identityColor,
                                                                ),
                                                                maxFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        2,
                                                                minFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        4,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          Constants
                                                                              .halfPadding),
                                                              alignment: arabicLanguage
                                                                  ? Alignment
                                                                      .centerLeft
                                                                  : Alignment
                                                                      .centerRight,
                                                              child:
                                                                  AutoSizeText(
                                                                cartOrder.products![index]['sales_price'] !=
                                                                            'null' &&
                                                                        cartOrder.products![index]['sales_price'] !=
                                                                            null
                                                                    ? (double.parse(cartOrder.products![index]['sales_price'].toString()) * double.parse(cartOrder.products![index]['quantity']))
                                                                            .toString() +
                                                                        'Currency'
                                                                            .tr()
                                                                    : (double.parse(cartOrder.products![index]['price']) * double.parse(cartOrder.products![index]['quantity']))
                                                                            .toString() +
                                                                        'Currency'
                                                                            .tr(),
                                                                style: TextStyle(
                                                                    color: Constants
                                                                        .identityColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                maxFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        2,
                                                                minFontSize:
                                                                    Constants
                                                                            .fontSize -
                                                                        4,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                            ),

                      /**
                       *
                       *
                       * Offers
                       *
                       *
                       */

                      cartOrder.offers == null
                          ? Container()
                          : Container(
                              child: ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: cartOrder.offers!.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Constants.padding),
                                      margin: EdgeInsets.only(
                                          bottom: Constants.padding),
                                      child: Container(
                                        width: containerWidth,
                                        // height: itemContainerHeight,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    Constants.borderRadius)),
                                            color: Constants.whiteColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                blurRadius: 5,
                                                offset: Offset(0, 0),
                                              ),
                                            ]),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              width: containerWidth,
                                              height:
                                                  itemContainerHeight / 2 - 16,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        Constants.borderRadius),
                                                    topRight: Radius.circular(
                                                        Constants
                                                            .borderRadius)),
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                        margin: EdgeInsets.all(
                                                            Constants.padding),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        Constants
                                                                            .borderRadius)),
                                                            color: Constants
                                                                .whiteColor,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey[400]!,
                                                                blurRadius: 5,
                                                                offset: Offset(
                                                                    0, 1),
                                                              ),
                                                            ]),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      Constants
                                                                          .borderRadius)),
                                                          child: Image.network(
                                                            Constants.apiFilesUrl +
                                                                cartOrder.offers![
                                                                        index]
                                                                    ['image'],
                                                            fit: BoxFit.fill,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                    backgroundColor:
                                                                        Colors
                                                                            .grey,
                                                                    valueColor: new AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Constants
                                                                            .redColor),
                                                                    value: loadingProgress.expectedTotalBytes !=
                                                                            null
                                                                        ? loadingProgress.cumulativeBytesLoaded /
                                                                            loadingProgress.expectedTotalBytes!
                                                                        : null),
                                                              );
                                                            },
                                                          ),
                                                        )),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.all(
                                                          Constants.padding),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          AutoSizeText(
                                                            arabicLanguage
                                                                ? cartOrder.offers![
                                                                        index]
                                                                    ['name_ar']
                                                                : cartOrder.offers![
                                                                        index]
                                                                    ['name_en'],
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .identityColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            maxFontSize:
                                                                Constants
                                                                    .fontSize,
                                                            minFontSize: Constants
                                                                    .fontSize -
                                                                2,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      child: IconButton(
                                                        icon: Icon(
                                                          MyFlutterApp
                                                              .group_245,
                                                          color: Constants
                                                              .redColor,
                                                          size: 25,
                                                        ),
                                                        onPressed: () async {
                                                          final prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          CustomDialog(
                                                            context: context,
                                                            title:
                                                                "Warning".tr(),
                                                            message:
                                                                "Are you sure you want to delete this product from your cart?"
                                                                    .tr(),
                                                            okButtonTitle:
                                                                'Ok'.tr(),
                                                            cancelButtonTitle:
                                                                'Cancel'.tr(),
                                                            onPressedCancelButton:
                                                                () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            onPressedOkButton:
                                                                () {
                                                              List<String>?
                                                                  tempOffersIDs =
                                                                  prefs.getStringList(
                                                                      Constants
                                                                          .keyOffersIDsInCart);
                                                              List<String>?
                                                                  tempOffersQuantities =
                                                                  prefs.getStringList(
                                                                      Constants
                                                                          .keyOffersQuantitiesInCart);
                                                              List<String>?
                                                                  tempOffersVariants =
                                                                  prefs.getStringList(
                                                                      Constants
                                                                          .keyOffersProductsVariants);
                                                              int itemsInCart =
                                                                  prefs.getInt(
                                                                          Constants
                                                                              .keyNumberOfItemsInCart) ??
                                                                      0;
                                                              setState(() {
                                                                tempOffersIDs!
                                                                    .removeAt(
                                                                        index);
                                                                tempOffersQuantities!
                                                                    .removeAt(
                                                                        index);
                                                                tempOffersVariants!
                                                                    .removeAt(
                                                                        index);
                                                                itemsInCart =
                                                                    itemsInCart >
                                                                            0
                                                                        ? --itemsInCart
                                                                        : 0;

                                                                prefs.setStringList(
                                                                    Constants
                                                                        .keyOffersIDsInCart,
                                                                    tempOffersIDs);
                                                                prefs.setStringList(
                                                                    Constants
                                                                        .keyOffersQuantitiesInCart,
                                                                    tempOffersQuantities);
                                                                prefs.setStringList(
                                                                    Constants
                                                                        .keyOffersProductsVariants,
                                                                    tempOffersVariants);
                                                                prefs.setInt(
                                                                    Constants
                                                                        .keyNumberOfItemsInCart,
                                                                    itemsInCart);
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            },
                                                            color: Color(
                                                                0xFFFFB300),
                                                            icon:
                                                                "assets/images/warning.svg",
                                                          ).showCustomDialog();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal:
                                                      Constants.padding),
                                              child: Divider(
                                                color: Constants.redColor,
                                                thickness: 1,
                                              ),
                                            ),
                                            Container(
                                              width: containerWidth,
                                              margin: EdgeInsets.symmetric(vertical: Constants.halfPadding),
                                              // height: itemContainerHeight / 2,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                        Constants.borderRadius),
                                                    bottomRight:
                                                        Radius.circular(
                                                            Constants
                                                                .borderRadius)),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      Constants
                                                                          .padding),
                                                          child: AutoSizeText(
                                                            'Unit Price'.tr(),
                                                            style: TextStyle(
                                                              color: Constants
                                                                  .identityColor,
                                                            ),
                                                            maxFontSize: Constants
                                                                    .fontSize -
                                                                2,
                                                            minFontSize: Constants
                                                                    .fontSize -
                                                                4,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      Constants
                                                                          .padding),
                                                          alignment: arabicLanguage
                                                              ? Alignment
                                                                  .centerLeft
                                                              : Alignment
                                                                  .centerRight,
                                                          child: AutoSizeText(
                                                            (cartOrder.offers![
                                                                            index]
                                                                            [
                                                                            'price']
                                                                        .toString()
                                                                        .endsWith(
                                                                            '.0')
                                                                    ? cartOrder
                                                                        .offers![
                                                                            index]
                                                                            [
                                                                            'price']
                                                                        .toString()
                                                                        .replaceAll(
                                                                            '.0',
                                                                            '')
                                                                    : cartOrder
                                                                        .offers![
                                                                            index]
                                                                            [
                                                                            'price']
                                                                        .toString()) +
                                                                'Currency'.tr(),
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .identityColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            maxFontSize: Constants
                                                                    .fontSize -
                                                                2,
                                                            minFontSize: Constants
                                                                    .fontSize -
                                                                4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      Constants
                                                                          .padding),
                                                          child: AutoSizeText(
                                                            'Quantity'.tr(),
                                                            style: TextStyle(
                                                              color: Constants
                                                                  .identityColor,
                                                            ),
                                                            maxFontSize: Constants
                                                                    .fontSize -
                                                                2,
                                                            minFontSize: Constants
                                                                    .fontSize -
                                                                4,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                              int.parse(cartOrder
                                                                          .offers![
                                                                              index]
                                                                              [
                                                                              'quantity']
                                                                          .toString()) >
                                                                      1
                                                                  ? IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .remove,
                                                                        color: Constants
                                                                            .identityColor,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        final prefs =
                                                                            await SharedPreferences.getInstance();
                                                                        List<String>?
                                                                            tempOffersQuantities =
                                                                            prefs.getStringList(Constants.keyOffersQuantitiesInCart);
                                                                        setState(
                                                                            () {
                                                                          int val =
                                                                              int.parse(tempOffersQuantities![index]);
                                                                          tempOffersQuantities[index] =
                                                                              (val - 1 >= 1 ? val - 1 : 1).toString();
                                                                          prefs.setStringList(
                                                                              Constants.keyOffersQuantitiesInCart,
                                                                              tempOffersQuantities);
                                                                        });
                                                                      },
                                                                    )
                                                                  : Container(
                                                                      width: 50,
                                                                    ),
                                                              Container(
                                                                alignment:
                                                                Alignment
                                                                    .center,
                                                                height:
                                                                colorSizeContainerWidth /
                                                                    2,
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal:
                                                                    15,
                                                                    vertical:
                                                                    Constants.padding /
                                                                        4),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.all(Radius.circular(Constants
                                                                        .borderRadius)),
                                                                    color: Constants
                                                                        .identityColor),
                                                                child:
                                                                    AutoSizeText(
                                                                  cartOrder
                                                                      .offers![
                                                                          index]
                                                                          [
                                                                          'quantity']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Constants
                                                                          .whiteColor,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  maxFontSize:
                                                                      Constants
                                                                              .fontSize -
                                                                          2,
                                                                  minFontSize:
                                                                      Constants
                                                                              .fontSize -
                                                                          4,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  color: Constants
                                                                      .identityColor,
                                                                  size: 20,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  final prefs =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  List<String>?
                                                                      tempOffersQuantities =
                                                                      prefs.getStringList(
                                                                          Constants
                                                                              .keyOffersQuantitiesInCart);
                                                                  setState(() {
                                                                    tempOffersQuantities![
                                                                        index] = (int.parse(tempOffersQuantities[index]) +
                                                                            1)
                                                                        .toString();
                                                                    prefs.setStringList(
                                                                        Constants
                                                                            .keyOffersQuantitiesInCart,
                                                                        tempOffersQuantities);
                                                                  });
                                                                },
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      Constants
                                                                          .padding),
                                                          child: AutoSizeText(
                                                            'Total'.tr(),
                                                            style: TextStyle(
                                                              color: Constants
                                                                  .identityColor,
                                                            ),
                                                            maxFontSize: Constants
                                                                    .fontSize -
                                                                2,
                                                            minFontSize: Constants
                                                                    .fontSize -
                                                                4,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      Constants
                                                                          .padding),
                                                          alignment: arabicLanguage
                                                              ? Alignment
                                                                  .centerLeft
                                                              : Alignment
                                                                  .centerRight,
                                                          child: AutoSizeText(
                                                            (double.parse(cartOrder
                                                                            .offers![index][
                                                                                'price']
                                                                            .toString()) *
                                                                        double.parse(cartOrder
                                                                            .offers![index]['quantity']
                                                                            .toString()))
                                                                    .toString() +
                                                                'Currency'.tr(),
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .identityColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            maxFontSize: Constants
                                                                    .fontSize -
                                                                2,
                                                            minFontSize: Constants
                                                                    .fontSize -
                                                                4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),

                      /**
                       *
                       *
                       * Coupons / Vouchers
                       *
                       *
                       */

                      keysValuesCoupons.length <= 1
                          ? Container()
                          : Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: Constants.padding),
                              child: Align(
                                alignment: arabicLanguage
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Container(
                                    child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    icon: Container(),
                                    iconEnabledColor: Constants.identityColor,
                                    value: _coupon,
                                    items: keysValuesCoupons
                                        .map((data) => DropdownMenuItem<String>(
                                              child: Text(
                                                data['key'] == 0
                                                    ? data['code']
                                                    : data['discount_value']
                                                            .toString() +
                                                        (data['is_percentage']
                                                                    .toString() ==
                                                                'true'
                                                            ? '%'
                                                            : 'Currency'.tr()),
                                                style: TextStyle(
                                                    color: Constants.redColor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              value: data['key'].toString(),
                                            ))
                                        .toList(),
                                    onChanged: (String? value) {
                                      var temp = keysValuesCoupons.firstWhere(
                                          (coupon) =>
                                              coupon['key'].toString() ==
                                              value);
                                      setState(() {
                                        couponValue = temp['discount_value']
                                                .toString() +
                                            (temp['is_percentage'].toString() ==
                                                    'true'
                                                ? ' %'
                                                : ' ');
                                        _coupon = value;
                                      });
                                    },
                                    hint: AutoSizeText(
                                      '+ add voucher'.tr(),
                                      style: TextStyle(
                                          color: Constants.redColor,
                                          fontWeight: FontWeight.bold),
                                      maxFontSize: Constants.fontSize - 2,
                                      minFontSize: Constants.fontSize - 4,
                                    ),
                                  ),
                                )),
                              ),
                            ),

                      /**
                       *
                       *
                       * Total prices
                       *
                       *
                       */

                      Container(
                        width: containerWidth,
                        height: containerWidth / 3,
                        padding: EdgeInsets.symmetric(
                            horizontal: Constants.halfPadding),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(Constants.borderRadius)),
                            color: Constants.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: arabicLanguage
                                          ? EdgeInsets.only(
                                              right: Constants.halfPadding)
                                          : EdgeInsets.only(
                                              left: Constants.halfPadding),
                                      child: AutoSizeText(
                                        'SubTotal'.tr(),
                                        style: TextStyle(
                                          color: Constants.identityColor,
                                        ),
                                        minFontSize: 16,
                                        maxFontSize: 18,
                                      ),
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    alignment: arabicLanguage
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    padding: arabicLanguage
                                        ? EdgeInsets.only(
                                            left: Constants.halfPadding)
                                        : EdgeInsets.only(
                                            right: Constants.halfPadding),
                                    child: AutoSizeText(
                                      calculatePrices()['subTotal'].toString() +
                                          'Currency'.tr(),
                                      style: TextStyle(
                                          color: Constants.identityColor,
                                          fontWeight: FontWeight.bold),
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: arabicLanguage
                                          ? EdgeInsets.only(
                                              right: Constants.halfPadding)
                                          : EdgeInsets.only(
                                              left: Constants.halfPadding),
                                      child: AutoSizeText(
                                        'Coupon'.tr(),
                                        style: TextStyle(
                                          color: Constants.identityColor,
                                        ),
                                        minFontSize: 16,
                                        maxFontSize: 18,
                                      ),
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    alignment: arabicLanguage
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    padding: arabicLanguage
                                        ? EdgeInsets.only(
                                            left: Constants.halfPadding)
                                        : EdgeInsets.only(
                                            right: Constants.halfPadding),
                                    child: AutoSizeText(
                                      couponValue.toString(),
                                      style: TextStyle(
                                          color: Constants.identityColor,
                                          fontWeight: FontWeight.bold),
                                      minFontSize: 16,
                                      maxFontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      padding: arabicLanguage
                                          ? EdgeInsets.only(
                                              right: Constants.halfPadding)
                                          : EdgeInsets.only(
                                              left: Constants.halfPadding),
                                      child: AutoSizeText(
                                        'Total'.tr(),
                                        style: TextStyle(
                                            color: Constants.identityColor),
                                        minFontSize: 16,
                                        maxFontSize: 18,
                                      ),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      alignment: arabicLanguage
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      padding: arabicLanguage
                                          ? EdgeInsets.only(
                                              left: Constants.halfPadding)
                                          : EdgeInsets.only(
                                              right: Constants.halfPadding),
                                      child: AutoSizeText(
                                        calculatePrices()['total'].toString() +
                                            'Currency'.tr(),
                                        style: TextStyle(
                                            color: Constants.identityColor,
                                            fontWeight: FontWeight.bold),
                                        minFontSize: 16,
                                        maxFontSize: 18,
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /**
                       *
                       *
                       * Delivery cost message
                       *
                       *
                       */

                      Container(
                        width: containerWidth,
                        padding: EdgeInsets.all(Constants.padding),
                        child: Center(
                          child: InkWell(
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return ButtonBarTheme(
                                    data: ButtonBarThemeData(
                                        alignment: MainAxisAlignment.center),
                                    child: AlertDialog(
                                      title: Text('Delivery Cost Details'.tr()),
                                      content: SingleChildScrollView(
                                        child: SingleChildScrollView(
                                          child: Text(arabicLanguage
                                              ? costsMessage.messageAr!
                                              : costsMessage.messageEn!),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            'Ok'.tr(),
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Constants.fontSize - 2),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          color: Constants.redColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                Constants.borderRadius),
                                          ),
                                          minWidth: containerWidth / 2.5,
                                          height: 40,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            child: AutoSizeText(
                              'Click to display delivery costs'.tr(),
                              style: TextStyle(
                                  color: Constants.redColor,
                                  fontWeight: FontWeight.bold),
                              maxFontSize: Constants.fontSize,
                              minFontSize: Constants.fontSize - 2,
                            ),
                          ),
                        ),
                      ),

                      /**
                       *
                       *
                       * Address
                       *
                       *
                       */

                      Container(
                        width: containerWidth,
                        // height: containerWidth / 10 * 3,
                        padding: EdgeInsets.all(Constants.padding),
                        margin: EdgeInsets.only(bottom: Constants.padding),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(Constants.borderRadius)),
                            color: Constants.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: Constants.halfPadding),
                              child: AutoSizeText(
                                'Select your delivery address'.tr(),
                                style: TextStyle(
                                  color: Constants.identityColor,
                                ),
                                maxFontSize: Constants.fontSize - 2,
                                minFontSize: Constants.fontSize - 4,
                              ),
                            ),
                            keysValuesAddresses.length > 1
                                ? Column(
                                    children: <Widget>[
                                      Container(
                                          child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          iconEnabledColor:
                                              Constants.identityColor,
                                          value: _address,
                                          items: keysValuesAddresses
                                              .map((data) =>
                                                  DropdownMenuItem<String>(
                                                    child:
                                                        // data['value'] ==
                                                        //                                   'Select address'.tr() ?
                                                        AutoSizeText(
                                                      data['value'],
                                                      style: TextStyle(
                                                          color: Constants
                                                              .identityColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxFontSize:
                                                          Constants.fontSize -
                                                              2,
                                                      minFontSize:
                                                          Constants.fontSize -
                                                              4,
                                                    ),
                                                    //     :
                                                    // Column(
                                                    //   children: [
                                                    //     AutoSizeText(
                                                    //       data['value'],
                                                    //       style: TextStyle(
                                                    //           color: Constants
                                                    //               .identityColor,
                                                    //           fontWeight:
                                                    //           FontWeight.bold),
                                                    //       maxFontSize:
                                                    //       Constants.fontSize -
                                                    //           2,
                                                    //       minFontSize:
                                                    //       Constants.fontSize -
                                                    //           4,
                                                    //     ),
                                                    //     AutoSizeText(
                                                    //       data['value'],
                                                    //       style: TextStyle(
                                                    //           color: Constants
                                                    //               .identityColor,
                                                    //           fontWeight:
                                                    //           FontWeight.bold),
                                                    //       maxFontSize:
                                                    //       Constants.fontSize -
                                                    //           2,
                                                    //       minFontSize:
                                                    //       Constants.fontSize -
                                                    //           4,
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    value:
                                                        data['key'].toString(),
                                                  ))
                                              .toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              _address = value;
                                              isEnabled =
                                                  value != '0' ? true : false;
                                            });
                                          },
                                          hint: AutoSizeText(
                                            'Select address'.tr(),
                                            style: TextStyle(
                                                color: Constants.identityColor,
                                                fontWeight: FontWeight.bold),
                                            maxFontSize: Constants.fontSize - 2,
                                            minFontSize: Constants.fontSize - 4,
                                          ),
                                        ),
                                      )),
                                      Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        child: AutoSizeText(
                                          'Or'.tr(),
                                          style: TextStyle(
                                            color: Constants.identityColor,
                                          ),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ),
                                      )
                                    ],
                                  )
                                : Container(
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: AutoSizeText(
                                      'You haven\'t added any address yet. '
                                          .tr(),
                                      style: TextStyle(
                                        color: Constants.identityColor,
                                      ),
                                      maxFontSize: Constants.fontSize - 2,
                                      minFontSize: Constants.fontSize - 4,
                                    ),
                                  ),
                            InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  Platform.isIOS
                                      ? MaterialPageRoute(
                                          builder: (context) =>
                                              AddAddressIOS.withRedirect(
                                            redirectToCartPage: true,
                                          ),
                                        )
                                      : MaterialPageRoute(
                                          builder: (context) =>
                                              AddAddress.withRedirect(
                                            redirectToCartPage: true,
                                          ),
                                        )),
                              child: AutoSizeText(
                                'Click to add new one'.tr(),
                                style: TextStyle(
                                  color: Constants.redColor,
                                ),
                                maxFontSize: Constants.fontSize - 2,
                                minFontSize: Constants.fontSize - 4,
                              ),
                            )
                          ],
                        ),
                      ),

                      /**
                       *
                       *
                       * Notes
                       *
                       *
                       */
                      Container(
                        width: containerWidth,
                        // height: containerWidth / 10 * 3,
                        padding: EdgeInsets.all(Constants.padding),
                        margin: EdgeInsets.only(bottom: Constants.padding),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(Constants.borderRadius)),
                            color: Constants.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: TextField(
                            controller: notesController,
                            keyboardType: TextInputType.multiline,
                            decoration: new InputDecoration.collapsed(
                              hintText: 'Add notes (if there is any)'.tr() +
                                  '\n' +
                                  'e.g: Please call this number .....'.tr(),
                            ),
                            style: TextStyle(
                                color: Constants.identityColor,
                                fontSize: Constants.fontSize - 3),
                            maxLines: 5,
                            minLines: 3,
                          ),
                        ),
                      ),

                      /**
                       *
                       *
                       * Order button
                       *
                       *
                       */

                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: Constants.padding),
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
                              confirmOrderButtonLabel.tr(),
                              style: TextStyle(
                                color: Constants.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                              maxFontSize: Constants.fontSize,
                              minFontSize: Constants.fontSize - 2,
                            ),
                            onPressed: !isEnabled || !cartHasItems
                                ? null
                                : isLoading == 1
                                    ? null
                                    : () {
                                        saveOrder(containerWidth);
                                      },
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            )),
      ),
    );
  }

  getCartPageContent() async {
    print('fat 1 ');
    final String url = 'get-cart-page-content';
    final prefs = await SharedPreferences.getInstance();

    List<String>? productsIDs =
        prefs.getStringList(Constants.keyProductsIDsInCart);
    List<String>? productsQuantities =
        prefs.getStringList(Constants.keyProductsQuantitiesInCart);
    List<String>? productsVariants =
        prefs.getStringList(Constants.keyProductsVariantsInCart);
    List<String>? offersIDs = prefs.getStringList(Constants.keyOffersIDsInCart);
    List<String>? offersQuantities =
        prefs.getStringList(Constants.keyOffersQuantitiesInCart);
    String? accessToken = prefs.getString(Constants.keyAccessToken);
    orderIdToUpdate = prefs.getString(Constants.keyOrderIDToUpdate);

    if (accessToken != null) {
      print('fat2');

      confirmOrderButtonLabel =
      (orderIdToUpdate == null || orderIdToUpdate!.isEmpty) ? 'Create Order' :  'Update Order' ;

      List? productsData;
      List? offersData;

      if (productsIDs != null) {
        cartHasItems = true;
        productsData = [];
        for (int i = 0; i < productsIDs.length; i++) {
          productsData.add({
            'id': productsIDs[i],
            'quantity': productsQuantities![i],
            'variant': productsVariants![i]
          });
        }
      }

      if (offersIDs != null) {
        cartHasItems = true;
        offersData =[];
        for (int i = 0; i < offersIDs.length; i++) {
          offersData.add({
            'id': offersIDs[i],
            'quantity': offersQuantities![i],
          });
        }
      }

      Map<String, String?> dataToBeSent = orderIdToUpdate != null
          ? {
              'products_data': jsonEncode(productsData),
              'offers_data': jsonEncode(offersData),
              'order_id': orderIdToUpdate
              // This parameter is used to get notes of order in case updating order
            }
          : {
              'products_data': jsonEncode(productsData),
              'offers_data': jsonEncode(offersData),
            };


      print('fat3');
      final response = await http.post(Uri.parse(Constants.apiUrl + url ),
          body: dataToBeSent,
          headers: {
            'Authorization': 'Bearer ' + accessToken,
            'referer': Constants.apiReferer
          });

      if (response.statusCode == 200) {
        print('fat 4');

        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'];
          print('cart order: ' + data.toString());

          if (!(data['products_and_offers'] is List)) {
            cartOrder.products = data['products_and_offers']['products'] != null
                ? data['products_and_offers']['products']
                : null;
            cartOrder.offers = data['products_and_offers']['offers'] != null
                ? data['products_and_offers']['offers']
                : null;
          } else {
            cartOrder.products = null;
            cartOrder.offers = null;
            cartHasItems = false;
          }

          if (data['notes'] != null) {
            cartOrder.notes = data['notes'];
            if (notesTemp == -1) {
              notesController.text = cartOrder.notes!;
            }
            notesTemp++;
          }

          if (data['available_coupons'] != null) {
            availableCoupons = [];
            for (int i = 0; i < data['available_coupons'].length; i++) {
              availableCoupons!.add(Coupon(
                  id: data['available_coupons'][i]['id'].toString(),
                  isPercentage:
                      data['available_coupons'][i]['is_percentage'] == 0
                          ? false
                          : true,
                  code: data['available_coupons'][i]['code'],
                  discountValue: data['available_coupons'][i]['discount_value']
                      .toString()));
            }
          }

          if (data['addresses_names'] != null) {
            addresses =[];
            for (int i = 0; i < data['addresses_names'].length; i++) {
              addresses!.add(CartAddress(
                id: data['addresses_names'][i]['id'].toString(),
                name: data['addresses_names'][i]['name'],
                // details: data['addresses_names'][i]['details']
              ));
            }
          }

          costsMessage = CartDeliveringCostsMessage(
            messageEn: data['cost_message_en'],
            messageAr: data['cost_message_ar'],
          );
        }
      }
      return true;
    }
  }

  saveOrder(double containerWidth) async {
    setState(() => isLoading = 1);

    String url = 'create-order';
    final prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString(Constants.keyAccessToken)!;

    if (orderIdToUpdate != null) {
      url = 'create-order?order_id_for_update=' + orderIdToUpdate!;
    }

    List products = [];
    List offers =[];

    if (cartOrder.products != null) {
      for (int i = 0; i < cartOrder.products!.length; i++) {
        products.add({
          'id': cartOrder.products![i]['id'],
          'quantity': cartOrder.products![i]['quantity'],
          'variant': cartOrder.products![i]['variant']
        });
      }
    }

    if (cartOrder.offers != null) {
      List<String>? offersProductsVariants =
          prefs.getStringList(Constants.keyOffersProductsVariants);
      for (int i = 0; i < cartOrder.offers!.length; i++) {
        offers.add({
          'id': cartOrder.offers![i]['id'],
          'quantity': cartOrder.offers![i]['quantity'],
          'variants': offersProductsVariants![i]
        });
      }
    }

    Map<String, String?> dataToBeSent = {
      'products_data': jsonEncode(products),
      'offers_data': jsonEncode(offers),
      'notes': notesController.text,
      'coupon_id': _coupon != null ? _coupon : '',
      'address_id': _address,
    };

    print(dataToBeSent);

    final response = await http.post(Uri.parse(Constants.apiUrl + url),
        body: dataToBeSent,
        headers: {
          'Authorization': 'Bearer ' + accessToken,
          'referer': Constants.apiReferer
        });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        prefs.setString(Constants.keyOrderIDToUpdate,'' );
        prefs.setStringList(Constants.keyProductsIDsInCart, []);
        prefs.setStringList(Constants.keyProductsQuantitiesInCart, []);
        prefs.setStringList(Constants.keyProductsVariantsInCart, []);
        prefs.setStringList(Constants.keyOffersIDsInCart, []);
        prefs.setStringList(Constants.keyOffersQuantitiesInCart, []);
        prefs.setInt(Constants.keyNumberOfItemsInCart, 0);

        String content = 'The order has been saved successfully.'.tr();
        content += '\n\n';
        content += 'Note: Order will be handled within 24 hours.'.tr();
        CustomDialog(
          context: context,
          title: data['status'] ? "Successful..".tr() : "Error".tr(),
          message: content,
          okButtonTitle: 'Ok'.tr(),
          cancelButtonTitle: 'Cancel'.tr(),
          onPressedCancelButton: () {
            Navigator.pop(context);
          },
          onPressedOkButton: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => OrdersHistoryPage()));
          },
          color: data['status'] ? Constants.greenColor : Constants.redColor,
          icon: data['status']
              ? "assets/images/correct.svg"
              : "assets/images/wrong.svg",
        ).showCustomDialog();
      } else if (data['message'] == 'Blocked Account') {
        CustomDialog(
          context: context,
          title: 'Blocked Account'.tr(),
          message: 'Blocked Account Message'.tr(),
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

  Map<String, num> calculatePrices() {
    if (cartOrder.products == null && cartOrder.offers == null) {
      Map<String, num> result = {'subTotal': 0.0, 'total': 0.0};
      return result;
    }

    var sumProducts = 0.0;
    if (cartOrder.products != null) {
      for (int i = 0; i < cartOrder.products!.length; i++) {
        sumProducts += cartOrder.products![i]['sales_price'] != 'null' &&
                cartOrder.products![i]['sales_price'] != null
            ? double.parse(cartOrder.products![i]['sales_price'].toString()) *
                double.parse(cartOrder.products![i]['quantity'].toString())
            : double.parse(cartOrder.products![i]['price'].toString()) *
                double.parse(cartOrder.products![i]['quantity'].toString());
      }
    }

    var sumOffers = 0.0;
    if (cartOrder.offers != null) {
      for (int i = 0; i < cartOrder.offers!.length; i++) {
        sumOffers += double.parse(cartOrder.offers![i]['price'].toString()) *
            double.parse(cartOrder.offers![i]['quantity'].toString());
      }
    }

    num total = sumProducts + sumOffers;
    num totalWithCoupon = total;

    if (_coupon != null && _coupon != '0') {
      Coupon selectedCoupon = availableCoupons!
          .firstWhere((coupon) => coupon.id.toString() == _coupon);
      if (selectedCoupon.isPercentage!) {
        totalWithCoupon -=
            (double.parse(selectedCoupon.discountValue!) * total / 100);
      } else {
        totalWithCoupon -= double.parse(selectedCoupon.discountValue!);
      }
    }

    Map<String, num> result = {
      'subTotal': total < 0 ? 0.0 : total,
      'total': totalWithCoupon < 0 ? 0.0 : totalWithCoupon
    };
    return result;
  }

  clearCart() async {
    setState(() => isLoading = 1);
    final prefs = await SharedPreferences.getInstance();
    List<String>? productsIDs =
        prefs.getStringList(Constants.keyProductsIDsInCart);
    List<String>? productsQuantities =
        prefs.getStringList(Constants.keyProductsQuantitiesInCart);
    List<String>? productsVariants =
        prefs.getStringList(Constants.keyProductsVariantsInCart);
    int itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart) ?? 0;

    if (productsIDs == null) {
      productsIDs = [];
      productsQuantities = [];
      productsVariants = [];
    }
    productsIDs.clear();
    productsQuantities!.clear();
    productsVariants!.clear();
    itemsInCart = 0;

    prefs.setStringList(Constants.keyProductsIDsInCart, productsIDs);
    prefs.setStringList(
        Constants.keyProductsQuantitiesInCart, productsQuantities);
    prefs.setStringList(Constants.keyProductsVariantsInCart, productsVariants);
    prefs.setInt(Constants.keyNumberOfItemsInCart, itemsInCart);

    Navigator.pop(context);

    setState(() => isLoading = 0);
  }
}
