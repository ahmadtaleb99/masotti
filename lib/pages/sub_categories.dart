import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './products.dart';
import '../widgets/sub_category.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import 'home_page.dart';

// was stateless
class SubCategoriesPage extends StatefulWidget {
  final bool fromSideMenu;
  final String? categoryId;
  final String? categoryNameEn;
  final String? categoryNameAr;

  SubCategoriesPage(
      {required this.fromSideMenu,
      required this.categoryId,
      required this.categoryNameEn,
      required this.categoryNameAr});

  @override
  _SubCategoriesPageState createState() => _SubCategoriesPageState();
}

class _SubCategoriesPageState extends State<SubCategoriesPage> {
  int? itemsInCart = 0;
  bool authenticated = false;
  double spacing = 0.0;

  @override
  void initState() {
    super.initState();
    getItemsInCartCount();
  }

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      authenticated =
          prefs.getString(Constants.keyAccessToken) != null ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    spacing = containerWidth / 25;
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: arabicLanguage ? widget.categoryNameAr : widget.categoryNameEn,
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: authenticated ? true : false,
      ),
      drawer: SideMenu(),
      body: widget.fromSideMenu
          ? WillPopScope(
              onWillPop: () {
                Navigator.pop(context);
                Navigator.popUntil(context, ModalRoute.withName("/Home"));
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
                return Future.value(true);
              },
              child: getBody(),
            )
          : getBody(),
    );
  }

  Widget getBody() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topRight: Radius.circular(Constants.borderRadius * 2),
          topLeft: Radius.circular(Constants.borderRadius * 2)),
      child: Container(
        color: Constants.whiteColor,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Constants.padding),
          child: FutureBuilder(
            future: getSubCategories(widget.categoryId),
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
                return RequestEmptyData(message: response);
              }
              List<SubCategoryWidget> subCategories =
                  response as List<SubCategoryWidget>;
              return SingleChildScrollView(
                child: Wrap(
                  spacing: spacing -
                      (MediaQuery.of(context).devicePixelRatio > 1.2 ? 4 : 0),
                  children: List.generate(subCategories.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductsPage(
                                      categoryId: null,
                                      categoryNameEn: null,
                                      categoryNameAr: null,
                                      subCategoryId: subCategories[index].id,
                                      subCategoryNameEn:
                                          subCategories[index].nameEn,
                                      subCategoryNameAr:
                                          subCategories[index].nameAr,
                                    ))).then(
                          (value) => setState(() {
                            getItemsInCartCount();
                          }),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: Constants.padding),
                        child: subCategories[index],
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future getSubCategories(categoryId) async {
    AsyncMemoizer memoizer = AsyncMemoizer();
    return memoizer.runOnce(() async {
      final String url = 'get-sub-categories?category_id=$categoryId';
      final response = await http.get(Uri.parse(Constants.apiUrl + url) ,
          headers: {'referer': Constants.apiReferer});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'] as List;
          List<SubCategoryWidget> subCategories = [];
          for (int i = 0; i < data.length; i++) {
            subCategories.add(SubCategoryWidget(
              id: data[i]['id'].toString(),
              nameEn: data[i]['name_en'],
              nameAr: data[i]['name_ar'],
              imagePath: data[i]['icon'],
            ));
          }
          return subCategories;
        }
        return data['message'].toString();
      }
      return Constants.requestErrorMessage;
    });
  }
}
