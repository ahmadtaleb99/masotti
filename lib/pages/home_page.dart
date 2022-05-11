import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import '../pages/sub_categories.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import '../widgets/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/my_flutter_app_icons.dart';
import '../pages/products.dart';
import '../widgets/alert_dialog.dart';
import 'dart:convert';
import './categories.dart';
import './product.dart';
import '../models/featured_category.dart';
import '../widgets/product.dart';
import '../widgets/request_empty_data.dart';
import '../constants.dart';
import '../assets/flutter_custom_icons.dart';
import '../widgets/home_page_appbar.dart';
import '../side_menu.dart';
import '../models/home_page.dart';
import '../models/featured_product.dart';
import '../widgets/who_are_we_button.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:meta/meta.dart';
// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:path_provider/path_provider.dart';

import 'package:flutter/scheduler.dart' as Scheduler;
import 'package:uni_links/uni_links.dart';
import 'dart:async';

bool _initialUriIsHandled = false;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final AsyncMemoizer _homePageMemoizer = AsyncMemoizer();
  List<LatestProduct> displayedLatestProducts = [];
  String? activeFeaturedCategoryID;
  late LatestCategory activeLatestCategory;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool arabicLanguage = false;
  DateTime? currentBackPressTime;

  // final notifications = FlutterLocalNotificationsPlugin();

  Uri? _initialUri = Uri();
  Object? _err;

  StreamSubscription? _sub;

  int? itemsInCart = 0;
  bool authenticated = false;

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      print('  items in cart : : : : :');
      print(prefs.getInt(Constants.keyNumberOfItemsInCart).toString() + '  items in cart : : : : :');

      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      authenticated =
          prefs.getString(Constants.keyAccessToken) != null ? true : false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _handleInitialUri();
    getItemsInCartCount();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Handle the initial Uri - the one the app was started with
  ///
  /// **ATTENTION**: `getInitialLink`/`getInitialUri` should be handled
  /// ONLY ONCE in your app's lifetime, since it is not meant to change
  /// throughout your app's life.
  ///
  /// We handle all exceptions, since it is called from initState.
  Future<void> _handleInitialUri() async {
    // In this example app this is an almost useless guard, but it is here to
    // show we are not going to call getInitialUri multiple times, even if this
    // was a weidget that will be disposed of (ex. a navigation route change).
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri: $uri');
          Scheduler.SchedulerBinding.instance!.addPostFrameCallback((_) {
            if (_initialUri != null) {
              print('uri: ' + uri.toString());
              List<String> splitted = uri.toString().split('/');
              if (splitted[splitted.length - 2] == 'products')
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProductPage(id: splitted[splitted.length - 1])));
            }
          });
        }
        if (!mounted) return;
        _initialUri = uri;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('failed to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        _err = err;
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double spacing = containerWidth / 25;
    double featuredCategoriesContainerWidth =
        containerWidth - (Constants.doublePadding);
    double featuredCategoryContainerWidth =
        featuredCategoriesContainerWidth * 100 / 335;
    double featuredCategoryContainerHeight =
        featuredCategoryContainerWidth / 4 * 3;
    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.whiteColor,
      drawer: SideMenu(),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          child: FutureBuilder(
            future: _getHomePageElements(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: ColoredCircularProgressIndicator(),
                    ));
              }
              var response = snap.data;
              if (response is String) {
                return Container(
                    margin: EdgeInsets.only(top: Constants.padding),
                    child: RequestEmptyData(
                      message: response,
                    ));
              }
              HomePageData homePageData = response as HomePageData;
              return SingleChildScrollView(
                  child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: HomePageAppBarWidget(
                      height: (MediaQuery.of(context).size.width / 4 * 3) +
                          ((MediaQuery.of(context).size.width / 4 * 3) /
                              10 *
                              2),
                      icon: MyFlutterApp.component_1___79,
                      images: homePageData.sliderImages!,
                      products: homePageData.sliderProducts,
                      scaffoldKey: _scaffoldKey,
                      itemsInCart: itemsInCart,
                      cartIconExist: authenticated ? true : false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width / 4 * 3 +
                            ((MediaQuery.of(context).size.width / 4 * 3) / 10) -
                            25),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[500]!,
                              blurRadius: 10,
                              offset: Offset(1, 1),
                            ),
                          ]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25)),
                        child: Container(
                          color: Constants.whiteColor,
                          padding: EdgeInsets.only(
                              top: Constants.padding,
                              right: Constants.padding,
                              left: Constants.padding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(
                                      top: Constants.padding,
                                      bottom: Constants.halfPadding),
                                  child: Text(
                                    'LATEST PRODUCTS'.tr(),
                                    style: TextStyle(
                                      color: Colors.transparent,
                                      fontSize: Constants.fontSize + 4,
                                      fontWeight: FontWeight.bold,
                                      decorationColor: Constants.redColor,
                                      decorationThickness: 30,
                                      decoration: TextDecoration.underline,
                                      decorationStyle:
                                          TextDecorationStyle.solid,
                                      shadows: [
                                        Shadow(
                                          color: Constants.redColor,
                                          offset: Offset(0, -10),
                                        ),
                                      ],
                                    ),
                                  )),
                              Container(
                                  padding: EdgeInsets.only(
                                      bottom: Constants.padding),
                                  width: featuredCategoriesContainerWidth,
                                  height: featuredCategoryContainerHeight - 10,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: List.generate(
                                          homePageData.latestCategories!.length,
                                          (index) {
                                        return GestureDetector(
                                            onTap: () {
                                              _changeDisplayedFeaturedProducts(
                                                  homePageData,
                                                  homePageData
                                                          .latestCategories![
                                                      index]);
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: activeFeaturedCategoryID ==
                                                              homePageData
                                                                  .latestCategories![
                                                                      index]
                                                                  .id
                                                          ? Constants
                                                              .borderColor!
                                                          : Colors.grey[400]!),
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(Constants
                                                              .borderRadius +
                                                          2))),
                                              elevation:
                                                  activeFeaturedCategoryID ==
                                                          homePageData
                                                              .latestCategories![
                                                                  index]
                                                              .id
                                                      ? 5
                                                      : 1,
                                              child: Container(
                                                width:
                                                    featuredCategoryContainerWidth,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius
                                                      .all(Radius.circular(
                                                          Constants
                                                              .borderRadius)),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    margin:
                                                        EdgeInsets.only(top: 5),
                                                    child: AutoSizeText(
                                                      arabicLanguage
                                                          ? homePageData
                                                              .latestCategories![
                                                                  index]
                                                              .nameAr!
                                                          : homePageData
                                                              .latestCategories![
                                                                  index]
                                                              .nameEn!,
                                                      style: TextStyle(
                                                          color: Constants
                                                              .identityColor,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      minFontSize:
                                                          Constants.fontSize -
                                                              2,
                                                      maxFontSize:
                                                          Constants.fontSize,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ));
                                      }))),
                              Container(
                                width: containerWidth,
                                padding:
                                    EdgeInsets.only(bottom: Constants.padding),
                                child: Wrap(
                                    spacing: spacing -
                                        (MediaQuery.of(context)
                                                    .devicePixelRatio >
                                                1.2
                                            ? 4
                                            : 0),
                                    runSpacing: 10,
                                    children: displayedLatestProducts.length !=
                                            0
                                        ? List.generate(
                                            displayedLatestProducts.length,
                                            (productIndex) {
                                            return GestureDetector(
                                              onTap: () async {
                                                print('pressed');
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProductPage(
                                                              id: displayedLatestProducts[
                                                                      productIndex]
                                                                  .id,
                                                            ))).then(
                                                  (value) => setState(() {

                                                    getItemsInCartCount();
                                                  }),
                                                );
                                              },
                                              child: Builder(
                                                builder: (context) {

                                                  return ProductWidget(
                                                    id: displayedLatestProducts[
                                                            productIndex]
                                                         .id,
                                                    nameEn: displayedLatestProducts[
                                                            productIndex]
                                                        .nameEn,
                                                    nameAr: displayedLatestProducts[
                                                            productIndex]
                                                        .nameAr,
                                                    imagePath:
                                                        displayedLatestProducts[
                                                                productIndex]
                                                            .imagePath,
                                                    price: displayedLatestProducts[
                                                            productIndex]
                                                        .price
                                                        .toString(),
                                                    salesPrice:
                                                        displayedLatestProducts[
                                                                productIndex]
                                                            .salesPrice
                                                            .toString()
                                                            .toLowerCase(),
                                                  );
                                                }
                                              ),
                                            );
                                          })
                                        : [
                                            RequestEmptyData(
                                              message: Constants
                                                  .requestNoDataMessage,
                                            )
                                          ]),
                              ),
                              Container(
                                width: containerWidth,
                                padding:
                                    EdgeInsets.only(bottom: Constants.padding),
                                child: GestureDetector(
                                  onTap: () {
                                    if (activeLatestCategory
                                        .hasSubCategories!) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SubCategoriesPage(
                                                    fromSideMenu: false,
                                                    categoryId:
                                                        activeLatestCategory.id,
                                                    categoryNameEn:
                                                        activeLatestCategory
                                                            .nameEn,
                                                    categoryNameAr:
                                                        activeLatestCategory
                                                            .nameAr,
                                                  ))).then(
                                        (value) => setState(() {
                                          getItemsInCartCount();
                                        }),
                                      );
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductsPage(
                                                    categoryId:
                                                        activeLatestCategory.id,
                                                    categoryNameEn:
                                                        activeLatestCategory
                                                            .nameEn,
                                                    categoryNameAr:
                                                        activeLatestCategory
                                                            .nameAr,
                                                    subCategoryId: null,
                                                    subCategoryNameAr: null,
                                                    subCategoryNameEn: null,
                                                  ))).then(
                                        (value) => setState(() {
                                          getItemsInCartCount();
                                        }),
                                      );
                                    }
                                  },
                                  child: Card(
                                    elevation: 4,
                                    color: Constants.redColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                Constants.borderRadius))),
                                    child: Container(
                                      margin: EdgeInsets.only(top: 3),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: Constants.padding),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AutoSizeText(
                                            arabicLanguage
                                                ? 'See more '.tr() +
                                                    activeLatestCategory.nameAr!
                                                : 'See more '.tr() +
                                                    activeLatestCategory
                                                        .nameEn!,
                                            style: TextStyle(
                                                color: Constants.whiteColor,
                                                fontWeight: FontWeight.bold),
                                            minFontSize: Constants.fontSize - 2,
                                            maxFontSize: Constants.fontSize,
                                          ),
                                          arabicLanguage
                                              ? Transform.rotate(
                                                  angle: -3.14,
                                                  child: Icon(
                                                    MyFlutterApp.group_640,
                                                    color: Constants.whiteColor,
                                                    size: 12,
                                                  ),
                                                )
                                              : Icon(
                                                  MyFlutterApp.group_640,
                                                  color: Constants.whiteColor,
                                                  size: 12,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              homePageData.displayAboutBtn!
                                  ? WhoAreWeButton()
                                  : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
            },
          ),
        ),
      ),
    );
  }

  Future _getHomePageElements() async {
    return _homePageMemoizer.runOnce(() async {
      final String url = 'get-home-page-data';
      HomePageData homePageData;
      final response = await http.get(Uri.parse((Constants.apiUrl + url)),
          headers: {'referer': Constants.apiReferer});
      log(response.body);
      if (response.statusCode == 200) {
        homePageData = HomePageData();
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'];
          var homePageSlider = data['homepage_sliders'] as List;
          homePageData.sliderImages = [];
          homePageData.sliderProducts = [];
          for (int i = 0; i < homePageSlider.length; i++) {
            homePageData.sliderImages!.add(
              homePageSlider[i]['slide_image'].toString(),
            );
            homePageData.sliderProducts!.add(
              homePageSlider[i]['product_id'] != null
                  ? homePageSlider[i]['product_id'].toString()
                  : 'null',
            );
          }
          homePageData.displayAboutBtn = data['show_who_are_we_btn'] != null
              ? data['show_who_are_we_btn'].toString() == '1'
                  ? true
                  : false
              : false;
          homePageData.availableOffers =
              data['available_offers'].toString() == 'true' ? true : false;
          var featuredCategoriesList = data['latest_categories'] as List;
          homePageData.latestCategories = [];
          for (int i = 0; i < featuredCategoriesList.length; i++) {
            var subCategories =
                featuredCategoriesList[i]['subCategories'] as List;
            print(subCategories.length.toString());
            homePageData.latestCategories!.add(LatestCategory.fromValues(
              id: featuredCategoriesList[i]['id'].toString(),
              nameEn: featuredCategoriesList[i]['name_en'],
              nameAr: featuredCategoriesList[i]['name_ar'],
              hasSubCategories: subCategories.length > 0 ? true : false,
            ));
          }

          activeLatestCategory = homePageData.latestCategories![0];
          var featuredProductsList = data['latest_products'] as List;
          homePageData.latestProducts = [];
          for (int j = 0; j < featuredProductsList.length; j++) {
            String categoryId =
                featuredProductsList[j]['category_id'].toString();
            List products = featuredProductsList[j]['products'] as List;
            for (int k = 0; k < products.length; k++) {
              LatestProduct product = LatestProduct.fromValues(
                  categoryId: categoryId,
                  id: products[k]['id'],
                  nameEn: products[k]['name_en'],
                  nameAr: products[k]['name_ar'],
                  imagePath: products[k]['images'][0]['path'],
                  price: double.parse(products[k]['price']),
                  salesPrice:
                      products[k]['sales_price'].toString().toLowerCase());
              homePageData.latestProducts!.add(product);
              if (j == 0) {
                displayedLatestProducts.add(product);
              }
            }
            if (j == 0) {
              activeFeaturedCategoryID = categoryId;
            }
          }
          return homePageData;
        }
        return Constants.requestNoDataMessage;
      }
      return Constants.requestErrorMessage;
    });
  }

  _changeDisplayedFeaturedProducts(
      HomePageData homePageData, LatestCategory category) {
    setState(() {
      getItemsInCartCount();
      displayedLatestProducts.clear();
      for (int i = 0; i < homePageData.latestProducts!.length; i++) {
        if (homePageData.latestProducts![i].categoryId == category.id) {
          displayedLatestProducts.add(homePageData.latestProducts![i]);
        }
      }
      activeFeaturedCategoryID = category.id;
      activeLatestCategory = category;
    });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      CustomDialog(
        context: context,
        title: "Confirm Exit".tr(),
        message: "Are you sure you want to exit?".tr(),
        okButtonTitle: 'Ok'.tr(),
        cancelButtonTitle: 'Cancel'.tr(),
        onPressedCancelButton: () {
          Navigator.pop(context);
        },
        onPressedOkButton: () {
          SystemNavigator.pop();
        },
        color: Constants.exitDialogColor,
        icon: "assets/images/warning.svg",
      ).showCustomDialog();
      return Future.value(false);
    }
    return Future.value(true);
  }

