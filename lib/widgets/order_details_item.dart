import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';

String imageURL =
    "https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80";

class OrderDetailsItemWidget extends StatelessWidget {
  final String itemId;
  final String? name;
  final String price;
  final String quantity;
  final String thumbnail;
  final Map? variant;
  final bool availability;
  final Function onPressedOnView;

  OrderDetailsItemWidget(
      {required this.itemId,
      required this.name,
      required this.price,
      required this.quantity,
      required this.thumbnail,
      required this.variant,
      required this.availability,
      required this.onPressedOnView});

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight =
        variant == null ? containerWidth / 10 * 7 : containerWidth / 100 * 100;
    double headerHeight = (containerWidth / 10 * 7) / 10 * 3;
    double colorSizeContainerWidth = containerWidth / 100 * 14;
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Container(
      width: containerWidth,
      // height: containerHeight / 2,
      child: Stack(
        children: <Widget>[
          Container(
            // height: containerHeight / 2,
            width: containerWidth,
            padding: EdgeInsets.only(
                top: variant == null
                    ? containerHeight / 6
                    : containerHeight / 6 + 6,
              bottom: Constants.halfPadding,
            ),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.borderRadius)),
                color: Constants.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,
                    blurRadius: 5,
                    offset: Offset(0, 0),
                  )
                ]),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: containerHeight / 4,
                    width: containerWidth / 2,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.all(Radius.circular(Constants.borderRadius)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[400]!,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            )
                          ]),
                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.all(Radius.circular(Constants.borderRadius)),
                        child: CachedNetworkImage(
                          imageUrl: Constants.apiFilesUrl + thumbnail,
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, downloadProgress) {
                            return Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.grey,
                                    valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
                                    value: downloadProgress.progress));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      variant == null
                          ? Container()
                          : Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                top: Constants.halfPadding,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: AutoSizeText(
                                        'Size & Color'.tr(),
                                        style: TextStyle(
                                          color: Constants.identityColor,
                                        ),
                                        maxFontSize: Constants.fontSize,
                                        minFontSize: Constants.fontSize - 2,
                                      ),
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Container(
                                        alignment: arabicLanguage
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        padding: arabicLanguage
                                            ? EdgeInsets.only(left: 10)
                                            : EdgeInsets.only(right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: <Widget>[
                                            Expanded(
                                        flex:2,

                                        child: Container(
                                                // width: colorSizeContainerWidth,
                                                // height:
                                                // colorSizeContainerWidth / 2,
                                                padding: EdgeInsets.only(right: 10, left: 10, top: 5),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Constants
                                                          .identityColor),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(Constants
                                                          .borderRadius)),
                                                  color: Constants.whiteColor,
                                                ),
                                                child: AutoSizeText(
                                                  variant!['size'],
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                    Constants.identityColor,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                  maxFontSize: Constants.fontSize,
                                                  minFontSize: Constants.fontSize - 2,
                                                ),
                                              ),
                                            ),
                                            Expanded(

                                              child: Container(
                                                width: colorSizeContainerWidth / 2,
                                                height:
                                                colorSizeContainerWidth / 2,
                                                margin: arabicLanguage
                                                    ? EdgeInsets.only(right: 5)
                                                    : EdgeInsets.only(left: 5),
                                                child: Stack(
                                                  children: [
                                                    Positioned(
                                                      child: Icon(Icons.brightness_1,
                                                          size: 23,
                                                          color: Colors
                                                              .grey[400]),
                                                    ),
                                                    Icon(Icons.brightness_1,
                                                        size: 22,
                                                        color: Color(int.parse(
                                                            '0xFF' +
                                                                variant!['color']
                                                                    .toString()))),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            top: Constants.halfPadding,
                            bottom: Constants.halfPadding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                                flex: 1,
                                child: Container(
                                  child: AutoSizeText(
                                    'Quantity'.tr(),
                                    style: TextStyle(
                                      color: Constants.identityColor,
                                    ),
                                    maxFontSize: Constants.fontSize,
                                    minFontSize: Constants.fontSize - 2,
                                  ),
                                )),
                            Container(
                              alignment: arabicLanguage
                                  ? Alignment.centerLeft
                                  : Alignment.centerRight,
                              padding: arabicLanguage
                                  ? EdgeInsets.only(left: 10)
                                  : EdgeInsets.only(right: 10),
                              child: Container(
                                // width: colorSizeContainerWidth,
                                height:
                                colorSizeContainerWidth / 2,
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Constants
                                          .identityColor),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(Constants
                                          .borderRadius)),
                                  color: Constants.whiteColor,
                                ),
                                child: AutoSizeText(
                                  quantity.toString(),
                                  style: TextStyle(
                                    color: Constants.identityColor,
                                    fontWeight: FontWeight.bold
                                  ),
                                  maxFontSize: Constants.fontSize,
                                  minFontSize: Constants.fontSize - 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: Container(
                                child: AutoSizeText(
                                  'Price'.tr(),
                                  style: TextStyle(
                                    color: Constants.identityColor,
                                  ),
                                  maxFontSize: Constants.fontSize,
                                  minFontSize: Constants.fontSize - 2,
                                ),
                              )),
                          Container(
                            alignment: arabicLanguage
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            padding: arabicLanguage
                                ? EdgeInsets.only(left: 10)
                                : EdgeInsets.only(right: 10),
                            child: AutoSizeText(
                              price.toString() + 'Currency'.tr(),
                              style: TextStyle(
                                color: Constants.identityColor,
                                fontWeight: FontWeight.bold
                              ),
                              maxFontSize: Constants.fontSize,
                              minFontSize: Constants.fontSize - 2,
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
          Positioned(
              top: 0,
              child: Container(
                width: containerWidth,
                // height: headerHeight,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius)),
                    color: Constants.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[400]!,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      )
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: arabicLanguage
                          ? EdgeInsets.only(right: 15)
                          : EdgeInsets.only(left: 15),
                      child: AutoSizeText(
                        name!,
                        style: TextStyle(
                          color: Constants.identityColor,
                          fontWeight: FontWeight.bold,
                        ),
                        maxFontSize: Constants.fontSize + 2,
                        minFontSize: Constants.fontSize,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: arabicLanguage
                          ? EdgeInsets.only(left: 10)
                          : EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          MyFlutterApp.group_1,
                          color: Constants.identityColor,
                          size: 17,
                        ),
                        onPressed: onPressedOnView as void Function()?,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
