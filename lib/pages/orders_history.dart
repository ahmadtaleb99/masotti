import 'package:flutter/material.dart';
import '../widgets/colored_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './order_details.dart';
import '../widgets/order_history_item.dart';
import '../constants.dart';
import '../side_menu.dart';
import '../widgets/custom_appbar_2.dart';
import '../widgets/request_empty_data.dart';
import 'home_page.dart';

// was stateless
class OrdersHistoryPage extends StatefulWidget {
  @override
  _OrdersHistoryPageState createState() => _OrdersHistoryPageState();
}

class _OrdersHistoryPageState extends State<OrdersHistoryPage> {
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
    double containerWidth =
        MediaQuery.of(context).size.width - (Constants.doublePadding);
    return Scaffold(
      backgroundColor: Constants.identityColor,
      appBar: CustomAppBarWidget(
        title: 'Orders History',
        currentContext: context,
        itemsInCart: itemsInCart,
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
                  future: getOrders(),
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
                    List<OrderHistoryItemWidget> orders =
                        response as List<OrderHistoryItemWidget>;
                    return Container(
                        width: containerWidth,
                        child: Column(
                          children: List.generate(orders.length, (index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: Constants.padding),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OrderDetailsPage(
                                                orderId: orders[index].orderId,
                                              ))).then(
                                      (value) => setState(() {}));
                                },
                                child: orders[index],
                              ),
                            );
                          }),
                        ));
                  }),
            ),
          ),
        ),
      ),
    );
  }

  Future getOrders() async {
    final String url = 'get-orders-history';
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
          print('orders: ' + data.toString());
          List<OrderHistoryItemWidget> orders = [];
          for (int i = 0; i < data.length; i++) {
            orders.add(OrderHistoryItemWidget(
              orderId: data[i]['id'].toString(),
              address: data[i]['address'],
              createdDate: data[i]['date'],
              status: data[i]['status'],
              price: data[i]['total_price'].toString(),
            ));
          }
          return orders;
        }
        return data['message'].toString();
      }
      return Constants.requestErrorMessage;
    }
  }
}
