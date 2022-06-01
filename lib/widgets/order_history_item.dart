import 'package:flutter/material.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';

class OrderHistoryItemWidget extends StatelessWidget {
  final String orderId;
  final String? address;
  final String price;
  final String? createdDate;
  final String? status;

  OrderHistoryItemWidget({
    required this.orderId,
    required this.address,
    required this.price,
    required this.createdDate,
    required this.status,
  });

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
    bool arabicLanguage =
    Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight = containerWidth * 45 / 100;
    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
          borderRadius:
          BorderRadius.all(Radius.circular(Constants.borderRadius)),
          boxShadow: [
        BoxShadow(
          color: Colors.grey,
          blurRadius: 5,
          offset: Offset(0, 0),
        )
      ]),
      child: Stack(
        children: <Widget>[
          Container(
            width: containerWidth,
            height: containerHeight * 25 * 2 / 100,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.borderRadius)),
                color: _getOrderStatusColor(status)),
            child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: AutoSizeText(
                        status!.tr(),
                        style: TextStyle(
                            color: Constants.whiteColor,
                            fontWeight: FontWeight.bold),
                        maxFontSize: Constants.fontSize,
                        minFontSize: Constants.fontSize - 2,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
            top: containerHeight * 25 / 100,
            child: Container(
              width: containerWidth,
              height: containerHeight * 75 / 100,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.borderRadius)),
                color: Constants.whiteColor,
              ),
              child: Container(
                padding: EdgeInsets.only(top: 20, right: arabicLanguage ? 15 : 10, left: arabicLanguage ? 10 : 15, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: AutoSizeText(
                              'Order ID: '.tr() + orderId,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxFontSize: Constants.fontSize + 2,
                              minFontSize: Constants.fontSize,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 10),
                            child: AutoSizeText(
                              price + (Constants.removeSyrianIdentity ? '' :  'Currency'.tr() ),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxFontSize: Constants.fontSize + 2,
                              minFontSize: Constants.fontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        'Address: '.tr() + address!,
                        style: TextStyle(height: 1.6),
                        maxFontSize: Constants.fontSize - 2,
                        minFontSize: Constants.fontSize - 4,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            'Created Date: '.tr() + createdDate!,
                            style: TextStyle(height: 1.6),
                            maxFontSize: Constants.fontSize - 2,
                            minFontSize: Constants.fontSize - 4,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child:  Transform.rotate(
                              angle: arabicLanguage ? 3.14 / 2 : -3.14 / 2,
                              child: Icon(
                                MyFlutterApp.path_261,
                                color: Constants.identityColor,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
