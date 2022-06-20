import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './sub_categories.dart';
import './products.dart';
import '../widgets/category.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import 'home_page.dart';

// was stateless
class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int? itemsInCart = 0;
  bool authenticated = false;

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
    double spacing = containerWidth / 25;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Categories',
        showBackButton: true,
        currentContext: context,
        itemsInCart: itemsInCart,
        cartIconExist: authenticated ? true : false,
      ),
      drawer: SideMenu(),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName("/Home"));
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
          return Future.value(true);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(Constants.borderRadius * 2),
              topLeft: Radius.circular(Constants.borderRadius * 2)),
          child: Container(
            color: Constants.whiteColor,
            height: double.infinity,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Constants.padding),
              child: FutureBuilder(
                future: getCategories(),
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
                    return RequestEmptyData(
                      message: response,
                    );
                  }
                  List<CategoryWidget> categories =
                      response as List<CategoryWidget>;
                  return SingleChildScrollView(
                    child: Container(
                        child: Wrap(
                      spacing: spacing -
                          (MediaQuery.of(context).devicePixelRatio > 1.2
                              ? 4
                              : 0),
                      children: List.generate(categories.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            if (categories[index].hasSubCategories!) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SubCategoriesPage(
                                        fromSideMenu: false,
                                            categoryId: categories[index].id,
                                            categoryNameEn:
                                                categories[index].nameEn,
                                            categoryNameAr:
                                                categories[index].nameAr,
                                          ))).then(
                                (value) => setState(() {
                                  getItemsInCartCount();
                                }),
                              );
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductsPage(
                                            categoryId: categories[index].id,
                                            categoryNameEn:
                                                categories[index].nameEn,
                                            categoryNameAr:
                                                categories[index].nameAr,
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
                          child: Container(
                            margin: EdgeInsets.only(bottom: Constants.padding),
                            child: categories[index],
                          ),
                        );
                      }),
                    )),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future getCategories() async {
    AsyncMemoizer memoizer = AsyncMemoizer();
    return memoizer.runOnce(() async {
      final String url = 'get-categories';
      final response = await http.get(Uri.parse(Constants.apiUrl + url),
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
}
