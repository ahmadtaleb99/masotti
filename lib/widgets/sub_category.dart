import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';

class SubCategoryWidget extends StatelessWidget{

  final String id;
  final String? nameAr;
  final String? nameEn;
  final String? imagePath;

  SubCategoryWidget({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    double width =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerWidth = width;
    bool arabicLanguage =
    Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(Constants.borderRadius)),
            child: Container(
              color: Constants.redColor,
              padding: EdgeInsets.all(Constants.halfPadding),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.only(bottom: Constants.halfPadding / 2),
          elevation: 12,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Constants.borderColor!),
              borderRadius:
              BorderRadius.all(Radius.circular(Constants.borderRadius))),
          child: Container(
            padding: arabicLanguage
                ? EdgeInsets.only(left: Constants.padding)
                : EdgeInsets.only(right: Constants.padding),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            width: containerWidth * 21.19 / 100,
                            height: (containerWidth * 21.19 / 100) / 4 * 3.5,
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  side:
                                  BorderSide(color: Constants.borderColor!),
                                  borderRadius: arabicLanguage
                                      ? BorderRadius.only(
                                      topRight: Radius.circular(
                                          Constants.borderRadius),
                                      bottomRight: Radius.circular(
                                          Constants.borderRadius))
                                      : BorderRadius.only(
                                      topLeft: Radius.circular(
                                          Constants.borderRadius),
                                      bottomLeft: Radius.circular(
                                          Constants.borderRadius))),
                              child: ClipRRect(
                                borderRadius: arabicLanguage
                                    ? BorderRadius.only(
                                    topRight: Radius.circular(
                                        Constants.borderRadius),
                                    bottomRight: Radius.circular(
                                        Constants.borderRadius))
                                    : BorderRadius.only(
                                    topLeft: Radius.circular(
                                        Constants.borderRadius),
                                    bottomLeft: Radius.circular(
                                        Constants.borderRadius)),
                                child: imagePath != null
                                    ? CachedNetworkImage(
                                  imageUrl:
                                  Constants.apiFilesUrl + imagePath!,
                                  fit: BoxFit.cover,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) {
                                    return Center(
                                        child: CircularProgressIndicator(
                                            backgroundColor: Colors.grey,
                                            valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
                                            value: downloadProgress
                                                .progress));
                                  },
                                )
                                    : Image.asset(
                                    Constants.defaultCategoryImage,
                                    fit: BoxFit.fill),
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              arabicLanguage ? nameAr! : nameEn!,
                              style: TextStyle(
                                  color: Constants.identityColor,
                                  fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              minFontSize: Constants.fontSize - 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Constants.halfPadding),
                      child: arabicLanguage
                          ? Transform.rotate(
                        angle: -3.14,
                        child: Icon(
                          MyFlutterApp.next,
                          color: Constants.redColor,
                          size: 15,
                        ),
                      )
                          : Icon(
                        MyFlutterApp.next,
                        color: Constants.redColor,
                        size: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}