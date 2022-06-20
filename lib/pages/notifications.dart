import 'package:flutter/material.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import '../widgets/notification.dart';
import '../widgets/alert_dialog.dart';
import 'home_page.dart';

// was stateless
class NotificationsPage extends StatefulWidget {

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int? itemsInCart = 0;

  @override
  void initState() {
    super.initState();
    getItemsInCartCount();
  }

  getItemsInCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      itemsInCart = prefs.getInt(Constants.keyNumberOfItemsInCart);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool arabicLanguage =
        Localizations.localeOf(context).languageCode == 'ar' ? true : false;
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'My Notifications',
        currentContext: context,
        itemsInCart: itemsInCart,
        showBackButton: arabicLanguage ? true : null,
        cartIconExist: true,
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
                    List<NotificationWidget> notifications =
                        response as List<NotificationWidget>;
                    return Container(
                      child: Column(
                        children: List.generate(notifications.length, (index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: Constants.padding),
                            child: GestureDetector(
                              onTap: () => showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomAlertDialog(
                                      title: arabicLanguage
                                          ? notifications[index].titleAr
                                          : notifications[index].titleEn,
                                      content: arabicLanguage
                                          ? notifications[index].contentAr
                                          : notifications[index].contentEn,
                                      btnLabel: 'Ok',
                                      btnOnPressed: () => Navigator.pop(context),
                                    );
                                  }),
                              child: notifications[index],
                            ),
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
    String url = 'get-customer-notifications';
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(Constants.keyAccessToken);

    if (accessToken != null) {
      final response = await http.get(Uri.parse(Constants.apiUrl + url), headers: {
        'Authorization': 'Bearer ' + accessToken,
        'referer': Constants.apiReferer
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          data = data['data'];
          List<NotificationWidget> notifications =[];
          for (int i = 0; i < data.length; i++) {
            notifications.add(NotificationWidget(
              id: data[i]['id'].toString(),
              titleEn: data[i]['title_en'],
              titleAr: data[i]['title_ar'],
              contentEn: data[i]['body_en'],
              contentAr: data[i]['body_ar'],
              hasBeenRead: data[i]['has_been_read'] == 0 ? false : true,
            ));
          }

          String url = 'mark-notifications-as-read';
          await http.post(Uri.parse(Constants.apiUrl + url), headers: {
            'Authorization': 'Bearer ' + accessToken,
            'referer': Constants.apiReferer
          });
          prefs.setBool(Constants.keyUnreadNotifications, false);
          return notifications;
        }
        return data['message'].toString();
      }
      return Constants.requestErrorMessage;
    }
  }
}
