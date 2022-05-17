import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class ColoredCircularProgressIndicator extends StatelessWidget{

  const ColoredCircularProgressIndicator();
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
      CircularProgressIndicator.adaptive(
        backgroundColor: Colors.grey,
        valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
      ),
    );
  }
}