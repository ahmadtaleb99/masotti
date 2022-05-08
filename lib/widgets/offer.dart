import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as easyLocalization;
import '../constants.dart';
import './count_down.dart';

class OfferWidget extends StatefulWidget{

  String id;
  String? nameEn;
  String? nameAr;
  String? detailsEn;
  String? detailsAr;
  String oldPrice;
  String newPrice;
  String? imagePath;
  int? timer;
  List<dynamic>? products;
  bool? hasBeenExpired;

  OfferWidget({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.detailsEn,
    required this.detailsAr,
    required this.oldPrice,
    required this.newPrice,
    required this.imagePath,
    required this.timer,
    this.hasBeenExpired,
    this.products,
  });

  @override
  State<StatefulWidget> createState() => OfferWidgetState();
}

class OfferWidgetState extends State<OfferWidget>{
  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - (Constants.doublePadding);
    double imageHeight = containerWidth / 4 * 3;
    double containerHeight = imageHeight + (imageHeight / 4);
    double footerAreaHeight = imageHeight / 4;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool arabicLanguage = Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Container(
      width: containerWidth,
      height: containerHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            bottom: 0,
            child: Container(
              width: containerWidth,
              height: footerAreaHeight + 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Constants.borderRadius), bottomRight: Radius.circular(Constants.borderRadius)),
                color: Constants.identityColor
              ),
              child: Container(
                padding: EdgeInsets.only(bottom: 5),
                alignment: Alignment.bottomCenter,
                child: AutoSizeText(
                  widget.newPrice + 'Currency'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.whiteColor, 
                  ),
                  minFontSize: Constants.fontSize - 4,
                ),
              )
            )
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Constants.borderColor!),
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: containerWidth,
                  height: imageHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(Constants.borderRadius), topLeft: Radius.circular(Constants.borderRadius)),
                    child: Image.network(
                      Constants.apiFilesUrl + widget.imagePath!,
                      fit: BoxFit.fill,
                      loadingBuilder: (context, child, loadingProgress){
                        if(loadingProgress == null){
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.grey,
                              valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null
                          ),
                        );
                      },
                    ),
                  )
                ),
                Container(
                  width: containerWidth,
                  height: footerAreaHeight / 5 * 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Constants.borderRadius), bottomRight: Radius.circular(Constants.borderRadius)),
                    color: Constants.whiteColor
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: arabicLanguage ? Alignment.centerRight : Alignment.centerLeft,
                          padding: arabicLanguage ? EdgeInsets.only(right: 40) : EdgeInsets.only(left: 40),
                          child: AutoSizeText(
                            arabicLanguage ? widget.nameAr! : widget.nameEn!,
                            style: TextStyle(
                              color: Constants.identityColor, 
                              fontWeight: FontWeight.bold
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            minFontSize: devicePixelRatio > 1.2 ? 14 : 18,
                          ),
                        )
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(right: 5),
                                    child:  CountDownTimer(
                                      secondsRemaining: widget.timer,
                                      countDownTimerStyle: TextStyle(
                                        color: Constants.whiteColor,
                                        fontSize: Constants.fontSize - 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1
                                      ),
                                      countDownFormatter: Constants.day,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 5),
                                    child:  CountDownTimer(
                                      secondsRemaining: widget.timer,
                                      countDownTimerStyle: TextStyle(
                                        color: Constants.whiteColor,
                                        fontSize: Constants.fontSize - 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1
                                      ),
                                      countDownFormatter: Constants.hours,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 5),
                                    child:  CountDownTimer(
                                      secondsRemaining: widget.timer,
                                      countDownTimerStyle: TextStyle(
                                        color: Constants.whiteColor,
                                        fontSize: Constants.fontSize - 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1
                                      ),
                                      countDownFormatter: Constants.minutes,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 5),
                                    child:  CountDownTimer(
                                      secondsRemaining: widget.timer,
                                      countDownTimerStyle: TextStyle(
                                        color: Constants.whiteColor,
                                        fontSize: Constants.fontSize - 10,
                                        fontWeight: FontWeight.bold,
                                        height: 1
                                      ),
                                      countDownFormatter: Constants.seconds,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        )
                      )
                    ],
                  )
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}