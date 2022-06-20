import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/cart.dart';
import '../pages/search_results.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';

class CustomAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final BuildContext currentContext;
  int? itemsInCart;
  bool? cartIconExist;
  bool? isCartPage;
  bool? cartFromSideMenu;
  final bool  ? showBackButton;

  CustomAppBarWidget(
      {required this.title,
      required this.currentContext,
      required this.itemsInCart,
       this.showBackButton,
      this.cartIconExist,
      this.isCartPage,
      this.cartFromSideMenu});

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  State<StatefulWidget> createState() => CustomAppBarWidgetState();
}

class CustomAppBarWidgetState extends State<CustomAppBarWidget> {
  @override
  Widget build(BuildContext currentContext) {
    Radius radius = Radius.circular(Constants.borderRadius);
    bool arabicLanguage =
        Localizations.localeOf(currentContext).languageCode == 'ar'
            ? true
            : false;
    BorderRadius borderRadius = arabicLanguage
        ? BorderRadius.only(bottomLeft: radius, topLeft: radius)
        : BorderRadius.only(bottomRight: radius, topRight: radius);
    if (widget.isCartPage == null) widget.isCartPage = false;
    if (widget.cartFromSideMenu == null) widget.cartFromSideMenu = false;
    return AppBar(
      title: Padding(
        padding: EdgeInsets.only(top: 26, right: 5, left: 5),
        child: Text(widget.title!.tr().toUpperCase(),
            style: TextStyle(
                color: Constants.whiteColor, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Constants.identityColor,
      centerTitle: true,

      leading: Builder(
        builder: (context) {
          return Container(
              width: 100,
              margin: EdgeInsets.only(top: 18),
              child: IconButton(
                icon: SvgPicture.asset(
                  Constants.sideMenuImage2,
                ),
                color: Constants.whiteColor,
                onPressed: () => Scaffold.of(currentContext).openDrawer(),
              ));
        },
      ),
      elevation: 0,
      actions: [

        widget.cartIconExist! && !widget.isCartPage!
            ? InkWell(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  Navigator.of(currentContext)
                      .push(MaterialPageRoute(builder: (_) => CartPage(fromSideMenu: false,)))
                      .then((value) => setState(() {
                            widget.itemsInCart =
                                prefs.getInt(Constants.keyNumberOfItemsInCart);
                          }));
                },
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.only(top: 18),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(MyFlutterApp.group_525,
                            color: Constants.whiteColor, size: 22),
                      ),
                      widget.itemsInCart != null && widget.itemsInCart != 0
                          ? Positioned(
                              right: 0,
                              top: 8,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Constants.redColor,
                                    borderRadius: BorderRadius.circular(
                                        Constants.borderRadius)),
                                constraints:
                                    BoxConstraints(minWidth: 17, minHeight: 15),
                                child: Container(
                                  margin: EdgeInsets.only(top: 2),
                                  child: Text(
                                    widget.itemsInCart.toString(),
                                    style: TextStyle(
                                        color: Constants.whiteColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  ),
                ),
              )
            : Container(),
        InkWell(
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            Navigator.of(currentContext)
                .push(MaterialPageRoute(builder: (_) => SearchResultsPage()))
                .then((value) => setState(() {
                      widget.itemsInCart =
                          prefs.getInt(Constants.keyNumberOfItemsInCart);
                      widget.cartIconExist =
                          prefs.getString(Constants.keyAccessToken) != null
                              ? true
                              : false;
                      if (widget.isCartPage!) {
                        Navigator.pop(currentContext);
                        Navigator.push(currentContext, MaterialPageRoute(
                            builder: (_) =>
                                CartPage(fromSideMenu: widget.cartFromSideMenu! ? true : false,)));
                      }
                    }));
          },
          child: Container(
            margin: EdgeInsets.only(top: 18, right: 10, left: 10),
            color: Colors.transparent,
            child: Icon(
              MyFlutterApp.group_526,
              color: Constants.whiteColor,
            ),
          ),
        ),
       if(Platform.isIOS || widget.showBackButton != null) InkWell(
          onTap: ()  {
         Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(top: 18, right: 10, left: 10),
            child:   Transform(
    alignment: Alignment.center,
    transform: Matrix4.rotationY(arabicLanguage ?0 :  math.pi),
    child: Icon(
      Icons.arrow_back_ios_new,
      color: Constants.whiteColor,
    ),
    ),
          ),
        ),
      ],
    );
  }
}
