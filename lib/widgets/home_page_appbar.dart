import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:masotti/pages/product.dart';
import 'package:masotti/widgets/carousel_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/cart.dart';
import '../assets/my_flutter_app_icons.dart';
import '../constants.dart';
import '../pages/search_results.dart';

// ignore: must_be_immutable
class HomePageAppBarWidget extends StatefulWidget
    implements PreferredSizeWidget {
  final double? height;
  final List<String> images;
  final List<String>? products;
  final IconData? icon;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  int? itemsInCart;
  bool? cartIconExist;

  HomePageAppBarWidget(
      {this.height,
    required  this.images,
      this.products,
      this.icon,
      this.scaffoldKey,
      this.itemsInCart,
      this.cartIconExist});

  @override
  Size get preferredSize => Size(double.infinity, this.height!);

  @override
  State<StatefulWidget> createState() => HomePageAppBarWidgetState();
}

class HomePageAppBarWidgetState extends State<HomePageAppBarWidget> {
  late bool arabicLanguage;

  // String searchText = '';

  @override
  Widget build(BuildContext context) {
    Radius radius = Radius.circular(Constants.borderRadius);
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    BorderRadius borderRadius = arabicLanguage
        ? BorderRadius.only(bottomLeft: radius, topLeft: radius)
        : BorderRadius.only(bottomRight: radius, topRight: radius);
    double heightWidthRatio =
        MediaQuery.of(context).size.height / MediaQuery.of(context).size.width;
    // double searchBarHeight = MediaQuery.of(context).size.height / 100 * 8 - (heightWidthRatio > 1.75 && heightWidthRatio < 2.1 ? 16 : 0);
    return Container(
      // height: widget.height,
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: widget.height! -
                ((MediaQuery.of(context).size.width / 4 * 3) / 10),
            child:
                        CarouselSliderWidget(images: widget.images,
                          onImageTap: (index) async {

                              if(widget.products![index] == 'null')
                                        return;


                              final prefs = await SharedPreferences.getInstance();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        id: widget.products![index],
                                      ))).then(
                                    (value) => setState(() {
                                  widget.itemsInCart =
                                      prefs.getInt(Constants.keyNumberOfItemsInCart);
                                  widget.cartIconExist =
                                  prefs.getString(Constants.keyAccessToken) != null
                                      ? true
                                      : false;
                                }),
                              );
                            })
          ),
          Align(
            alignment: arabicLanguage ? Alignment.topRight : Alignment.topLeft,
            child: Container(
                width: 60,
                height: 40,
                margin: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                    borderRadius: borderRadius, color: Constants.whiteColor),
                child: IconButton(
                  icon: SvgPicture.asset(
                    Constants.sideMenuImage,
                  ),
                  color: Constants.identityColor,
                  onPressed: () => widget.scaffoldKey!.currentState!.openDrawer(),
                )),
          ),
          Align(
            alignment: arabicLanguage ? Alignment.topLeft : Alignment.topRight,
            child: Container(
                width: widget.cartIconExist! ? 90 : 60,
                height: 40,
                margin: EdgeInsets.only(top: 40),
                decoration: BoxDecoration(
                    borderRadius: !arabicLanguage
                        ? BorderRadius.only(bottomLeft: radius, topLeft: radius)
                        : BorderRadius.only(
                            bottomRight: radius, topRight: radius),
                    color: Constants.whiteColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.cartIconExist!
                        ? InkWell(
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (_) => CartPage(
                                            fromSideMenu: false,
                                          )))
                                  .then((value) => setState(() {
                                        widget.itemsInCart = prefs.getInt(
                                            Constants.keyNumberOfItemsInCart);
                                      }));
                            },
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  color: Colors.transparent,
                                  alignment: Alignment.center,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(MyFlutterApp.group_525,
                                      color: Constants.identityColor, size: 22),
                                ),
                                widget.itemsInCart != null &&
                                        widget.itemsInCart != 0
                                    ? Positioned(
                                        right: 0,
                                        top: 8,
                                        child: Container(
                                          padding: EdgeInsets.all(2),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Constants.redColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Constants.borderRadius)),
                                          constraints: BoxConstraints(
                                              minWidth: 17, minHeight: 15),
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
                          )
                        : Container(),
                    InkWell(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (_) => SearchResultsPage()))
                            .then((value) => setState(() {
                                  widget.itemsInCart = prefs
                                      .getInt(Constants.keyNumberOfItemsInCart);
                                  widget.cartIconExist = prefs.getString(
                                              Constants.keyAccessToken) !=
                                          null
                                      ? true
                                      : false;
                                }));
                      },
                      child: Container(
                        color: Colors.transparent,
                        margin: EdgeInsets.all(5),
                        child: Icon(
                          MyFlutterApp.group_526,
                          color: Constants.identityColor,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     width: MediaQuery.of(context).size.width / 3 * 2,
          //     margin: EdgeInsets.only(bottom: 5),
          //     child: Row(
          //       children: <Widget>[
          //         Expanded(
          //           flex: 3,
          //           child: Container(
          //             height: searchBarHeight,
          //             decoration: BoxDecoration(
          //               borderRadius: arabicLanguage ? BorderRadius.only(topRight: Radius.circular(Constants.borderRadius), bottomRight: Radius.circular(Constants.borderRadius)) : BorderRadius.only(topLeft: Radius.circular(Constants.borderRadius), bottomLeft: Radius.circular(Constants.borderRadius)),
          //               color: Constants.whiteColor,
          //             ),
          //             child: TextField(
          //               decoration: InputDecoration(
          //                 border: OutlineInputBorder(
          //                   borderRadius: arabicLanguage ? BorderRadius.only(topRight: Radius.circular(Constants.borderRadius), bottomRight: Radius.circular(Constants.borderRadius)) : BorderRadius.only(topLeft: Radius.circular(Constants.borderRadius), bottomLeft: Radius.circular(Constants.borderRadius))
          //                 ),
          //                 focusColor: Constants.whiteColor,
          //                 hintText: 'Search'.tr(),
          //                 hintStyle: TextStyle(
          //                   fontSize: 12
          //                 )
          //               ),
          //               onChanged: (value) => setState(() => searchText = value.trim()),
          //               onSubmitted: (value) => value != '' && value != ' ' ? Navigator.push(context, MaterialPageRoute(
          //                 builder: (context) => SearchResultsPage(
          //                   searchText: searchText.trim(),
          //                 )
          //               )) : null,
          //             )
          //           )
          //         ),
          //         Expanded(
          //           flex: 1,
          //           child: Container(
          //             height: searchBarHeight,
          //             decoration: BoxDecoration(
          //               borderRadius: arabicLanguage ? BorderRadius.only(topLeft: Radius.circular(Constants.borderRadius), bottomLeft: Radius.circular(Constants.borderRadius)) : BorderRadius.only(topRight: Radius.circular(Constants.borderRadius), bottomRight: Radius.circular(Constants.borderRadius)),
          //               color: Constants.identityColor
          //             ),
          //             child: IconButton(
          //               icon: Icon(
          //                 CustomIcons.search,
          //                 color: Constants.whiteColor,
          //                 size: 24,
          //               ),
          //               onPressed: searchText == '' || searchText == ' ' ? null : () => Navigator.push(context, MaterialPageRoute(
          //                 builder: (context) => SearchResultsPage(
          //                   searchText: searchText,
          //                 )
          //               )),
          //             ),
          //           ),
          //         )
          //       ],
          //     )
          //   )
          // )
        ],
      ),
    );
  }
}
