import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

// ignore: must_be_immutable
class SideMenuItemWidget extends StatefulWidget {
  final String name;
  final IconData icon;
  final Widget? pageToNavigate;
  int? badgeNumber;

  SideMenuItemWidget({
    required this.name,
    required this.icon,
    required this.pageToNavigate,
    this.badgeNumber
  });

  @override
  _SideMenuItemWidgetState createState() => _SideMenuItemWidgetState();
}

class _SideMenuItemWidgetState extends State<SideMenuItemWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.pageToNavigate == null ? null : () async {
        final prefs = await SharedPreferences.getInstance();
        Navigator.pop(context);
        Navigator.popUntil(context, ModalRoute.withName("/Home"));
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomePage()
        ));
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => widget.pageToNavigate!
        ));
        setState(() {
          widget.badgeNumber = prefs.getInt(Constants.keyNumberOfItemsInCart);
        });
      },
      child: Container(
	  color: Colors.transparent,
        padding: EdgeInsets.only(top: 2, bottom: 2),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      widget.icon,
                      color: Constants.redColor,
                      size: 22
                    ),
                  ),
                  widget.badgeNumber != null && widget.badgeNumber != 0 && widget.name == 'My Cart' ?
                  Positioned(
                    right: 15,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Constants.redColor,
                        borderRadius: BorderRadius.circular(Constants.borderRadius)
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18,
                        minHeight: 18
                      ),
                      child: Text(
                        widget.badgeNumber.toString(),
                        style: TextStyle(
                          color: Constants.whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  :
                  Container()
                ],

              )
            ),
            Expanded(
              flex: 3,
              child: Container(
                margin: EdgeInsets.only(top: 10, left: 10),
                child: AutoSizeText(
                  widget.name.tr(),
                  style: TextStyle(
                    color: Constants.redColor,
                  ),
                  maxFontSize: Constants.fontSize,
                  minFontSize: Constants.fontSize - 2,
                ),
              )
            ),
            Container(
              width: 16,
              height: 40,
            )
          ],
        ),
      )
    );
  }
}