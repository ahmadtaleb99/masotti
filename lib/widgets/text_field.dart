import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final String label;
  final Function onSaved;
  final void Function(String)?  onChanged;
  final IconData? icon;
  final double? iconSize;
  final Function? onSubmit;
  final TextInputAction? textInputAction;
  final  String? initialValue;
  bool isRequired = true;
  bool? isEmail = false;
  bool? isPassword = false;
  bool? isPhone = false;
  bool? isCode = false;
  TextEditingController  ? controller;

    CustomTextField(
      {required this.label,
      required this.onSaved,
      required this.isRequired,
      this.iconSize,
      this.onSubmit,
      this.textInputAction,
        this.controller,
      this.initialValue,
      this.onChanged,
      this.isEmail,
      this.isPassword,
      this.isPhone,
      this.isCode,
      this.icon});

  @override
  Widget build(BuildContext context) {
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;

    return Center(
      child: Stack(
        children: [
          Container(
            height: 63,
            decoration: BoxDecoration(
              color: Constants.whiteColor,
              borderRadius: BorderRadius.all(
                Radius.circular(Constants.borderRadius),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          TextFormField(
          controller: controller,
            textAlignVertical: TextAlignVertical.center,
            obscureText: isPassword != null ? true : false,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius))),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius))),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius))),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius))),
                errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius))),
                disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.all(
                        Radius.circular(Constants.borderRadius))),
                // contentPadding: EdgeInsets.all(
                //   Constants.padding,
                // ),
                hintText: label.tr(),
                prefixIcon: Card(
                  elevation: 3,
                  margin: arabicLanguage
                      ? EdgeInsets.only(left: 10)
                      : EdgeInsets.only(right: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(Constants.borderRadius))),
                  child: Container(
                    height: 63,
                    width: 63,
                    child: Icon(
                      icon,
                      color: Constants.redColor,
                      size: iconSize == null ? 25 : iconSize,
                    ),
                  ),
                )),
            keyboardType: isPhone != null || isCode != null
                ? TextInputType.number
                : isEmail != null
                    ? TextInputType.emailAddress
                    : TextInputType.text,
            onChanged: onChanged ,
            initialValue: initialValue,
            validator: (value) {
              if (isPassword != null && isPassword!) {
                return value!.length < 4
                    ? 'FIELD_VALIDATOR can\'t be less than 4 characters'
                        .tr(args: [label.tr()])
                    : null;
              }
              if (isEmail != null && isEmail!) {
                Pattern pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = RegExp(pattern as String);
                return !regex.hasMatch(value!.trim())
                    ? 'FIELD_VALIDATOR must be a valid email'
                        .tr(args: [label])
                    : null;
              }
              if (isCode != null && isCode!) {
                Pattern pattern = r'^[0-9]{6}$';
                RegExp regex = RegExp(pattern as String);
                return !regex.hasMatch(value!.trim())
                    ? 'FIELD_VALIDATOR must be a valid code within 6 digits'
                        .tr(args: [label])
                    : null;
              }
              if (isPhone != null && isPhone!) {
                Pattern pattern = r'^09[0-9]{8}$';
                RegExp regex = RegExp(pattern as String);
                return !regex.hasMatch(value!.trim())
                    ? 'FIELD_VALIDATOR must be a valid phone number'
                        .tr(args: [label])
                    : null;
              }
              if (isRequired != null && isRequired) {
                return value!.isEmpty
                    ? 'FIELD_VALIDATOR can\'t be empty'.tr(args: [label])
                    : null;
              }
              return null;
            },
            onSaved: onSaved as void Function(String?)?,
            onFieldSubmitted: onSubmit as void Function(String)? ?? (_) {},
            textInputAction: textInputAction ?? TextInputAction.next,
          ),
        ],
      ),
    );
  }
}
