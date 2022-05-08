import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:async/async.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/request_empty_data.dart';
import 'dart:convert';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import 'home_page.dart';

// was stateless
class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
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
        title: 'Privacy Policy',
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
                child: FutureBuilder(
              future: getPrivacyPolicy(),
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
                    children: <Widget>[
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
                        margin: EdgeInsets.symmetric(
                            vertical: Constants.doublePadding),
                        width: containerWidth / 2,
                        height: containerWidth / 6 * 4,
                        child: SvgPicture.asset(
                          Constants.privacyPolicyImage,
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

  getPrivacyPolicy() async {
    AsyncMemoizer memoizer = AsyncMemoizer();
    return memoizer.runOnce(() async {
      final String url = 'get-privacy-policy-message';
      final response = await http.get(Uri.parse(Constants.apiUrl + url),
          headers: {'referer': Constants.apiReferer});

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          return data['data'];
        }
      }
      return Constants.requestErrorMessage;
    });
  }
}
