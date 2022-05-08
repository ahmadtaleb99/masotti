import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import '../assets/flutter_custom_icons.dart';
import '../assets/my_flutter_app_icons.dart';
import '../widgets/product_page_appbar.dart';
import '../widgets/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:convert';
import './login.dart';
import './product_quantity_and_variant.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/alert_dialog.dart';
import '../widgets/request_empty_data.dart';
import '../models/product.dart';
import 'package:share/share.dart';

import 'cart.dart';

class ProductPage extends StatefulWidget {
  final String? id;

  ProductPage({
    required this.id,
  });

  @override
  State<StatefulWidget> createState() =>
      ProductPageState(
        id: this.id,
      );
}

class ProductPageState extends State<ProductPage> {
  String? id;

  bool arabicLanguage = false;
  bool authenticated = false;
  bool? accountIsActive = false;
  late Product tempProduct;
  Future? future;
  int? itemsInCart = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> colors = [];
  List<String> sizeColorsList = [];
  List<String> sizes = [];
  var existedColor = [];
  var isSelectedColors =[];
  List<bool> existedColorList = [];
  var isSelectedColorsList =[];
  String? selectedSize;
  String? selectedColor;

  ProductPageState({
    required this.id,
  });

  getSizeColors(String? sizeValue, Product product) {
    List<bool> existedSize =[];
    var isSelectedSizes =[];
    selectedColor = null;

    print( product.variants!.length.toString() + ' variants  : ');
    print( product.variants!.toString() + ' variants  : ');
    for (int i = 0; i < product.variants!.length; i++) {
      existedSize.add(false);
      isSelectedSizes.add(false);
    }
    existedColorList.clear();
    isSelectedColorsList.clear();
    sizeColorsList.clear();
    existedColorList.addAll(existedSize.toList());
    print(existedColorList);
    isSelectedColorsList.addAll(isSelectedSizes);

    for (int variantIndex = 0;
    variantIndex < product.variants!.length;
    variantIndex++) {
      for (int colorIndex = 0;
      colorIndex <
          product.variants!.values
              .elementAt(variantIndex)
              .length;
      colorIndex++) {
        String color = product.variants!.values
            .elementAt(variantIndex)[colorIndex]['color']
            .toString();
        String size =
        product.variants!.keys.elementAt(variantIndex).toString();
        if (!sizeColorsList.contains(color) && sizeValue == size) {
          sizeColorsList.add(color);
        }
      }
    }
    log('colors :::: ${colors.toString()}    sizeColorsList :::: ${sizeColorsList.toString()}     existedColorList :::: ${existedColorList.toString()}');

    log(' lengths : : : :: colors :::: ${colors.length}    sizeColorsList :::: ${sizeColorsList.length}     existedColorList :::: ${existedColorList.length}');

    for (int i = 0; i < colors.length; i++) {
      log('i is $i');
      for (int j = 0; j < sizeColorsList.length; j++)  {
        log('j is $j');
        if (colors[i] == sizeColorsList[j])
        {
          log('match');
          existedColorList[i] = true;
          log('match');

        }
        log(' no  match');

      }
      log('colors :::: ${colors.toString()}    sizeColorsList :::: ${sizeColorsList.toString()}     existedColorList :::: ${existedColorList.toString()}');

    }
    print('hom');
    print(sizeColorsList.toString());
  }

  void getProductSizeList(Product product) {
    print('getProductSizeList');
    if (product.variants != null) {
      for (int i = 0; i < product.variants!.length; i++) {
        if (product.variants!.keys != null) {
          sizes.add(product.variants!.keys.elementAt(i).toString());
        }
      }
      selectedSize = sizes[0];
      for (int variantIndex = 0;
      variantIndex < product.variants!.length;
      variantIndex++) {
        for (int colorIndex = 0;
        colorIndex <
            product.variants!.values
                .elementAt(variantIndex)
                .length;
        colorIndex++) {
          String color = product.variants!.values
              .elementAt(variantIndex)[colorIndex]['color']
              .toString();
          if (!colors.contains(color)) {
            colors.add(color);
          }
        }
      }
      getSizeColors(selectedSize, product);
    }
  }

  void selectColor(int index) {
    if (isSelectedColorsList[index]) {} else {
      isSelectedColorsList[index] = true;
      for (int i = 0; i < isSelectedColorsList.length; i++) {
        if (i != index) {
          isSelectedColorsList[i] = false;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCustomerRequiredInfo();
    future = getProduct(id);
  }

  getCustomerRequiredInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authenticated =
      prefs.getString(Constants.keyAccessToken) != null ? true : false;
      accountIsActive = prefs.getBool(Constants.keyAccountStatus);
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
    });
  }

