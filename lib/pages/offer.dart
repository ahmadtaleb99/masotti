import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocalization;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:masotti/assets/flutter_custom_icons.dart';
import 'package:masotti/widgets/custom_dialog.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'dart:convert';
import 'package:form_builder_validators/form_builder_validators.dart';

import './product.dart';
import './login.dart';
import '../widgets/count_down.dart';
import '../constants.dart';

import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/offer.dart';
import '../controllers/offers_controller.dart';
import 'cart.dart';

class OfferPage extends StatefulWidget {
  final String id;

  OfferPage({required this.id});

  @override
  State<StatefulWidget> createState() => OfferPageState();
}

class OfferPageState extends State<OfferPage> {
  bool arabicLanguage = false;
  int? itemsInCart = 0;
  bool authenticated = false;
  bool? accountIsActive = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    getCustomerRequiredInfo();
  }

  getCustomerRequiredInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      authenticated =
          prefs.getString(Constants.keyAccessToken) != null ? true : false;
      accountIsActive = prefs.getBool(Constants.keyAccountStatus);
    });
  }

  Future addOfferToCart(Map<String, dynamic> productsVariants) async {
    if (authenticated && accountIsActive!) {
      final prefs = await SharedPreferences.getInstance();
      List<String>? offersIDs =
          prefs.getStringList(Constants.keyOffersIDsInCart);
      List<String>? offersQuantities =
          prefs.getStringList(Constants.keyOffersQuantitiesInCart);
      List<String>? offersProductsVariants =
          prefs.getStringList(Constants.keyOffersProductsVariants);
      int itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart) ?? 0;

      if (offersIDs == null) {
        offersIDs =[];
        offersQuantities = [];
        offersProductsVariants =[];
      }
      offersIDs.add(widget.id);
      offersQuantities!.add('1');
      offersProductsVariants!.add(jsonEncode(productsVariants));
      itemsInCart++;

      prefs.setStringList(Constants.keyOffersIDsInCart, offersIDs);
      prefs.setStringList(
          Constants.keyOffersQuantitiesInCart, offersQuantities);
      prefs.setStringList(
          Constants.keyOffersProductsVariants, offersProductsVariants);
      prefs.setInt(Constants.keyNumberOfItemsInCart, itemsInCart);

      final snackBar = SnackBar(
        content: Container(
            height: 80,
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                AutoSizeText(
                  'The offer has been added to the cart'.tr(),
                  style: TextStyle(color: Constants.whiteColor),
                  minFontSize: Constants.fontSize - 4,
                ),
              ],
            ))),
        duration: Duration(seconds: 3),
        backgroundColor: Constants.identityColor,
      );
      scaffoldKey.currentState!.showSnackBar(snackBar);
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
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
        color: Color(0xFFFFB300),
        icon: "assets/images/warning.svg",
      ).showCustomDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Offers',
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: false,
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
                future: OffersController.getOffer(widget.id),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        child: Center(
                          child: ColoredCircularProgressIndicator(),
                        ));
                  }
                  OfferWidget offer = snap.data as OfferWidget;
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                            width: containerWidth,
                            height: containerWidth / 4 * 3,
                            margin: EdgeInsets.only(bottom: Constants.padding),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Constants.borderRadius)),
                              child: Image.network(
                                Constants.apiFilesUrl + offer.imagePath!,
                                fit: BoxFit.fill,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Constants.redColor),
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
                        Row(
                          children: <Widget>[
                            Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: arabicLanguage
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  padding: arabicLanguage
                                      ? EdgeInsets.only(right: 10)
                                      : EdgeInsets.only(left: 10),
                                  child: AutoSizeText(
                                    arabicLanguage
                                        ? offer.nameAr!
                                        : offer.nameEn!,
                                    style: TextStyle(
                                        color: Constants.identityColor,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    maxFontSize: Constants.fontSize + 2,
                                    minFontSize: Constants.fontSize,
                                  ),
                                )),
                            Expanded(
                                flex: 3,
                                child: Container(
                                    child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: CountDownTimer(
                                            secondsRemaining: offer.timer,
                                            countDownTimerStyle: TextStyle(
                                                color: Constants.whiteColor,
                                                fontSize:
                                                    Constants.fontSize - 4,
                                                fontWeight: FontWeight.bold,
                                                height: 1),
                                            countDownFormatter: Constants.day,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: CountDownTimer(
                                            secondsRemaining: offer.timer,
                                            countDownTimerStyle: TextStyle(
                                                color: Constants.whiteColor,
                                                fontSize:
                                                    Constants.fontSize - 4,
                                                fontWeight: FontWeight.bold,
                                                height: 1),
                                            countDownFormatter: Constants.hours,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: CountDownTimer(
                                            secondsRemaining: offer.timer,
                                            countDownTimerStyle: TextStyle(
                                                color: Constants.whiteColor,
                                                fontSize:
                                                    Constants.fontSize - 4,
                                                fontWeight: FontWeight.bold,
                                                height: 1),
                                            countDownFormatter:
                                                Constants.minutes,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(right: 5),
                                          child: CountDownTimer(
                                            secondsRemaining: offer.timer,
                                            countDownTimerStyle: TextStyle(
                                                color: Constants.whiteColor,
                                                fontSize:
                                                    Constants.fontSize - 4,
                                                fontWeight: FontWeight.bold,
                                                height: 1),
                                            countDownFormatter:
                                                Constants.seconds,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )))
                          ],
                        ),
                        Container(
                          width: containerWidth,
                          margin: EdgeInsets.only(top: Constants.padding),
                          padding: EdgeInsets.all(Constants.halfPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: Constants.halfPadding),
                                child: AutoSizeText(
                                  'Details'.tr(),
                                  style: TextStyle(
                                      color: Constants.identityColor,
                                      fontWeight: FontWeight.bold),
                                  maxFontSize: Constants.fontSize + 2,
                                  minFontSize: Constants.fontSize,
                                ),
                              ),
                              HtmlWidget(
                                arabicLanguage
                                    ? offer.detailsAr!
                                    : offer.detailsEn!,
                                textStyle: TextStyle(
                                  fontSize: Constants.fontSize - 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: containerWidth,
                          padding: EdgeInsets.all(Constants.halfPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: Constants.halfPadding,
                                    top: Constants.halfPadding),
                                child: AutoSizeText(
                                  'Products'.tr(),
                                  style: TextStyle(
                                      color: Constants.identityColor,
                                      fontWeight: FontWeight.bold),
                                  maxFontSize: Constants.fontSize + 2,
                                  minFontSize: Constants.fontSize,
                                ),
                              ),
                              Column(children: <Widget>[
                                FormBuilder(
                                  key: formKey,
                                  child: Column(
                                    children: List.generate(
                                        offer.products!.length, (index) {
                                      return Container(
                                        width: containerWidth / 3 * 2,
                                        margin: authenticated
                                            ? EdgeInsets.only(
                                                bottom: Constants.padding / 2)
                                            : EdgeInsets.only(bottom: 0),
                                        child: Column(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () {

                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductPage(
                                                              id: offer
                                                                      .products![
                                                                  index]['id'],
                                                            ))).then(
                                                  (value) => setState(() {
                                                    getCustomerRequiredInfo();
                                                  }),
                                                );
                                              },
                                              child: Container(
                                                width: containerWidth / 3 * 2,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        Constants.padding,
                                                    vertical:
                                                        Constants.padding /
                                                            3 *
                                                            2),
                                                margin: EdgeInsets.only(
                                                    bottom: Constants.padding),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Constants
                                                            .identityColor),
                                                    borderRadius: BorderRadius
                                                        .all(Radius.circular(
                                                            Constants
                                                                .borderRadius)),
                                                    color:
                                                        Constants.whiteColor),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        arabicLanguage
                                                            ? offer.products![
                                                                    index]
                                                                ['name_ar']
                                                            : offer.products![
                                                                    index]
                                                                ['name_en'],
                                                        style: TextStyle(
                                                          color: Constants
                                                              .identityColor,
                                                        ),
                                                        maxFontSize:
                                                            Constants.fontSize -
                                                                2,
                                                        minFontSize:
                                                            Constants.fontSize -
                                                                4,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Icon(
                                                          Icons.arrow_forward,
                                                          size: 20),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            authenticated
                                                ? FormBuilderDropdown(
                                                    name: offer.products![index]
                                                        ['id'],
                                                    hint: AutoSizeText(
                                                        'Select Variant'.tr()),
                                                    validator: FormBuilderValidators.required(
                                                            errorText:
                                                                'Size & Color can\'t be empty'
                                                                    .tr()),
                                                    items:
                                                        (offer.products![index]
                                                                    ['variants']
                                                                as List)
                                                            .map((variant) {
                                                      return DropdownMenuItem<
                                                              String>(
                                                          value: variant['id']
                                                              .toString(),
                                                          child: Container(
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    width: 60,
                                                                    height: 30,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(Constants
                                                                                .borderRadius)),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black87)),
                                                                    child: Text(
                                                                      variant[
                                                                          'size'],
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Text(
                                                                      '&',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets
                                                                        .all(5),
                                                                    width: 60,
                                                                    height: 30,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(Constants
                                                                                .borderRadius)),
                                                                        color: Color(int.parse('0xFF' +
                                                                            variant['color'])),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.grey[600]!,
                                                                            blurRadius:
                                                                                3,
                                                                            offset:
                                                                                Offset(1, 1),
                                                                          ),
                                                                        ]),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ));
                                                    }).toList(),
                                                  )
                                                : Container()
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                )
                              ])
                            ],
                          ),
                        ),
                        Container(
                          width: containerWidth,
                          padding: EdgeInsets.all(Constants.halfPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    bottom: Constants.halfPadding),
                                child: AutoSizeText(
                                  'Price'.tr(),
                                  style: TextStyle(
                                      color: Constants.identityColor,
                                      fontWeight: FontWeight.bold),
                                  maxFontSize: Constants.fontSize + 2,
                                  minFontSize: Constants.fontSize,
                                ),
                              ),
                              AutoSizeText(
                                offer.newPrice + (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                style: TextStyle(
                                  color: Constants.identityColor,
                                ),
                                maxFontSize: Constants.fontSize - 2,
                                minFontSize: Constants.fontSize - 4,
                              ),
                            ],
                          ),
                        ),
                        offer.hasBeenExpired!
                            ? Container()
                            : Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: Constants.padding),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ButtonTheme(
                                      minWidth: containerWidth / 2,
                                      child: RaisedButton(
                                          padding: EdgeInsets.symmetric(
                                              vertical: Constants.padding),
                                          color: Constants.redColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Constants.borderRadius)),
                                          child: AutoSizeText(
                                            'Add To Cart'.tr(),
                                            style: TextStyle(
                                              color: Constants.whiteColor,
                                            ),
                                            maxFontSize: Constants.fontSize,
                                          ),
                                          onPressed: () async {
                                            if (formKey.currentState!
                                                .saveAndValidate()) {
                                              await addOfferToCart(formKey
                                                      .currentState!.value)
                                                  .then((value) => setState(() {
                                                        getCustomerRequiredInfo();
                                                      }));
                                            }
                                          }),
                                    ),
                                    SizedBox(width: 5),
                                    authenticated
                                        ? Card(
                                            elevation: 4,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(Constants
                                                        .borderRadius))),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              child: Stack(
                                                children: <Widget>[
                                                  InkWell(
                                                    onTap: () async {
                                                      final prefs =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      Navigator.of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                                  builder: (_) =>
                                                                      CartPage(
                                                                        fromSideMenu:
                                                                            false,
                                                                      )))
                                                          .then(
                                                            (value) =>
                                                                setState(() {
                                                              itemsInCart = prefs
                                                                  .getInt(Constants
                                                                      .keyNumberOfItemsInCart);
                                                            }),
                                                          );
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      alignment:
                                                          Alignment.center,
                                                      height: 50,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10),
                                                      child: Icon(
                                                          CustomIcons.cart,
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
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    2),
                                                            alignment: Alignment
                                                                .center,
                                                            decoration: BoxDecoration(
                                                                color: Constants
                                                                    .identityColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Constants
                                                                            .borderRadius)),
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        17,
                                                                    minHeight:
                                                                        15),
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(top: 2),
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
                  );
                },
              )),
        ),
      ),
    );
  }
}
