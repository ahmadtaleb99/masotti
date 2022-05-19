import 'package:flutter/material.dart';
import 'package:masotti/widgets/request_empty_data.dart';

import '../constants.dart';
import 'custom_red_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String errorText;
  final void Function()? onRetry;
  const CustomErrorWidget({
    required this.errorText,
    this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: Constants.padding),
            child: RequestEmptyData(
              message: errorText,
            )),
        CustomRedButton(text: 'Retry', onPressed: onRetry)
      ],
    );
  }
}
