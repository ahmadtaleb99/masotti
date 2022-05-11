import 'dart:convert';

import 'package:async/async.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import './widgets/custom_dialog.dart';
import './pages/products.dart';
import './pages/sub_categories.dart';
import './widgets/category.dart';
import './assets/my_flutter_app_icons.dart';
import './pages/orders_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import './constants.dart';
import './assets/flutter_custom_icons.dart';
import './widgets/side_menu_item.dart';
import './pages/profile.dart';
import './pages/privacy_policy.dart';
import './pages/returns_and_exchange.dart';
import './pages/notifications.dart';
import './pages/settings.dart';
import './pages/guest_settings.dart';
import './pages/my_addresses.dart';
import './pages/home_page.dart';
import './pages/login.dart';
import './pages/categories.dart';
import './pages/offers.dart';
import './pages/cart.dart';
import './pages/FAQs.dart';
import 'dart:math';

class SideMenu extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SideMenuState();
  }
}

class SideMenuState extends State<SideMenu> with TickerProviderStateMixin {
  bool authenticated = false;
  bool unreadNotifications = false;
  bool arabicLanguage = false;
  int? itemsInCart = 0;

  late AnimationController rotationController;

  _checkMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authenticated =
          prefs.getString(Constants.keyAccessToken) != null ? true : false;
      unreadNotifications =
          prefs.getBool(Constants.keyUnreadNotifications) == true
              ? true
              : false;
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
    });
  }

  @override
  void initState() {
    super.initState();
    _checkMenuItems();
    rotationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
        upperBound: 0.5,
        reverseDuration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Container(
      decoration: BoxDecoration(
          borderRadius: arabicLanguage
              ? BorderRadius.horizontal(left: Radius.circular(50))
              : BorderRadius.horizontal(right: Radius.circular(50)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[500]!,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ]),
      child: ClipRRect(
        borderRadius: arabicLanguage
            ? BorderRadius.horizontal(left: Radius.circular(50))
            : BorderRadius.horizontal(right: Radius.circular(50)),
        child: Drawer(
            child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      child: Container(
                          margin: arabicLanguage
                              ? EdgeInsets.only(left: 40)
                              : EdgeInsets.only(right: 40),
                          child: Container(
                            padding: arabicLanguage
                                ? EdgeInsets.only(right: 90)
                                : EdgeInsets.only(left: 90),
                            child: Image.asset(Constants.logoImage),
                          )),
                    ),
                    SideMenuItemWidget(
                      name: 'Home SideNav',
                      icon: CustomIcons.home,
                      pageToNavigate: HomePage(),
                    ),
                    FutureBuilder(
                        future: getCategories(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return ListTileTheme(
                                dense: true,
                                contentPadding: EdgeInsets.all(0),
                                child: ExpansionTile(
                                  title: Container(
                                      color: Colors.transparent,
                                      padding:
                                          EdgeInsets.only(top: 2, bottom: 2),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Expanded(
                                              flex: 1,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                    CustomIcons.categories,
                                                    color: Constants.redColor,
                                                    size: 22),
                                              )),
                                          Expanded(
                                              flex: 2,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  Navigator.popUntil(
                                                      context,
                                                      ModalRoute.withName(
                                                          "/Home"));
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              HomePage()));
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CategoriesPage()));
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, left: 10),
                                                  child: AutoSizeText(
                                                    'Categories'.tr(),
                                                    style: TextStyle(
                                                      color: Constants.redColor,
                                                    ),
                                                    maxFontSize:
                                                        Constants.fontSize,
                                                    minFontSize:
                                                        Constants.fontSize - 2,
                                                  ),
                                                ),
                                              )),
                                          Expanded( //loading
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                        backgroundColor: Colors.grey,
                                                        valueColor: new AlwaysStoppedAnimation<Color>(Constants.redColor),
                                                    strokeWidth: 3,
                                                  )),
                                            ),
                                          )
                                        ],
                                      )),
                                  trailing: SizedBox.shrink(),
                                ));
                          }
                          var response = snap.data;
                          if (response is String) {
                            return SideMenuItemWidget(
                              name: 'Categories',
                              icon: CustomIcons.categories,
                              pageToNavigate: CategoriesPage(),
                            );
                          }
                          final theme = Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ); //new
                          List<CategoryWidget> categories =
                              response as List<CategoryWidget>;
                          return Theme(
                            data: theme,
                            child: ListTileTheme(
                              dense: true,
                              contentPadding: EdgeInsets.all(0),
                              child: ExpansionTile(
                                  onExpansionChanged: (expanded) {
                                    if (expanded) {
                                      arabicLanguage
                                          ? rotationController.forward(
                                              from: 0.0)
                                          : rotationController.forward(
                                              from: 0.0);
                                    } else {
                                      arabicLanguage
                                          ? rotationController.reverse(
                                              from: -0.5)
                                          : rotationController.reverse(
                                              from: 0.5);
                                    }
                                  },
                                  title: Container(
                                    color: Colors.transparent,
                                    padding: EdgeInsets.only(top: 2, bottom: 2),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                  CustomIcons.categories,
                                                  color: Constants.redColor,
                                                  size: 22),
                                            )),
                                        Expanded(
                                            flex: 2,
                                            child: GestureDetector(
                                              onTap: () async {
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                Navigator.pop(context);
                                                Navigator.popUntil(
                                                    context,
                                                    ModalRoute.withName(
                                                        "/Home"));
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            HomePage()));
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CategoriesPage()));
                                                setState(() {
                                                  itemsInCart = prefs.getInt(
                                                      Constants
                                                          .keyNumberOfItemsInCart);
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: 10, left: 10),
                                                child: AutoSizeText(
                                                  'Categories'.tr(),
                                                  style: TextStyle(
                                                    color: Constants.redColor,
                                                  ),
                                                  maxFontSize:
                                                      Constants.fontSize,
                                                  minFontSize:
                                                      Constants.fontSize - 2,
                                                ),
                                              ),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: RotationTransition(
                                              turns: arabicLanguage
                                                  ? Tween(begin: 0.0, end: -0.5)
                                                      .animate(
                                                          rotationController)
                                                  : Tween(begin: 0.0, end: 0.5)
                                                      .animate(
                                                          rotationController),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: arabicLanguage
                                                    ? Transform.rotate(
                                                        angle: -3.14,
                                                        child: Icon(
                                                            MyFlutterApp
                                                                .group_640,
                                                            color: Constants
                                                                .redColor,
                                                            size: 15),
                                                      )
                                                    : Icon(
                                                        MyFlutterApp.group_640,
                                                        color:
                                                            Constants.redColor,
                                                        size: 15),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  tilePadding: EdgeInsets.zero,
                                  trailing: SizedBox.shrink(),
                                  children: List.generate(
                                      categories.length,
                                      (index) => Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 100, vertical: 7),
                                            child: InkWell(
                                              onTap: () {
                                                if (categories[index]
                                                    .hasSubCategories!) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SubCategoriesPage(
                                                                fromSideMenu: true,
                                                                categoryId:
                                                                    categories[
                                                                            index]
                                                                        .id,
                                                                categoryNameEn:
                                                                    categories[
                                                                            index]
                                                                        .nameEn,
                                                                categoryNameAr:
                                                                    categories[
                                                                            index]
                                                                        .nameAr,
                                                              )));
                                                } else {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                                  ProductsPage(
                                                                    categoryId:
                                                                        categories[index]
                                                                            .id,
                                                                    categoryNameEn:
                                                                        categories[index]
                                                                            .nameEn,
                                                                    categoryNameAr:
                                                                        categories[index]
                                                                            .nameAr,
                                                                    subCategoryId:
                                                                        null,
                                                                    subCategoryNameAr:
                                                                        null,
                                                                    subCategoryNameEn:
                                                                        null,
                                                                  )));
                                                }
                                              },
                                              child: Row(children: [
                                                AutoSizeText(
                                                  arabicLanguage
                                                      ? categories[index].nameAr!
                                                      : categories[index]
                                                          .nameEn!,
                                                  style: TextStyle(
                                                      color: Constants.redColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  maxFontSize:
                                                      Constants.fontSize,
                                                  minFontSize:
                                                      Constants.fontSize - 2,
                                                ),
                                              ]),
                                            ),
                                          ))),
                            ),
                          );
                        }),
                    SideMenuItemWidget(
                      name: 'Offers',
                      icon: CustomIcons.offers,
                      pageToNavigate: OffersPage(),
                    ),
                    authenticated
                        ? SideMenuItemWidget(
                            name: 'My Addresses',
                            icon: CustomIcons.address,
                            pageToNavigate: MyAddressesPage(),
                          )
                        : Container(),
                    authenticated
                        ? SideMenuItemWidget(
                            name: 'My Cart',
                            icon: CustomIcons.cart,
                            pageToNavigate: CartPage(fromSideMenu: true,),
                            badgeNumber: itemsInCart,
                          )
                        : Container(),
                    authenticated
                        ? SideMenuItemWidget(
                            name: 'Orders History',
                            icon: CustomIcons.orders_history,
                            pageToNavigate: OrdersHistoryPage(),
                          )
                        : Container(),
                    authenticated
                        ? SideMenuItemWidget(
                            name: 'Notifications',
                            icon: unreadNotifications
                                ? CustomIcons.unread_notification
                                : CustomIcons.read_notification,
                            pageToNavigate: NotificationsPage(),
                          )
                        : Container(),
                    authenticated
                        ? SideMenuItemWidget(
                            name: 'Profile',
                            icon: CustomIcons.profile,
                            pageToNavigate: ProfilePage(),
                          )
                        : Container(),
                    authenticated
                        ? SideMenuItemWidget(
                            name: 'Settings',
                            icon: CustomIcons.settings,
                            pageToNavigate: SettingsPage(),
                          )
                        : SideMenuItemWidget(
                            name: 'Settings',
                            icon: CustomIcons.settings,
                            pageToNavigate: GuestSettingsPage(),
                          ),
                    SideMenuItemWidget(
                      name: 'FAQs',
                      icon: MyFlutterApp.faq,
                      pageToNavigate: FAQsPage(),
                    ),
                    SideMenuItemWidget(
                      name: 'Returns & Exchange',
                      icon: CustomIcons.returns_and_exchange,
                      pageToNavigate: ReturnsAndExchangePage(),
                    ),
                    SideMenuItemWidget(
                      name: 'Privacy Policy',
                      icon: CustomIcons.privacy_policy,
                      pageToNavigate: PrivacyPolicyPage(),
                    ),
                    authenticated
                        ? GestureDetector(
                            onTap: () => logout(),
                            child: SideMenuItemWidget(
                              name: 'Logout',
                              icon: CustomIcons.login,
                              pageToNavigate: null,
                            ))
                        : SideMenuItemWidget(
                            name: 'Login',
                            icon: CustomIcons.logout,
                            pageToNavigate: LoginPage(),
                          ),
                  ],
                ),
              )
            ]),
            arabicLanguage
                ? Positioned(
                    right: 60,
                    child: Container(
                        width: 0.5,
                        height: MediaQuery.of(context).size.height,
                        decoration:
                            BoxDecoration(color: Colors.grey[200], boxShadow: [
                          BoxShadow(
                            color: Constants.identityColor,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ])),
                  )
                : Positioned(
                    left: 65,
                    child: Container(
                        width: 0.5,
                        height: MediaQuery.of(context).size.height,
                        decoration:
                            BoxDecoration(color: Colors.grey[200], boxShadow: [
                          BoxShadow(
                            color: Constants.identityColor,
                            blurRadius: 1,
                            offset: Offset(1, 0),
                          ),
                        ])),
                  ),
          ],
        )),
      ),
    );
  }

  Future getCategories() async {
    AsyncMemoizer memoizer = AsyncMemoizer();
    return memoizer.runOnce(() async {
      final String url = 'get-categories';
      final response = await http.get(Uri.parse(Constants.apiUrl + url) ,
          headers: {'referer': Constants.apiReferer});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'] as List;
          List<CategoryWidget> categories = [];
          for (int i = 0; i < data.length; i++) {
            categories.add(CategoryWidget(
              id: data[i]['id'].toString(),
              nameEn: data[i]['name_en'],
              nameAr: data[i]['name_ar'],
              imagePath: data[i]['icon'],
              hasSubCategories: data[i]['has_sub_categories'],
            ));
          }
          return categories;
        }
        return data['message'].toString();
      }
      return Constants.requestErrorMessage;
    });
  }

  logout() async {
    CustomDialog(
      context: context,
      title: "Confirm Logout".tr(),
      message: "Are you sure you want to Logout?".tr(),
      okButtonTitle: 'Ok'.tr(),
      cancelButtonTitle: 'Cancel'.tr(),
      onPressedCancelButton: () {
        Navigator.pop(context);
      },
      onPressedOkButton: () async {
        final String url = 'get-cart-page-content';
        final prefs = await SharedPreferences.getInstance();
        String accessToken = prefs.getString(Constants.keyAccessToken)!;
        final response = await http.post(Uri.parse(Constants.apiUrl + url), headers: {
          'Authorization': 'Bearer ' + accessToken,
          'referer': Constants.apiReferer
        });

        if (response.statusCode == 200) {
          prefs.clear();
          prefs.setBool(Constants.keyFirstRunOfApp, false);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
        }
      },
      color: Constants.exitDialogColor,
      icon: "assets/images/warning.svg",
    ).showCustomDialog();
  }
}
