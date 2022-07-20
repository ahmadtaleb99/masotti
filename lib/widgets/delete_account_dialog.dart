import 'dart:developer';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:masotti/assets/my_flutter_app_icons.dart';
import 'package:masotti/widgets/text_field.dart';
import '../constants.dart';

class DeleteAccountDialog {
  final BuildContext? context;
  final String? title;
  final String? message;
  final String? okButtonTitle;
  final Function()? onPressedOkButton;
  final Color? color;
  final String? icon;

  DeleteAccountDialog(
      {this.context,
      this.title,
      this.message,
      this.okButtonTitle,
      this.onPressedOkButton,
      this.color,
      this.icon});

  Future<dynamic> showCustomDialog() async {
    double containerWidth =
        MediaQuery.of(context!).size.width - (Constants.doublePadding);
   return await showDialog(
        context: context!,
        builder: (context) {
          return DeleteAccountWidget(
              onPressedOkButton: onPressedOkButton,
              containerWidth: containerWidth);
        });
  }
}

class DeleteAccountWidget extends StatefulWidget {
  final Function? onPressedOkButton;
  final double containerWidth;

  @override
  _DeleteAccountWidgetState createState() => _DeleteAccountWidgetState();

  const DeleteAccountWidget({
    this.onPressedOkButton,
    required this.containerWidth,
  });
}

class _DeleteAccountWidgetState extends State<DeleteAccountWidget> {
  bool _hasAgreed = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _passwordIsvalid = false;
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return ButtonBarTheme(
      data: ButtonBarThemeData(alignment: MainAxisAlignment.center),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(Constants.borderRadius))),
        titlePadding: EdgeInsets.symmetric(horizontal: 30),
        title: Container(
          height: 150,
          // width: 100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(300),
                bottomRight: Radius.circular(300),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[400]!,
                  blurRadius: 5,
                  offset: Offset(1, 1),
                ),
              ]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
        'Delete Account'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Constants.redColor,
                    fontSize: Constants.fontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              SvgPicture.asset(
                "assets/images/warning.svg",
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Delete Account Text'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Constants.redColor,
                    fontSize: Constants.fontSize - 2,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: Constants.padding,    right: Constants.padding, top: Constants.padding),
                child: Container(
                  width: widget.containerWidth / 3,
                  child: Material(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _hasAgreed = !_hasAgreed;
                          _passwordIsvalid = false;
                          _passwordController.text = '';
                        }

                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Agree'.tr(),
                              style: TextStyle(
                                  color: Constants.identityColor,
                                  fontSize: Constants.fontSize - 2,
                                  fontWeight: FontWeight.bold)),
                          IgnorePointer(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                              disabledColor: Constants.greyColor
                              ),
                              child: Checkbox(
                                onChanged: null,
                                value: _hasAgreed,

                                  checkColor: Constants.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                  transitionBuilder: (Widget child, Animation<double> animation) =>
                      SlideTransition(
                        position:
                        Tween<Offset>(begin: Offset(0, -0.5), end: Offset(0, 0))
                            .animate(animation),
                        child: child,
                      ),
                  duration: Duration(milliseconds: 300),
                  reverseDuration: Duration(milliseconds: 300 ),
                  child: _hasAgreed
                      ?   Form(
                    key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(top : 10.0),
                          child: Column(
                            children: [
                              Text('Please Enter Password'.tr(),
                                  style: TextStyle(
                                      color: Constants.identityColor,
                                      fontSize: Constants.fontSize - 2,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 5,),
                              CustomTextField(
                                controller: _passwordController,
                    label: 'Password'.tr(),
                    onSaved: (value) => null,
                    onChanged: (text) {
                                 if(_formKey.currentState!.validate()){
                                   log('pass valid');
                                   setState(() => _passwordIsvalid = true);
                                 }
                                 else  setState(() => _passwordIsvalid = false);
                    },
                    isRequired: true,
                    isPassword: true,
                    icon: MyFlutterApp.subtraction_1,
                  ),
                            ],
                          ),
                        ),
                      )

                      : Container())
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 40),
                    child: ButtonTheme(
                      minWidth: widget.containerWidth / 3,
                      height: 40,
                      child: RaisedButton(
                        child: Text('Delete Account'.tr(),
                            style: TextStyle(
                                color: Constants.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: Constants.fontSize - 2)),
                        onPressed: !(_passwordIsvalid && _hasAgreed) ? null : (){
                          log(_passwordController.text);
                   return    Navigator.pop(context,_passwordController.text);
                        }
     ,
                        color: Constants.redColor,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Constants.borderRadius),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  @override
  void dispose() {
    _passwordController.dispose();
        super.dispose();
  }
}
