import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:masotti/services/dialog_service.dart';
import 'package:masotti/services/networking/network_helper.dart';
import 'package:masotti/widgets/custom_red_button.dart';
import 'package:masotti/widgets/error_widget.dart';
import '../main.dart';
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
import 'package:flutter/scheduler.dart' as Scheduler;
import 'package:uni_links/uni_links.dart' as UniLinks;
import 'dart:async';




bool initialUriIsHandled = false;
StreamSubscription<String?> ? _incomingUriStream ;
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
    // _handleInitialUri();
    // _handleIncomingUri();
    getItemsInCartCount();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _incomingUriStream?.cancel();
    super.dispose();
  }




  Future<void> _handleInitialUri() async {

    if (!initialUriIsHandled) {
      initialUriIsHandled = true;
      try {
        final uri = await UniLinks.getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          log('got initial uri');
          goToProductFromUri(uri);
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


  void goToProductFromUri(Uri uri){
    Scheduler.SchedulerBinding.instance!.addPostFrameCallback((_) {
        List<String> splitted = uri.toString().split('=');

        log(uri.toString().split('=').toString());
        navigatorKey.currentState!.push(MaterialPageRoute(
            builder: (context) =>
                ProductPage(id: splitted.last)));


    });

  }
  void _handleIncomingUri (){

    if(initialUriIsHandled){
      _incomingUriStream = UniLinks.linkStream.listen((uri) {

       goToProductFromUri(Uri.parse(uri!));

      });
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


    double noItemscontainerWidths = containerWidth / 100 * 48;
    double noItemscontainerHeight = (noItemscontainerWidths + (containerWidth / 100 * 5)) * 2 ;

    Radius radius = Radius.circular(Constants.borderRadius);

    arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    BorderRadius borderRadius = arabicLanguage
    ? BorderRadius.only(bottomLeft: radius, topLeft: radius)
        : BorderRadius.only(bottomRight: radius, topRight: radius);
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
              if(snap.hasError){
                return Column(

                  children: [

                    Align(
                      alignment: arabicLanguage ? Alignment.topRight : Alignment.topLeft,
                      child: Container(
                          width: 60,
                          height: 40,
                          margin: EdgeInsets.only(top: 40),
                          decoration: BoxDecoration(
                              borderRadius: borderRadius, color: Constants.identityColor.withOpacity(0.1  )),
                          child: IconButton(
                              icon: SvgPicture.asset(
                                Constants.sideMenuImage,
                              ),
                              color: Constants.identityColor,
                              onPressed: () => Scaffold.of(context).openDrawer()
                          )),
                    ),
                    SizedBox(height: 200,),
                    CustomErrorWidget(errorText: snap.error.toString(),onRetry : (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage()));
                    })

                  ],
                );

              }
              if (!snap.hasData) {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: ColoredCircularProgressIndicator(),
                    ));
              }
              var response = snap.data;
              if (response is String) {
                return Column(

                  children: [

                    Align(
                      alignment: arabicLanguage ? Alignment.topRight : Alignment.topLeft,
                      child: Container(
                          width: 60,
                          height: 40,
                          margin: EdgeInsets.only(top: 40),
                          decoration: BoxDecoration(
                              borderRadius: borderRadius, color: Constants.identityColor.withOpacity(0.1  )),
                          child: IconButton(
                              icon: SvgPicture.asset(
                                Constants.sideMenuImage,
                              ),
                              color: Constants.identityColor,
                              onPressed: () => Scaffold.of(context).openDrawer()
                          )),
                    ),

                    RequestEmptyData(message: response)
                  ],
                );
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
                                            Container(
                                              height: noItemscontainerHeight,
                                              child: RequestEmptyData(
                                                message: Constants
                                                    .requestNoDataMessage,
                                              ),
                                            )
                                          ]),
                              ),
                              displayedLatestProducts.length > 0 ?   Container(
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
                              ) : Container(),
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

        homePageData = HomePageData();
        try {
          var data  = await  NetworkingHelper.getData(url);
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
        catch (e) {
          rethrow  ;
        }

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
