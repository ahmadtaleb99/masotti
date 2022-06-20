import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/widgets/colored_circular_progress_indicator.dart';
import 'package:masotti/widgets/request_empty_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import './product.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/product.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class ProductsPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryNameEn;
  final String? categoryNameAr;

  final String? subCategoryId;
  final String? subCategoryNameEn;
  final String? subCategoryNameAr;

  ProductsPage({
    required this.categoryId,
    required this.categoryNameEn,
    required this.categoryNameAr,
    required this.subCategoryId,
    required this.subCategoryNameEn,
    required this.subCategoryNameAr,
  });

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  static const _pageSize = 10;

  final PagingController<int, ProductWidget> _pagingController =
      PagingController(firstPageKey: 0);

  int? itemsInCart = 0;
  bool authenticated = false;

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
      authenticated =
          prefs.getString(Constants.keyAccessToken) != null ? true : false;
    });
  }

  @override
  void initState() {
    print('inited');
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    getItemsInCartCount();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          await getProducts(widget.categoryId, widget.subCategoryId, pageKey);

      final isLastPage = newItems.length <= _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);

      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('products page ');
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double spacing = containerWidth / 25;
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
        backgroundColor: Constants.identityColor,
        appBar: CustomAppBarWidget(
          title: arabicLanguage
              ? (widget.categoryNameAr != null
                  ? widget.categoryNameAr
                  : widget.subCategoryNameAr)
              : (widget.categoryNameEn != null
                  ? widget.categoryNameEn
                  : widget.subCategoryNameEn),
          currentContext: context,
          itemsInCart: itemsInCart,
          showBackButton: true,

          cartIconExist: authenticated ? true : false,
        ),
        drawer: SideMenu(),
        body: ClipRRect(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(Constants.borderRadius * 2),
              topLeft: Radius.circular(Constants.borderRadius * 2)),
          child: Container(
            color: Constants.whiteColor,
            height: double.infinity,
            padding: EdgeInsets.all(Constants.padding),
            child:
            // _noItems ? RequestEmptyData(
            //
            //   message: Constants.requestNoDataMessage,
            // )  :
            PagedGridView<int, ProductWidget>(

            showNewPageErrorIndicatorAsGridChild: true,
              showNoMoreItemsIndicatorAsGridChild: true,
              pagingController: _pagingController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.15,
                crossAxisSpacing: spacing -
                    (MediaQuery.of(context).devicePixelRatio > 1.2 ? 4 : 0),
                mainAxisSpacing: spacing -
                    (MediaQuery.of(context).devicePixelRatio > 1.2 ? 4 : 0),
                crossAxisCount: 2,
              ),
              builderDelegate: PagedChildBuilderDelegate<ProductWidget>(


                  itemBuilder: (context, item, index) => GestureDetector(
                        onTap: () {

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductPage(
                                        id: item.id,
                                      ))).then(
                            (value) => setState(() {
                              getItemsInCartCount();
                            }),
                          );
                        },
                        child: Container(
                          child: item,
                        ),
                      ),
                firstPageProgressIndicatorBuilder: (context) => ColoredCircularProgressIndicator(),
                noItemsFoundIndicatorBuilder:  (_) =>     RequestEmptyData(
                 message: Constants.requestNoDataMessage,
               )  ,
                newPageProgressIndicatorBuilder: (context) => ColoredCircularProgressIndicator(),
              ),
            ),
          ),
        ));
  }

  Future getProducts(categoryId, subCategoryId, page) async {
    print('hon');
    String url = 'get-products-of-' +
        (categoryId != null
            ? 'category?category_id=$categoryId'
            : 'sub-category2?sub_category_id=$subCategoryId' + '&page=$page');
    print (url);
    final response = await http.get(Uri.parse(Constants.apiUrl + url),

        headers: {'referer': Constants.apiReferer});
    log(response.body);

    if (response.statusCode == 200) {

      var data = jsonDecode(response.body);
      if (data['status']) {
        print('true');
        data = data['data'] as List;
        List<ProductWidget> products = [];
        for (int i = 0; i < data.length; i++) {
          products.add(ProductWidget(
            id: data[i]['id'].toString(),
            nameEn: data[i]['name_en'],
            nameAr: data[i]['name_ar'],
            imagePath: data[i]['image'],
            price: data[i]['price'].toString(),
            salesPrice: data[i]['sales_price'].toString().toLowerCase(),
          ));
        }
        return products;
      }
      return <ProductWidget>[];


    }
    return Constants.requestErrorMessage;
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
