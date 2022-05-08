import 'package:flutter/material.dart';
import '../constants.dart';

class ColoredCircularProgressIndicator extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
      CircularProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
      ),
    );
  }
}