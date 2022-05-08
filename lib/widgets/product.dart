import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants.dart';

class ProductWidget extends StatelessWidget {
  final String? id;
  final String? nameAr;
  final String? nameEn;
  final String price;
  final String salesPrice;
  final String imagePath;

  bool arabicLanguage = false;

  ProductWidget({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.price,
    required this.salesPrice,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    arabicLanguage =
    Localizations
        .localeOf(context)
        .languageCode == 'ar' ? true : false;
    double width =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerWidth = width / 100 * 48;
    double containerHeight = containerWidth + (containerWidth / 100 * 5);
    return salesPrice != 'null'
        ? ClipRect(
            child: Banner(
                location: BannerLocation.topStart,
                message: 'SALE'.tr(),
                color: Constants.redColor,
                child: buildWidget(context, containerWidth, containerHeight)))
        : buildWidget(context, containerWidth, containerHeight);
  }

  Widget buildWidget(
      BuildContext context, double containerWidth, double containerHeight) {
    return Container(
        width: containerWidth,
        height: containerWidth / 4 * 3 + containerWidth / 8,
        child: Stack(
          children: <Widget>[
            Container(
              width: containerWidth,
              height: containerWidth / 4 * 3,
              decoration: BoxDecoration(
                  border: Border.all(color: Constants.borderColor!),
                  borderRadius:
                      BorderRadius.all(Radius.circular(Constants.borderRadius)),
                  color: Constants.whiteColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ]),
              child: Container(
                  width: containerWidth,
                  height: containerWidth / 4 * 3,
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(Constants.borderRadius + 2)),
                      child: Container(
                        width: containerWidth,
                        height: containerWidth / 4 * 3,
                        margin: EdgeInsets.all(5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                              Radius.circular(Constants.borderRadius + 2)),
                          child: CachedNetworkImage(
                            imageUrl: Constants.apiFilesUrl + imagePath,
                            fit: BoxFit.fill,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      backgroundColor: Colors.grey,
                                      valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
                                      value: downloadProgress.progress));
                            },
                          ),
                        ),
                      ))),
            ),
            Positioned(
                bottom: 5,
                child: Container(
                  width: containerWidth - 30,
                  height: (containerWidth / 8) * 2,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Stack(
                    children: [
                      Container(
                        width: containerWidth,
                        height: (containerWidth / 8) * 2,
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(top: 3),
                        decoration: BoxDecoration(
                            border: Border.all(color: Constants.borderColor!),
                            borderRadius: BorderRadius.all(
                                Radius.circular(Constants.borderRadius + 5)),
                            color: Constants.whiteColor),
                        child: AutoSizeText(
                          arabicLanguage ? nameAr! : nameEn!,
                          style: TextStyle(
                            color: Constants.identityColor,
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: Constants.fontSize - 3,
                          minFontSize: Constants.fontSize - 5,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                            height: containerWidth / 8,
                            width: containerWidth - 30,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(Constants.borderRadius),
                                ),
                                color: Constants.redColor),
                            child: Container(
                                padding: EdgeInsets.only(top: 3),
                                alignment: Alignment.center,
                                child: salesPrice != 'null'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          AutoSizeText(
                                            (price.endsWith('.0')
                                                    ? price.replaceAll('.0', '')
                                                    : price) +
                                                ' ',
                                            style: TextStyle(
                                                color: Colors.grey[300],
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                decorationThickness: 2),
                                            maxFontSize: Constants.fontSize - 3,
                                            minFontSize: Constants.fontSize - 5,
                                          ),
                                          AutoSizeText(
                                            salesPrice,
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                                ),
                                            maxFontSize: Constants.fontSize - 3,
                                            minFontSize: Constants.fontSize - 5,
                                          ),
                                          AutoSizeText(
                                            'Currency'.tr(),
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                            ),
                                            maxFontSize: Constants.fontSize - 3,
                                            minFontSize: Constants.fontSize - 5,
                                          )
                                        ],
                                      )
                                    : AutoSizeText(
                                        (price.endsWith('.0')
                                                ? price.replaceAll('.0', '')
                                                : price) +
                                            'Currency'.tr(),
                                        style: TextStyle(
                                            color: Constants.whiteColor,
                                        ),
                                        maxFontSize: Constants.fontSize - 3,
                                        minFontSize: Constants.fontSize - 5,
                                      ))),
                      ),
                    ],
                  ),
                )),
          ],
        ));
  }
}