// Future<NotificationDetails> _image(BuildContext context, Image picture) async {
//   final picturePath = await saveImage(context, picture);
//
//   final bigPictureStyleInformation = BigPictureStyleInformation(
//     picturePath,
//     BitmapSource.FilePath,
//   );
//
//   final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     'big text channel id',
//     'big text channel name',
//     'big text channel description',
//     style: AndroidNotificationStyle.BigPicture,
//     styleInformation: bigPictureStyleInformation,
//   );
//   return NotificationDetails(androidPlatformChannelSpecifics, null);
// }
//
// Future showImageNotification(
//     BuildContext context,
//     FlutterLocalNotificationsPlugin notifications, {
//       @required String title,
//       @required String body,
//       @required Image picture,
//       int id = 0,
//     }) async =>
//     notifications.show(id, title, body, await _image(context, picture));
//
// Future<String> _downloadAndSaveFile(String url, String fileName) async {
//   final Directory directory = await getApplicationDocumentsDirectory();
//   final String filePath = '${directory.path}/$fileName';
//   final http.Response response = await http.get(Uri.parse(url));
//   final File file = File(filePath);
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
// }
//
// Future<void> _showBigPictureNotification() async {
//   final String largeIconPath = await _downloadAndSaveFile(
//       'https://via.placeholder.com/48x48', 'largeIcon');
//   final String bigPicturePath = await _downloadAndSaveFile(
//       'https://via.placeholder.com/400x800', 'bigPicture');
//   final BigPictureStyleInformation bigPictureStyleInformation =
//   BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
//       largeIcon: FilePathAndroidBitmap(largeIconPath),
//       contentTitle: 'overridden <b>big</b> content title',
//       htmlFormatContentTitle: true,
//       summaryText: 'summary <i>text</i>',
//       htmlFormatSummaryText: true);
//   final AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails('big text channel id',
//       'big text channel name', 'big text channel description',
//       styleInformation: bigPictureStyleInformation);
//   final NotificationDetails platformChannelSpecifics =
//   NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       0, 'big text title', 'silent body', platformChannelSpecifics);
// }
}
