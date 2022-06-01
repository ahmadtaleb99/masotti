import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import '../widgets/custom_dialog.dart';
import '../assets/my_flutter_app_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './cart.dart';
import '../widgets/alert_dialog.dart';
import './product.dart';
import './offer.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/order_details_item.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  @override
  State<StatefulWidget> createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends State<OrderDetailsPage> {
  bool arabicLanguage = false;
  int isLoading = 0;

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

  Color _getOrderStatusColor(orderStatus) {
    switch (orderStatus) {
      case 'Pending':
        return Constants.orderStatusPendingColor;
      case 'In Progress':
        return Constants.orderStatusInProgressColor;
      case 'Waiting For Customer Action':
        return Constants.orderStatusWaitingForCustomerActionColor;
      case 'Canceled':
        return Constants.orderStatusCanceledColor;
      case 'Delivering':
        return Constants.orderStatusDeliveringColor;
      case 'Delivered':
        return Constants.orderStatusDeliveredColor;
      case 'Not Delivered':
        return Constants.orderStatusNotDeliveredColor;
    }
    return Constants.whiteColor;
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight = containerWidth * 60 / 100;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Order Details',
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
            padding: EdgeInsets.all(Constants.padding),
            child: FutureBuilder(
                future: getOrderDetails(widget.orderId),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: ColoredCircularProgressIndicator(),
                        ));
                  }
                  var response = snap.data;
                  if (response is String  ) {
                    return RequestEmptyData(
                      message: response,
                    );
                  }
                  dynamic orderDetails = response;
                  return Container(
                    width: containerWidth,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: containerWidth,
                          height: orderDetails['delivery_cost'] != null
                              ? containerHeight + 20
                              : containerHeight * 85 / 100,
                          margin: EdgeInsets.only(bottom: Constants.padding),
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: containerWidth,
                                height: containerHeight * 18 * 2 / 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Constants.borderRadius)),
                                  color: _getOrderStatusColor(
                                      orderDetails['status']),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey[400]!,
                                        blurRadius: 5,
                                        offset: Offset(0, 0),
                                      )
                                    ]
                                ),
                                child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                          child: AutoSizeText(
                                            orderDetails['status']
                                                .toString()
                                                .tr(),
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                                fontWeight: FontWeight.bold),
                                            maxFontSize: Constants.fontSize,
                                            minFontSize: Constants.fontSize - 2,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 15),
                                          child: Icon(
                                            MyFlutterApp.group_209,
                                            color: Constants.whiteColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              Positioned(
                                top: containerHeight * 18 / 100,
                                child: Container(
                                  width: containerWidth,
                                  // height: containerHeight,
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
                                        )
                                      ]),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 20,
                                        right: 15,
                                        left: 15,
                                        bottom: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              child: AutoSizeText(
                                                'Order ID: '.tr() +
                                                    orderDetails['id']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxFontSize:
                                                    Constants.fontSize + 2,
                                                minFontSize: Constants.fontSize,
                                              ),
                                            ),
                                            (orderDetails['delivery_cost'] !=
                                                        null) ||
                                                    (orderDetails[
                                                                'delivery_cost'] ==
                                                            null &&
                                                        orderDetails['status']
                                                                .toString() ==
                                                            'Delivered')
                                                ? Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: AutoSizeText(
                                                      (orderDetails['total_price'] +
                                                                  orderDetails[
                                                                      'delivery_cost'])
                                                              .toString() +
                                                          (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxFontSize:
                                                          Constants.fontSize +
                                                              2,
                                                      minFontSize:
                                                          Constants.fontSize,
                                                    ),
                                                  )
                                                : Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: AutoSizeText(
                                                      orderDetails[
                                                                  'total_price']
                                                              .toString() +
                                                          (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      maxFontSize:
                                                          Constants.fontSize +
                                                              2,
                                                      minFontSize:
                                                          Constants.fontSize,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        AutoSizeText(
                                          'Price: '.tr() +
                                              (orderDetails['total_price'] + 0)
                                                  .toString() +
                                              (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                          style: TextStyle(
                                              color: Constants.identityColor,
                                              height: 1.5),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ),
                                        (orderDetails['delivery_cost'] !=
                                                    null) ||
                                                (orderDetails[
                                                            'delivery_cost'] ==
                                                        null &&
                                                    orderDetails['status']
                                                            .toString() ==
                                                        'Delivered')
                                            ? AutoSizeText(
                                                orderDetails['delivery_cost'] !=
                                                        null
                                                    ? 'Delivery Cost: '.tr() +
                                                        orderDetails[
                                                                'delivery_cost']
                                                            .toString() +
                                                        (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() )
                                                    : 'Delivery Cost: '.tr() +
                                                        0.toString() +
                                                        (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                                style: TextStyle(
                                                    color:
                                                        Constants.identityColor,
                                                    height: 1.5),
                                                maxFontSize:
                                                    Constants.fontSize - 2,
                                                minFontSize:
                                                    Constants.fontSize - 4,
                                              )
                                            : Container(),
                                        (orderDetails['delivery_cost'] !=
                                                    null) ||
                                                (orderDetails[
                                                            'delivery_cost'] ==
                                                        null &&
                                                    orderDetails['status']
                                                            .toString() ==
                                                        'Delivered')
                                            ? AutoSizeText(
                                                orderDetails['delivery_cost'] !=
                                                        null
                                                    ? 'Total Price: '.tr() +
                                                        (orderDetails[
                                                                    'total_price'] +
                                                                orderDetails[
                                                                    'delivery_cost'])
                                                            .toString() +
                                                        (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() )
                                                    : 'Total Price: '.tr() +
                                                        (orderDetails[
                                                                    'total_price'] +
                                                                0)
                                                            .toString() +
                                                        (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                                style: TextStyle(
                                                    color:
                                                        Constants.identityColor,
                                                    height: 1.5),
                                                maxFontSize:
                                                    Constants.fontSize - 2,
                                                minFontSize:
                                                    Constants.fontSize - 4,
                                              )
                                            : Container(),
                                        AutoSizeText(
                                          'Address: '.tr() +
                                              orderDetails['address'],
                                          style: TextStyle(height: 1.6),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ),
                                        AutoSizeText(
                                          'Created Date: '.tr() +
                                              orderDetails['date'],
                                          style: TextStyle(height: 1.6),
                                          maxFontSize: Constants.fontSize - 2,
                                          minFontSize: Constants.fontSize - 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        /***
                         *
                         *
                         * Products
                         *
                         */

                        orderDetails['products'].length == 0
                            ? Container()
                            : Column(
                                children: List.generate(
                                    orderDetails['products'].length, (index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: Constants.padding),
                                    child: OrderDetailsItemWidget(
                                      itemId: orderDetails['products'][index]
                                              ['id']
                                          .toString(),
                                      name: arabicLanguage
                                          ? orderDetails['products'][index]
                                              ['name_ar']
                                          : orderDetails['products'][index]
                                              ['name_en'],
                                      price: orderDetails['products'][index]
                                              ['price']
                                          .toString(),
                                      quantity: orderDetails['products'][index]
                                              ['quantity']
                                          .toString(),
                                      thumbnail: orderDetails['products'][index]
                                              ['thumbnail']
                                          .toString(),
                                      availability: orderDetails['products']
                                                  [index]['available'] ==
                                              0
                                          ? false
                                          : true,
                                      variant: orderDetails['products'][index]
                                          ['variant'],
                                      onPressedOnView: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProductPage(
                                                    id: orderDetails['products']
                                                            [index]['id']
                                                        .toString(),
                                                    // nameEn: orderDetails['products'][index]['name_en'],
                                                    // nameAr: orderDetails['products'][index]['name_ar'],
                                                  ))),
                                    ),
                                  );
                                }),
                              ),

                        /***
                         *
                         *
                         * Offers
                         *
                         */

                        orderDetails['offers'].length == 0
                            ? Container()
                            : Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: Constants.padding),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.doublePadding),
                                alignment: arabicLanguage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: AutoSizeText(
                                  'Offers'.tr(),
                                  style: TextStyle(
                                      color: Constants.identityColor,
                                      fontWeight: FontWeight.bold),
                                  minFontSize: Constants.fontSize + 2,
                                  maxFontSize: Constants.fontSize + 4,
                                ),
                              ),
                        orderDetails['offers'].length == 0
                            ? Container()
                            : Column(
                                children: List.generate(
                                    orderDetails['offers'].length, (index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        bottom: Constants.padding),
                                    child: OrderDetailsItemWidget(
                                      itemId: orderDetails['offers'][index]
                                              ['id']
                                          .toString(),
                                      name: arabicLanguage
                                          ? orderDetails['offers'][index]
                                              ['name_ar']
                                          : orderDetails['offers'][index]
                                              ['name_en'],
                                      price: orderDetails['offers'][index]
                                              ['price']
                                          .toString(),
                                      quantity: orderDetails['offers'][index]
                                              ['quantity']
                                          .toString(),
                                      thumbnail: orderDetails['offers'][index]
                                              ['thumbnail']
                                          .toString(),
                                      availability: orderDetails['offers']
                                                  [index]['available'] ==
                                              0
                                          ? false
                                          : true,
                                      variant: null,
                                      onPressedOnView: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => OfferPage(
                                                    id: orderDetails['offers']
                                                            [index]['id']
                                                        .toString(),
                                                  ))),
                                    ),
                                  );
                                }),
                              ),

                        /***
                         *
                         *
                         * Unavailable items if any
                         *
                         */

                        orderDetails['unavailable_items'].length != 0 &&
                                orderDetails['status'] ==
                                    'Waiting For Customer Action'
                            ? Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: Constants.padding),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.doublePadding),
                                alignment: arabicLanguage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: AutoSizeText(
                                  'The unavailable items in the order'.tr(),
                                  style: TextStyle(
                                      color: Constants.identityColor,
                                      fontWeight: FontWeight.bold),
                                  minFontSize: Constants.fontSize + 2,
                                  maxFontSize: Constants.fontSize + 4,
                                ),
                              )
                            : Container(),
                        orderDetails['unavailable_items'].length != 0 &&
                                orderDetails['status'] ==
                                    'Waiting For Customer Action'
                            ? Container(
                                margin:
                                    EdgeInsets.only(bottom: Constants.padding),
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.doublePadding,
                                    vertical: Constants.padding),
                                alignment: arabicLanguage
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Constants.borderRadius),
                                  color: Constants.identityColor,
                                ),
                                child: Column(
                                    children: List.generate(
                                        orderDetails['unavailable_items']
                                            .length, (index) {
                                  return Container(
                                      child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical:
                                                    Constants.halfPadding),
                                            child: AutoSizeText(
                                              arabicLanguage
                                                  ? orderDetails[
                                                          'unavailable_items']
                                                      [index]['name_ar']
                                                  : orderDetails[
                                                          'unavailable_items']
                                                      [index]['name_en'],
                                              style: TextStyle(
                                                color: Constants.whiteColor,
                                              ),
                                              maxFontSize: Constants.fontSize,
                                              minFontSize:
                                                  Constants.fontSize - 2,
                                            ),
                                          )
                                        ],
                                      ),
                                      index !=
                                              orderDetails['unavailable_items']
                                                      .length -
                                                  1
                                          ? Divider(
                                              color: Constants.whiteColor,
                                              thickness: 2,
                                            )
                                          : Container()
                                    ],
                                  ));
                                })),
                              )
                            : Container(),
                        orderDetails['notes'] != null
                            ? Stack(
                                children: [
                                  Container(
                                    width: containerWidth,
                                    height: containerHeight / 2,
                                    padding:
                                        EdgeInsets.all(15),
                                    margin: EdgeInsets.only(
                                        bottom: Constants.padding,
                                        top: containerHeight / 6.5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                Constants.borderRadius)),
                                        color: Constants.whiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[400]!,
                                            blurRadius: 5,
                                            offset: Offset(0, 0),
                                          )
                                        ]),
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(bottom: 5, top: 10),
                                      child: AutoSizeText(
                                        orderDetails['notes'],
                                        style: TextStyle(
                                          color: Constants.identityColor,
                                        ),
                                        minFontSize: Constants.fontSize - 4,
                                        maxFontSize: Constants.fontSize - 2,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    child: Container(
                                      width: containerWidth,
                                      // height: headerHeight,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  Constants.borderRadius)),
                                          color: Constants.whiteColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[400]!,
                                              blurRadius: 5,
                                              offset: Offset(0, 0),
                                            )
                                          ]),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                        child: AutoSizeText(
                                          'Notes'.tr(),
                                          style: TextStyle(
                                              color: Constants.identityColor,
                                              fontWeight: FontWeight.bold),
                                          minFontSize: Constants.fontSize,
                                          maxFontSize: Constants.fontSize + 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),

                        /***
                         *
                         *
                         * Action Buttons
                         *
                         */

                        orderDetails['status'] ==
                                    'Waiting For Customer Action' ||
                                orderDetails['status'] == 'Pending'
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.padding),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: Constants.padding),
                                      alignment: Alignment.center,
                                      child: ButtonTheme(
                                        minWidth: containerWidth / 2,
                                        height: 50,
                                        padding: EdgeInsets.symmetric(
                                            vertical: Constants
                                                .buttonsVerticalPadding),
                                        child: RaisedButton(
                                          color: Color(0xFF00A3B3),
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Constants.borderRadius)),
                                          child: AutoSizeText(
                                            'Update Order'.tr(),
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                                fontWeight: FontWeight.bold),
                                            maxFontSize: Constants.fontSize,
                                            minFontSize: Constants.fontSize - 2,
                                          ),
                                          onPressed: () {
                                            CustomDialog(
                                              context: context,
                                              title: "Warning".tr(),
                                              message:
                                                  "Are you sure you want to update this order?"
                                                      .tr(),
                                              okButtonTitle: 'Ok'.tr(),
                                              cancelButtonTitle: 'Cancel'.tr(),
                                              onPressedCancelButton: () {
                                                Navigator.pop(context);
                                              },
                                              onPressedOkButton: () =>
                                                  updateOrder(widget.orderId),
                                              color: Color(0xFFFFB300),
                                              icon: "assets/images/warning.svg",
                                            ).showCustomDialog();
                                          },
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(
                                          top: Constants.padding),
                                      alignment: Alignment.center,
                                      child: ButtonTheme(
                                        minWidth: containerWidth / 2,
                                        height: 50,
                                        padding: EdgeInsets.symmetric(
                                            vertical: Constants
                                                .buttonsVerticalPadding),
                                        child: RaisedButton(
                                          color: Constants.redColor,
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Constants.borderRadius)),
                                          child: AutoSizeText(
                                            'Cancel Order'.tr(),
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                                fontWeight: FontWeight.bold),
                                            maxFontSize: Constants.fontSize,
                                            minFontSize: Constants.fontSize - 2,
                                          ),
                                          onPressed: () {
                                            CustomDialog(
                                              context: context,
                                              title: "Warning".tr(),
                                              message:
                                                  "Are you sure you want to cancel this order?"
                                                      .tr(),
                                              okButtonTitle: 'Yes'.tr(),
                                              cancelButtonTitle: 'No'.tr(),
                                              onPressedCancelButton: () {
                                                Navigator.pop(context);
                                              },
                                              onPressedOkButton: () =>
                                                  cancelOrder(widget.orderId),
                                              color: Color(0xFFFFB300),
                                              icon: "assets/images/warning.svg",
                                            ).showCustomDialog();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container()
                      ],
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  getOrderDetails(String orderId) async {
    final String url = 'get-order-details?order_id=$orderId';
    final response = await http.get(Uri.parse(Constants.apiUrl + url),
        headers: {'referer': Constants.apiReferer});

    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        print('order details: ' + data['data'].toString());
        return data['data'];
      }
      return data['message'].toString();
    }

    return Constants.requestErrorMessage;
  }

  updateOrder(String orderId) async {
    setState(() => isLoading = 1);

    final String url = 'update-order?order_id=$orderId';
    final response = await http.post(Uri.parse(Constants.apiUrl + url),
        headers: {'referer': Constants.apiReferer});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        data = data['data'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(Constants.keyOrderIDToUpdate, orderId);

        List products = data['products'];
        List offers = data['offers'];
        int itemsCount = products.length + offers.length;

        if (products == null) {
          prefs.setStringList(Constants.keyProductsIDsInCart, []);
          prefs.setStringList(Constants.keyProductsQuantitiesInCart, []);
          prefs.setStringList(Constants.keyProductsVariantsInCart, []);
        } else {
          List<String> productsIDs = [];
          List<String> productsQuantities = [];
          List<String> productsVariants = [];

          for (int i = 0; i < products.length; i++) {
            productsIDs.add(products[i]['id'].toString());
            productsQuantities.add(products[i]['quantity'].toString());
            productsVariants.add(products[i]['variant'].toString());
          }

          prefs.setStringList(Constants.keyProductsIDsInCart, productsIDs);
          prefs.setStringList(
              Constants.keyProductsQuantitiesInCart, productsQuantities);
          prefs.setStringList(
              Constants.keyProductsVariantsInCart, productsVariants);
        }

        if (offers == null) {

          prefs.setStringList(Constants.keyOffersIDsInCart, []);
          prefs.setStringList(Constants.keyOffersQuantitiesInCart, []);
          prefs.setStringList(Constants.keyOffersProductsVariants, []);
        } else {
          List<String> offersIDs = [];
          List<String> offersQuantities = [];
          List<String> offersProductsVariants = [];

          for (int i = 0; i < offers.length; i++) {
            offersIDs.add(offers[i]['id'].toString());
            offersQuantities.add(offers[i]['quantity'].toString());
            offersProductsVariants.add(offers[i]['variant'].toString());
          }

          prefs.setStringList(Constants.keyOffersIDsInCart, offersIDs);
          prefs.setStringList(
              Constants.keyOffersQuantitiesInCart, offersQuantities);
          prefs.setStringList(
              Constants.keyOffersProductsVariants, offersProductsVariants);
        }

        prefs.setInt(Constants.keyNumberOfItemsInCart, itemsCount);

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CartPage(fromSideMenu: false,))).then(
              (value) => setState(() {
            itemsInCart =
                prefs.getInt(Constants.keyNumberOfItemsInCart);
          }),
        );
      } else {
        CustomDialog(
          context: context,
          title: 'Warning'.tr(),
          message: data['message'].toString().tr(),
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
      }
    }

    setState(() => isLoading = 0);
    return Constants.requestErrorMessage;
  }

  cancelOrder(String orderId) async {
    setState(() => isLoading = 1);

    final String url = 'cancel-order?order_id=$orderId';
    final response = await http.post(Uri.parse(Constants.apiUrl + url),
        headers: {'referer': Constants.apiReferer});

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['status']) {
        final prefs = await SharedPreferences.getInstance();
        if (orderId == prefs.getString(Constants.keyOrderIDToUpdate)) {
          prefs.remove(Constants.keyOrderIDToUpdate);
        }
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        CustomDialog(
          context: context,
          title: 'Warning'.tr(),
          message: data['message'].toString().tr(),
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
      }
    }

    setState(() => isLoading = 0);
    return Constants.requestErrorMessage;
  }
}
