
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masotti/widgets/custom_dialog.dart';

import '../constants.dart';

showInternetErrorDialog(BuildContext context){
  CustomDialog(
    context: context,
    title: 'Internet Error'.tr(),
    message: 'Error has Occurred'.tr(),
    okButtonTitle: 'OK'.tr(),
    onPressedOkButton: () {
      Navigator.pop(context);

    },
    color: Constants.redColor,
    icon: "assets/images/warning.svg",
  ).showCustomDialog();

}