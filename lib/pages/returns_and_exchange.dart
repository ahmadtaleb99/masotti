import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../assets/my_flutter_app_icons.dart';
import 'dart:convert';
import '../widgets/request_empty_data.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import 'home_page.dart';

// was stateless
class ReturnsAndExchangePage extends StatefulWidget {
  @override
  _ReturnsAndExchangePageState createState() => _ReturnsAndExchangePageState();
}

class _ReturnsAndExchangePageState extends State<ReturnsAndExchangePage> {
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
        MediaQuery.of(context).size.width - (Constants.padding * 4);
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Returns & Exchange',
        currentContext: context,
        itemsInCart: itemsInCart,
        showBackButton: arabicLanguage ?   true : null ,

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
                child: FutureBuilder(
              future: getReturnsAndExchange(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: ColoredCircularProgressIndicator(),
                      ));
                }
                dynamic response = snap.data;
                if (response is String) {
                  return RequestEmptyData(
                    message: response,
                  );
                }
                return Container(
                  margin: EdgeInsets.all(Constants.doublePadding),
                  width: containerWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: containerWidth,
                        child: AutoSizeText(
                          arabicLanguage
                              ? response['message_ar']
                              : response['message_en'],
                          style: TextStyle(
                              fontSize: Constants.fontSize, height: 1.5),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: Constants.doublePadding,
                          bottom: Constants.doublePadding,
                        ),
                        child: Icon(
                          MyFlutterApp.returns___exchange_2_2,
                          color: Constants.redColor,
                          size: 130,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )),
          ),
        ),
      ),
    );
  }

  getReturnsAndExchange() async {
    AsyncMemoizer memoizer = AsyncMemoizer();
    return memoizer.runOnce(() async {
      final String url = 'get-return-and-exchange-message';
      final response = await http.get(Uri.parse(Constants.apiUrl + url),
          headers: {'referer': Constants.apiReferer});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          return data = data['data'];
        }
      }
      return Constants.requestErrorMessage;
    });
  }
}