  addToCartBottomSheet(context) async {
    final prefs = await SharedPreferences.getInstance();
    if (authenticated && accountIsActive!) {
      await showModalBottomSheet(
          backgroundColor: Constants.whiteColor,
          context: context,
          builder: (context) =>
              ProductQuantityAndVariant(
                id: tempProduct.id,
                nameEn: tempProduct.nameEn,
                nameAr: tempProduct.nameAr,
                price: tempProduct.price,
                salesPrice: tempProduct.salesPrice,
                dropDownVariants: tempProduct.dropDownVariants,
                variants: tempProduct.variants,
                selectedColor: selectedColor,
                selectedSize: selectedSize,
                scaffoldKey: _scaffoldKey,
              )).then((value) => setState(() {}));
      setState(() {
        itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      });
    } else if (authenticated && !accountIsActive!) {
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
    } else {
      CustomDialog(
        context: context,
        title: 'Authentication Required'.tr(),
        message: 'Authentication Required Message'.tr(),
        okButtonTitle: 'Login'.tr(),
        cancelButtonTitle: 'Cancel'.tr(),
        onPressedCancelButton: () {
          Navigator.pop(context);
        },
        onPressedOkButton: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LoginPage.withRedirect(
                      redirectToCartPage: true,
                    ),
              )).then((value) =>
              setState(() {
                authenticated =
                prefs.getString(Constants.keyAccessToken) != null
                    ? true
                    : false;
                accountIsActive =
                    prefs.getBool(Constants.keyAccountStatus);
                itemsInCart =
                    prefs.getInt(Constants.keyNumberOfItemsInCart);
              }));
        },
        color: Color(0xFFFFB300),
        icon: "assets/images/warning.svg",
      ).showCustomDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery
            .of(context)
            .size
            .width - (Constants.doublePadding);
    double spacing = containerWidth / 25;
    double productContainerWidth = containerWidth / 100 * 48;
    double productContainerHeight = containerWidth + (containerWidth / 100 * 5);
    double colorSizeContainerWidth = containerWidth / 100 * 15;
    arabicLanguage =
    Localizations
        .localeOf(context)
        .languageCode == 'ar' ? true : false;


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.whiteColor,
      drawer: SideMenu(),
      body: FutureBuilder(
          future: future,
          builder: (context, snap) {
            if (!snap.hasData) {
              return Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  child: Center(
                    child: ColoredCircularProgressIndicator(),
                  ));
            }
            dynamic response = snap.data;
            if (response is String) {
              return SafeArea(
                child: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  child: Center(
                    child: RequestEmptyData(
                      message: response,
                    ),
                  ),
                ),
              );
            }
            Product product = response as Product;
            return SingleChildScrollView(
                child: Stack(overflow: Overflow.visible, children: <Widget>[
                  ProductPageAppBarWidget(
                      height: (MediaQuery
                          .of(context)
                          .size
                          .width / 4 * 3) +
                          ((MediaQuery
                              .of(context)
                              .size
                              .width / 4 * 3) / 10 * 2),
                      icon: MyFlutterApp.component_1___79,
                      product: product,
                      scaffoldKey: _scaffoldKey),
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery
                          .of(context)
                          .size
                          .width / 4 * 3 +
                          ((MediaQuery
                              .of(context)
                              .size
                              .width / 4 * 3) / 10) -
                          25,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        child: Container(
                          color: Constants.whiteColor,
                          padding: EdgeInsets.only(
                              top: Constants.padding,
                              right: Constants.padding,
                              left: Constants.padding),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: AutoSizeText(
                                        arabicLanguage
                                            ? product.nameAr!.toUpperCase()
                                            : product.nameEn!.toUpperCase(),
                                        style: TextStyle(
                                            color: Constants.redColor,
                                            fontWeight: FontWeight.bold),
                                        minFontSize: Constants.fontSize + 2,
                                        maxFontSize: Constants.fontSize + 4,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: product.salesPrice == 'null'
                                          ? Align(
                                        alignment: arabicLanguage
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: AutoSizeText(
                                          product.price! + 'Currency'.tr(),
                                          style: TextStyle(
                                              color:
                                              Constants.identityColor,
                                              fontWeight: FontWeight.bold),
                                          minFontSize: Constants.fontSize,
                                          maxFontSize:
                                          Constants.fontSize + 2,
                                        ),
                                      )
                                          : Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: <Widget>[
                                              // AutoSizeText(
                                              //   'Before sales'.tr() + ': ',
                                              //   style: TextStyle(
                                              //     color: Constants
                                              //         .identityColor,
                                              //   ),
                                              //   minFontSize: Constants.fontSize,
                                              //   maxFontSize: Constants.fontSize + 2,
                                              // ),
                                              AutoSizeText(
                                                product.price! +
                                                    'Currency'.tr(),
                                                style: TextStyle(
                                                  color: Constants
                                                      .identityColor,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                                minFontSize:
                                                Constants.fontSize,
                                                maxFontSize:
                                                Constants.fontSize + 2,
                                              )
                                            ],
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: Constants.halfPadding),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: <Widget>[
                                                // AutoSizeText(
                                                //   'After sales'.tr() + ': ',
                                                //   style: TextStyle(
                                                //     fontWeight: FontWeight
                                                //         .bold,
                                                //     color: Constants.redColor,
                                                //   ),
                                                //   minFontSize: Constants.fontSize,
                                                //   maxFontSize: Constants.fontSize + 2,
                                                // ),
                                                AutoSizeText(
                                                  product.salesPrice +
                                                      'Currency'.tr(),
                                                  style: TextStyle(
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color:
                                                    Constants.redColor,
                                                  ),
                                                  minFontSize:
                                                  Constants.fontSize,
                                                  maxFontSize:
                                                  Constants.fontSize +
                                                      2,
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: containerWidth,
                                  padding: EdgeInsets.symmetric(
                                      vertical: Constants.padding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: Constants.padding),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            AutoSizeText(
                                              'Details'.tr(),
                                              style: TextStyle(
                                                  color: Constants
                                                      .identityColor,
                                                  fontWeight: FontWeight
                                                      .bold),
                                              minFontSize: Constants.fontSize,
                                              maxFontSize: Constants
                                                  .fontSize + 2,
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  Share.share(
                                                      'https://masotti.com/products/' +
                                                          product.id),
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      left:
                                                      Constants.halfPadding),
                                                  child: Icon(
                                                    MyFlutterApp.share,
                                                    color: Constants.redColor,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      HtmlWidget(arabicLanguage
                                          ? product.detailsAr!
                                          : product.detailsEn!),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: containerWidth,
                                  padding: EdgeInsets.symmetric(
                                      vertical: Constants.padding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: Constants.halfPadding),
                                        child: AutoSizeText(
                                          'Sizes'.tr(),
                                          style: TextStyle(
                                              color: Constants.identityColor,
                                              fontWeight: FontWeight.bold),
                                          minFontSize: Constants.fontSize,
                                          maxFontSize: Constants.fontSize + 2,
                                        ),
                                      ),
                                      Container(
                                        height: colorSizeContainerWidth / 1.3,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: List.generate(
                                              product.variants!.length,
                                                  (variantIndex) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedSize =
                                                      sizes[variantIndex];
                                                      getSizeColors(
                                                          product.variants!.keys
                                                              .elementAt(
                                                              variantIndex)
                                                              .toString(),
                                                          product);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        Constants
                                                            .halfPadding / 2),
                                                    child: Container(
                                                      width: colorSizeContainerWidth,
                                                      height:
                                                      colorSizeContainerWidth /
                                                          2,
                                                      alignment: Alignment
                                                          .center,
                                                      padding: EdgeInsets.all(
                                                          5),
                                                      margin: arabicLanguage
                                                          ? EdgeInsets.only(
                                                          left: Constants
                                                              .halfPadding /
                                                              2)
                                                          : EdgeInsets.only(
                                                          right: Constants
                                                              .halfPadding /
                                                              2),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  Constants
                                                                      .borderRadius /
                                                                      2)),
                                                          border: Border.all(
                                                              width: selectedSize ==
                                                                  product
                                                                      .variants!
                                                                      .keys
                                                                      .elementAt(
                                                                      variantIndex)
                                                                      .toString()
                                                                  ? 2
                                                                  : 1,
                                                              color:
                                                              selectedSize ==
                                                                  product
                                                                      .variants!
                                                                      .keys
                                                                      .elementAt(
                                                                      variantIndex)
                                                                      .toString()
                                                                  ? Constants
                                                                  .redColor
                                                                  : Constants
                                                                  .greyColor)),
                                                      child: AutoSizeText(
                                                        product.variants!.keys
                                                            .elementAt(
                                                            variantIndex)
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Constants
                                                                .greyColor,
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
                                                  ),
                                                );
                                              }),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: containerWidth,
                                  padding: EdgeInsets.symmetric(
                                      vertical: Constants.padding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.only(
                                            bottom: Constants.halfPadding),
                                        child: AutoSizeText(
                                          'Colors'.tr(),
                                          style: TextStyle(
                                              color: Constants.identityColor,
                                              fontWeight: FontWeight.bold),
                                          minFontSize: Constants.fontSize,
                                          maxFontSize: Constants.fontSize + 2,
                                        ),
                                      ),
                                      Container(
                                        height: colorSizeContainerWidth,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: List.generate(
                                              colors.length,
                                                  (colorIndex) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      if (existedColorList[
                                                      colorIndex]) {
                                                        selectColor(colorIndex);
                                                        selectedColor =
                                                        colors[colorIndex];
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        Constants
                                                            .halfPadding - 4),
                                                    alignment: Alignment
                                                        .center,
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Icon(
                                                            Icons
                                                                .brightness_1,
                                                            size: selectedColor ==
                                                                colors[colorIndex]
                                                                ? 37
                                                                : 31,
                                                            color: Colors
                                                                .grey[400]),
                                                        Positioned(
                                                          left: 0,
                                                          right: 0,
                                                          bottom: 0,
                                                          top: 0,
                                                          child: Stack(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .brightness_1,
                                                                  size: selectedColor ==
                                                                      colors[colorIndex]
                                                                      ? 36
                                                                      : 30,
                                                                  color: Color(
                                                                      int
                                                                          .parse(
                                                                          '0xFF' +
                                                                              colors[colorIndex]))
                                                              ),
                                                              !existedColorList[
                                                              colorIndex]
                                                                  ? Positioned(
                                                                left: 0,
                                                                right: 0,
                                                                bottom: 0,
                                                                top: 0,
                                                                child: Stack(
                                                                  children: [
                                                                    Positioned(
                                                                      left: 0,
                                                                      right: 0,
                                                                      bottom: 0,
                                                                      top: 0,
                                                                      child: Icon(
                                                                          Icons
                                                                              .close_outlined,
                                                                          size: 21,
                                                                          color: Colors
                                                                              .black
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      left: 0,
                                                                      right: 0,
                                                                      bottom: 0,
                                                                      top: 0,
                                                                      child: Icon(
                                                                          Icons
                                                                              .close_outlined,
                                                                          size: 20,
                                                                          color: Colors
                                                                              .white
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                                  : selectedColor ==
                                                                  colors[colorIndex]
                                                                  ? Positioned(
                                                                left: 0,
                                                                right: 0,
                                                                bottom: 0,
                                                                top: 0,
                                                                child: Stack(
                                                                  children: [
                                                                    Positioned(
                                                                      left: 0,
                                                                      right: 0,
                                                                      bottom: 0,
                                                                      top: 0,
                                                                      child: Icon(
                                                                          Icons
                                                                              .check,
                                                                          size: 26,
                                                                          color: Colors
                                                                              .black
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      left: 0,
                                                                      right: 0,
                                                                      bottom: 0,
                                                                      top: 0,
                                                                      child: Icon(
                                                                          Icons
                                                                              .check,
                                                                          size: 25,
                                                                          color: Colors
                                                                              .white
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: containerWidth,
                                  padding: EdgeInsets.symmetric(
                                      vertical: Constants.halfPadding),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      product.relatedProducts!.length > 0
                                          ? Container(
                                        padding: EdgeInsets.only(
                                            bottom:
                                            Constants.halfPadding / 2),
                                        child: AutoSizeText(
                                          'Related Products'.tr(),
                                          style: TextStyle(
                                              color:
                                              Constants.identityColor,
                                              fontWeight: FontWeight.bold),
                                          minFontSize: Constants.fontSize,
                                          maxFontSize:
                                          Constants.fontSize + 2,
                                        ),
                                      )
                                          : Container(),
                                      product.relatedProducts!.length > 0
                                          ? Container(
                                        height:
                                        productContainerWidth / 4 * 3 +
                                            productContainerHeight / 7,
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          children: List.generate(
                                              product.relatedProducts!
                                                  .length, (index) {
                                            return GestureDetector(
                                              onTap: () =>
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductPage(
                                                                id: product
                                                                    .relatedProducts![
                                                                index]
                                                                ['id']
                                                                    .toString(),
                                                              ))),
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: spacing -
                                                        (MediaQuery
                                                            .of(context)
                                                            .devicePixelRatio >
                                                            1.2
                                                            ? 0
                                                            : 0),
                                                    horizontal: spacing -
                                                        (MediaQuery
                                                            .of(context)
                                                            .devicePixelRatio >
                                                            1.2
                                                            ? 10
                                                            : 0)),
                                                child: ProductWidget(
                                                    id: product
                                                        .relatedProducts![index]
                                                    ['id']
                                                        .toString(),
                                                    nameEn: product
                                                        .relatedProducts![index]
                                                    ['name_en'],
                                                    nameAr: product
                                                        .relatedProducts![index]
                                                    ['name_ar'],
                                                    imagePath:
                                                    product
                                                        .relatedProducts![index]
                                                    ['image'],
                                                    price: product
                                                        .relatedProducts![index]
                                                    ['price']
                                                        .toString(),
                                                    salesPrice: product
                                                        .relatedProducts![index]
                                                    ['sales_price']
                                                        .toString()
                                                        .toLowerCase()),
                                              ),
                                            );
                                          }),
                                        ),
                                      )
                                          : Container(),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: Constants.padding),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            ButtonTheme(
                                              minWidth: containerWidth / 2,
                                              height: 50,
                                              child: RaisedButton(
                                                color: Constants.redColor,
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        Constants
                                                            .borderRadius)),
                                                child: AutoSizeText(
                                                  'Add To Cart'.tr(),
                                                  style: TextStyle(
                                                      color: Constants
                                                          .whiteColor,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                  minFontSize:
                                                  Constants.fontSize - 2,
                                                  maxFontSize: Constants
                                                      .fontSize,
                                                ),
                                                onPressed: () =>
                                                    addToCartBottomSheet(
                                                        context),
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            authenticated
                                                ? Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                      Constants
                                                          .borderRadius))),
                                              child: Container(
                                                margin:
                                                EdgeInsets.symmetric(
                                                    horizontal: 5),
                                                child: Stack(
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () async {
                                                        final prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                        Navigator.of(
                                                            context)
                                                            .push(
                                                            MaterialPageRoute(
                                                                builder: (_) =>
                                                                    CartPage(
                                                                      fromSideMenu: false,)))
                                                            .then(
                                                              (value) =>
                                                              setState(
                                                                      () {
                                                                    itemsInCart =
                                                                        prefs
                                                                            .getInt(
                                                                            Constants
                                                                                .keyNumberOfItemsInCart);
                                                                  }),
                                                        );
                                                      },
                                                      child: Container(
                                                        color: Colors
                                                            .transparent,
                                                        alignment: Alignment
                                                            .center,
                                                        height: 50,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                            horizontal:
                                                            10),
                                                        child: Icon(
                                                            CustomIcons
                                                                .cart,
                                                            color: Constants
                                                                .redColor,
                                                            size: 22),
                                                      ),
                                                    ),
                                                    itemsInCart != null &&
                                                        itemsInCart != 0
                                                        ? Positioned(
                                                      right: 0,
                                                      top: 8,
                                                      child:
                                                      Container(
                                                        padding:
                                                        EdgeInsets
                                                            .all(
                                                            2),
                                                        alignment:
                                                        Alignment
                                                            .center,
                                                        decoration: BoxDecoration(
                                                            color: Constants
                                                                .identityColor,
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                Constants
                                                                    .borderRadius)),
                                                        constraints: BoxConstraints(
                                                            minWidth:
                                                            17,
                                                            minHeight:
                                                            15),
                                                        child:
                                                        Container(
                                                          margin: EdgeInsets
                                                              .only(
                                                              top:
                                                              2),
                                                          child: Text(
                                                            '$itemsInCart',
                                                            style: TextStyle(
                                                                color: Constants
                                                                    .whiteColor,
                                                                fontSize:
                                                                10,
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                        : Container()
                                                  ],
                                                ),
                                              ),
                                            )
                                                : Container()
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ),
                  ),
                ]));
          }),
    );
  }

  Future getProduct(productId) async {
    // AsyncMemoizer memoizer = AsyncMemoizer();
    // return memoizer.runOnce(() async {
    final String url = 'get-product?product_id=$productId';
    final response = await http.get(Uri.parse(Constants.apiUrl + url) ,
        headers: {'referer': Constants.apiReferer});

    if (response.statusCode == 200) {
      print(response.body.toString() + 'asdasdasdasd');
      var data = jsonDecode(response.body);
      if (data['status']) {
        List? variantsChoices = data['variants'];
        data = data['data'];
        Product product = Product.getProductFromData(data, variantsChoices);
        print(product.nameAr);
        print(product.nameAr);
        tempProduct = product;
        getProductSizeList(product);
        print(product.nameAr.toString());

        return product;
      }
      return data['message'].toString();
    }
    return Constants.requestErrorMessage;
    // });
  }
}
