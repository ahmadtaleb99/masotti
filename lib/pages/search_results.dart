import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import '../assets/my_flutter_app_icons.dart';
import 'dart:convert';
import './product.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/product.dart';

class SearchResultsPage extends StatefulWidget {
  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  String? searchText;
  late StreamController _searchStream;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchStream = StreamController();
    _searchStream.add(0);
  }

  @override
  Widget build(BuildContext context) {
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    double spacing = containerWidth / 25;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: AppBar(
          backgroundColor: Constants.identityColor,
          toolbarHeight: 80,
          leading: Builder(
            builder: (context) {
              return Container(
                  width: 100,
                  // margin: EdgeInsets.only(top: 18),
                  child: IconButton(
                    icon: Image.asset('assets/images/Component 1 – 49.png'),
                    color: Constants.whiteColor,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ));
            },
          ),
          elevation: 0,
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(Constants.borderRadius * 3)),
            child: Center(
              child: TextField(
                controller: controller,
                autofocus: true,
                onSubmitted: (value) {
                  setState(() {
                    searchText = value;
                    getProducts(searchText);
                  });
                },
                decoration: InputDecoration(
                    suffixIcon: Card(
                      margin: EdgeInsets.zero,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Constants.borderColor!),
                          borderRadius: !arabicLanguage
                              ? BorderRadius.only(
                                  topRight: Radius.circular(
                                      Constants.borderRadius * 3),
                                  bottomRight: Radius.circular(
                                      Constants.borderRadius * 3))
                              : BorderRadius.only(
                                  topLeft: Radius.circular(
                                      Constants.borderRadius * 3),
                                  bottomLeft: Radius.circular(
                                      Constants.borderRadius * 3))),
                      child: IconButton(
                        icon: Icon(MyFlutterApp.group_526),
                        color: Constants.identityColor,
                        onPressed: () {
                          setState(() {
                            searchText = controller.text;
                          });
                        },
                      ),
                    ),
                    hintText: 'Search...'.tr(),
                    hintStyle: TextStyle(
                        fontSize: Constants.fontSize - 4,
                        color: Constants.greyColor),
                    contentPadding:
                        EdgeInsets.only(top: 8, left: 20, right: 20),
                    border: InputBorder.none),
              ),
            ),
          )),
      drawer: SideMenu(),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(Constants.borderRadius * 2),
            topLeft: Radius.circular(Constants.borderRadius * 2)),
        child: Container(
          color: Constants.whiteColor,
          height: double.infinity,
          padding: EdgeInsets.all(Constants.padding),
          child: StreamBuilder(
            stream: _searchStream.stream,
            builder: (context, snap) {
              if (!snap.hasData) {
                return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: ColoredCircularProgressIndicator(),
                    ));
              }
              var response = snap.data;
              print(response.toString());
              if (response is String) {
                return RequestEmptyData(
                  message: response,
                );
              }
              if (response is int) {
                return Container();
              }
              List<ProductWidget> products = response as List<ProductWidget>;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Wrap(
                      spacing: spacing -
                          (MediaQuery.of(context).devicePixelRatio > 1.2
                              ? 4
                              : 0),
                      children: List.generate(products.length, (index) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductPage(
                                        id: products[index].id,
                                      ))),
                          child: Container(
                            margin: EdgeInsets.only(bottom: Constants.padding),
                            child: products[index],
                          ),
                        );
                      }),
                    )),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future getProducts(String? searchText) async {
    print(searchText);
    if (searchText != null) {
      if (searchText.trim() != '') {
        _searchStream.add(null);
        AsyncMemoizer memoizer = AsyncMemoizer();
        return memoizer.runOnce(() async {
          final String url = 'search-products?search_text=$searchText';
          final response = await http.get(Uri.parse(Constants.apiUrl + url),
              headers: {'referer': Constants.apiReferer});

          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status']) {
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
              _searchStream.add(products);
              return products;
            }
            _searchStream.add(data['message'].toString());
            return data['message'].toString();
          }
          _searchStream.add(Constants.requestErrorMessage);
          return Constants.requestErrorMessage;
        });
      } else {
        _searchStream.add(0);
        return 0;
      }
    } else {
      _searchStream.add(0);
      return 0;
    }
  }
}
