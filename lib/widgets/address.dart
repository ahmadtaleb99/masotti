import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../pages/update_address.dart';
import '../assets/my_flutter_app_icons.dart';
import './alert_dialog.dart';
import '../constants.dart';
import '../assets/flutter_custom_icons.dart';
import '../pages/update_address_ios.dart';
import 'custom_dialog.dart';

class AddressWidget extends StatefulWidget {
  final String id;
  final String? name;
  final Function onDelete;

  AddressWidget(
      {required this.id, required this.name, required this.onDelete});

  @override
  State<StatefulWidget> createState() => AddressWidgetState();
}

class AddressWidgetState extends State<AddressWidget> {
  bool arabicLanguage = false;

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double containerHeight = containerWidth / 4;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Container(
      width: containerWidth,
      height: containerHeight,
      child: Row(
        children: <Widget>[
          Align(
            alignment:
                arabicLanguage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: containerWidth / 100 * 79.34,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.borderRadius)),
                color: Constants.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[400]!,
                    blurRadius: 5,
                    offset: Offset(3, 0),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: containerHeight,
                      width: containerWidth * 19.46 / 100,
                      margin: arabicLanguage
                          ? EdgeInsets.only(left: 10)
                          : EdgeInsets.only(right: 10),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                          Radius.circular(Constants.borderRadius),
                        )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(Constants.borderRadius),
                          ),
                          child: Icon(
                            CustomIcons.address,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Align(
                      alignment: arabicLanguage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: AutoSizeText(
                        widget.name!,
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                        minFontSize: Constants.fontSize - 2,
                        maxFontSize: Constants.fontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: containerWidth / 100 * 18.2,
            margin: arabicLanguage
                ? EdgeInsets.only(right: 5)
                : EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.all(Radius.circular(Constants.borderRadius)),
              color: Constants.redColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!,
                  blurRadius: 5,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(
                        MyFlutterApp.path_259,
                        size: 15,
                        color: Constants.whiteColor,
                      ),
                      onPressed: () {
                        CustomDialog(
                          context: context,
                          title: 'Warning'.tr(),
                          message:
                              'Are you sure you want to delete this address?'
                                  .tr(),
                          okButtonTitle: 'Ok'.tr(),
                          cancelButtonTitle: 'Cancel'.tr(),
                          onPressedCancelButton: () {
                            Navigator.pop(context);
                          },
                          onPressedOkButton: () {
                            widget.onDelete();
                          },
                          color: Color(0xFFFFB300),
                          icon: "assets/images/warning.svg",
                        ).showCustomDialog();
                      }),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(
                      MyFlutterApp.path_257,
                      size: 22,
                      color: Constants.whiteColor,
                    ),
                    onPressed: () =>



                        Navigator.push(
                        context,
                        Platform.isIOS
                            ? MaterialPageRoute(
                                builder: (context) =>
                                    UpdateAddressIOS(id: widget.id))
                            : MaterialPageRoute(
                                builder: (context) =>
                                    UpdateAddress(id: widget.id))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
