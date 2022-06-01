import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocalization;
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/offer.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/count_down.dart';
import '../controllers/offers_controller.dart';
import './offer.dart';
import 'home_page.dart';

class OffersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => OffersPageState();
}

class OffersPageState extends State<OffersPage> {
  String? orderBy = 'End Date';
  bool arabicLanguage = false;
  int? itemsInCart = 0;
  bool authenticated = false;

  @override
  void initState() {
    super.initState();
    getItemsInCartCount();
  }

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      authenticated =
          prefs.getString(Constants.keyAccessToken) != null ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageHeight = containerWidth / 4 * 3;
    double containerHeight = imageHeight + (imageHeight / 4);
    double footerAreaHeight = imageHeight / 4;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Offers',
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: authenticated ? true : false,
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
            width: MediaQuery.of(context).size.width,
            child: FutureBuilder(
              future: OffersController.getOffers(orderBy!),
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
                List<OfferWidget> offers = response as List<OfferWidget>;
                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(top: Constants.padding),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: containerWidth,
                            height: 60,
                            child: Stack(
                              children: <Widget>[
                                // Positioned(
                                //   bottom: 0,
                                //   child: Container(
                                //     width: containerWidth,
                                //     height: 60,
                                //     decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.all(
                                //             Radius.circular(
                                //                 Constants.borderRadius)),
                                //         color: Constants.redColor),
                                //   ),
                                // ),
                                Container(
                                    width: containerWidth,
                                    height: 55,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                Constants.borderRadius)),
                                        color: Constants.whiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[500]!,
                                            blurRadius: 5,
                                            offset: Offset(0, 0),
                                          ),
                                        ]),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.only(top: 5),
                                            child: Text(
                                              'Sort By'.tr(),
                                              style: TextStyle(
                                                color: Constants.identityColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    Constants.fontSize - 2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                padding: EdgeInsets.only(
                                                    left: Constants.padding,
                                                    right: Constants.padding),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          Constants
                                                              .borderRadius)),
                                                ),
                                                child: DropdownButton<String>(
                                                  iconSize: 30,
                                                  style: TextStyle(
                                                      color: Constants
                                                          .identityColor),
                                                  isExpanded: true,
                                                  iconEnabledColor:
                                                      Constants.identityColor,
                                                  value: orderBy!.tr(),
                                                  items: [
                                                    'End Date'.tr(),
                                                    'Low Price'.tr(),
                                                  ].map((String sort) {
                                                    return DropdownMenuItem<
                                                            String>(
                                                        value: sort,
                                                        child: Text(
                                                          sort,
                                                          style: TextStyle(
                                                            color: Constants
                                                                .identityColor,
                                                            fontFamily:
                                                                'Tajawal',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: Constants
                                                                    .fontSize -
                                                                (devicePixelRatio >
                                                                        1.2
                                                                    ? 4
                                                                    : 0),
                                                          ),
                                                        ));
                                                  }).toList(),
                                                  onChanged: (value) =>
                                                      setState(() =>
                                                          orderBy = value),
                                                ))),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: Constants.padding),
                            child: Column(
                              children: List.generate(offers.length, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => OfferPage(
                                                      id: offers[index].id,
                                                    )))
                                        .then((value) => setState(() {
                                              getItemsInCartCount();
                                            }));
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          bottom: Constants.padding),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  Constants.borderRadius)),
                                          color: Constants.whiteColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey[500]!,
                                              blurRadius: 5,
                                              offset: Offset(0, 0),
                                            ),
                                          ]),
                                      child: Container(
                                          width: containerWidth,
                                          height: containerHeight,
                                          child: Stack(
                                            children: <Widget>[
                                              Positioned(
                                                  bottom: 0,
                                                  child: Container(
                                                      width: containerWidth,
                                                      height:
                                                          footerAreaHeight + 20,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      Constants
                                                                          .borderRadius),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      Constants
                                                                          .borderRadius)),
                                                          color: Constants
                                                              .redColor),
                                                      child: Container(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: AutoSizeText(
                                                          offers[index]
                                                                  .newPrice +
                                                              (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: Constants
                                                                .whiteColor,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          minFontSize: Constants
                                                                  .fontSize -
                                                              4,
                                                        ),
                                                      ))),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          Constants
                                                              .borderRadius),
                                                ),
                                                child: Column(
                                                  children: <Widget>[
                                                    Container(
                                                        width: containerWidth,
                                                        height: imageHeight,
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      Constants
                                                                          .borderRadius),
                                                              topLeft: Radius
                                                                  .circular(
                                                                      Constants
                                                                          .borderRadius)),
                                                          child: Image.network(
                                                            Constants
                                                                    .apiFilesUrl +
                                                                offers[index]
                                                                    .imagePath!,
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
                                                    Container(
                                                        width: containerWidth,
                                                        height: footerAreaHeight /
                                                            5 *
                                                            3,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        Constants
                                                                            .borderRadius),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        Constants
                                                                            .borderRadius)),
                                                            color: Constants
                                                                .whiteColor),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                                flex: 3,
                                                                child:
                                                                    Container(
                                                                  alignment: arabicLanguage
                                                                      ? Alignment
                                                                          .centerRight
                                                                      : Alignment
                                                                          .centerLeft,
                                                                  padding: arabicLanguage
                                                                      ? EdgeInsets.only(
                                                                          right:
                                                                              40)
                                                                      : EdgeInsets.only(
                                                                          left:
                                                                              40),
                                                                  child:
                                                                      AutoSizeText(
                                                                    arabicLanguage
                                                                        ? offers[index]
                                                                            .nameAr!
                                                                        : offers[index]
                                                                            .nameEn!,
                                                                    style: TextStyle(
                                                                        color: Constants
                                                                            .identityColor,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                        maxFontSize: Constants.fontSize + 2,
                                                                        minFontSize: Constants.fontSize,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 3,
                                                                child: Container(
                                                                    child: Directionality(
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                  child:
                                                                      Container(
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.only(right: 5),
                                                                          child:
                                                                              CountDownTimer(
                                                                            secondsRemaining:
                                                                                offers[index].timer,
                                                                            countDownTimerStyle: TextStyle(
                                                                                color: Constants.whiteColor,
                                                                                fontSize: Constants.fontSize - 4,
                                                                                fontWeight: FontWeight.bold,
                                                                                height: 1),
                                                                            countDownFormatter:
                                                                                Constants.day,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.only(right: 5),
                                                                          child:
                                                                              CountDownTimer(
                                                                            secondsRemaining:
                                                                                offers[index].timer,
                                                                            countDownTimerStyle: TextStyle(
                                                                                color: Constants.whiteColor,
                                                                                fontSize: Constants.fontSize - 4,
                                                                                fontWeight: FontWeight.bold,
                                                                                height: 1),
                                                                            countDownFormatter:
                                                                                Constants.hours,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.only(right: 5),
                                                                          child:
                                                                              CountDownTimer(
                                                                            secondsRemaining:
                                                                                offers[index].timer,
                                                                            countDownTimerStyle: TextStyle(
                                                                                color: Constants.whiteColor,
                                                                                fontSize: Constants.fontSize - 4,
                                                                                fontWeight: FontWeight.bold,
                                                                                height: 1),
                                                                            countDownFormatter:
                                                                                Constants.minutes,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          padding:
                                                                              EdgeInsets.only(right: 5),
                                                                          child:
                                                                              CountDownTimer(
                                                                            secondsRemaining:
                                                                                offers[index].timer,
                                                                            countDownTimerStyle: TextStyle(
                                                                                color: Constants.whiteColor,
                                                                                fontSize: Constants.fontSize - 4,
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
                                                        ))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ))),
                                );
                              }),
                            ),
                          ),
                        ]),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
