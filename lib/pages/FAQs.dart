import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/FAQ.dart';
import 'home_page.dart';

class FAQsPage extends StatefulWidget {

  @override
  _FAQsPageState createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {

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
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'FAQs',
        currentContext: context,
        showBackButton: true,

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
                  future: getNotifications(),
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
                    List<FAQWidget> faqs = response as List<FAQWidget>;
                    return Container(
                      child: Column(
                        children: List.generate(faqs.length, (index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: Constants.halfPadding),
                            child: faqs[index],
                          );
                        }),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  getNotifications() async {
    String url = 'get-faqs';
    // final prefs = await SharedPreferences.getInstance();
    // String accessToken = prefs.getString(Constants.keyAccessToken);

    // if (accessToken != null) {
      final response = await http.get(Uri.parse(Constants.apiUrl + url) , headers: {
        // 'Authorization': 'Bearer ' + accessToken,
        'referer': Constants.apiReferer
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'];
          List<FAQWidget> faqs = [];
          for (int i = 0; i < data.length; i++) {
            faqs.add(FAQWidget(
              id: data[i]['id'].toString(),
              questionEn: data[i]['question_en'],
              questionAr: data[i]['question_ar'],
              answerEn: data[i]['answer_en'],
              answerAr: data[i]['answer_ar'],
              checked: false,
            ));
          }

          return faqs;
        }
        return data['message'].toString();
      // }
      return Constants.requestErrorMessage;
    }
  }
}
