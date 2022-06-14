import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:http/http.dart' as http;
import 'package:masotti/services/networking/network_helper.dart';
import 'package:masotti/widgets/custom_red_button.dart';
import 'package:masotti/widgets/request_empty_data.dart';
import './models/pushNotificationModel.dart';
import './pages/product.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import './pages/splash_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import './pages/offer.dart';
import './pages/notifications.dart';
import './pages/order_details.dart';
import './pages/categories.dart';
import './pages/home_page.dart';
import './pages/login.dart';
import './pages/intro_page.dart';
import './pages/first_run.dart';
import './constants.dart';
import 'package:flutter/scheduler.dart' as Scheduler;
import 'package:uni_links/uni_links.dart' as UniLinks;
import 'widgets/colored_circular_progress_indicator.dart';

Uri? initialDeepLinkUri = Uri();

bool _initialUriIsHandled = false;
StreamSubscription<String?> ? _incomingUriStream ;

Future backgroundMessageHandler(RemoteMessage message) async {
  print("onBackgroundMessage: $message");
  PushNotification notification = PushNotification.fromJson(message.data);
  MyAppState().showNotification(
      notification.title, notification.body, notification.imageUrl);
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EasyLocalization.ensureInitialized();
 await Firebase.initializeApp(

 );
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
      (_) => runApp(EasyLocalization(
          supportedLocales: [Locale('ar', 'DZ'), Locale('en', 'US')],
          path: 'assets/languages',
          fallbackLocale: Locale('en', 'US'),
          child: MyApp())));
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {

  Future checkTokenAndUnReadNotifications() async {
    try {
      final uri = await UniLinks.getInitialUri();
        log('inital uri : : : ::'+uri.toString());
      if (uri != null) {
        return _handleInitialUri(uri);
      }
      _initialUriIsHandled = true;

      final String url = 'check-token-and-un-read-notifications';
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.containsKey(Constants.keyAccessToken)
          ? prefs.getString(Constants.keyAccessToken)
          : null;

      if (token != null) {
        final data = await NetworkingHelper.postData(url, body: {'token': token}, headers: {'referer': Constants.apiReferer}, );

          if (data['status'] && data['data']) {
            prefs.setBool(
                Constants.keyUnreadNotifications,
                data['un_read_notifications']);
            return SplashScreen();
          }
          prefs.clear();
      }
      return LoginPage();
    }
    catch (e) {
      return Constants.requestErrorMessage;
    }
  }



  Future<Widget?> _handleInitialUri(Uri uri) async {
    _initialUriIsHandled = true;

      try {
        initialDeepLinkUri = uri;

        log('got initial uri');
        String id = _getProductIdFromUri(uri);
         return ProductPage(id: id);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('failed to get initial uri');
      } on FormatException catch (err) {
        print('malformed initial uri');
        // _err = err;
      }
  }

  String _getProductIdFromUri(Uri uri){
    List<String> splitted = uri.toString().split('=');
    return splitted.last;
  }
  void goToProductFromUri(Uri uri){
    Scheduler.SchedulerBinding.instance!.addPostFrameCallback((_) async {
      var id  = _getProductIdFromUri(uri);

      navigatorKey.currentState!.push(MaterialPageRoute(
          builder: (context) =>
              ProductPage(id:id)));

    });

  }
  void _handleIncomingUri (){

      _incomingUriStream = UniLinks.linkStream.listen((uri) {
        log('uri:::: '+uri.toString());
        if(_initialUriIsHandled)
          goToProductFromUri(Uri.parse(uri!));

        });

  }
  final FirebaseMessaging fireBaseMessaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  bool redirectToChooseLanguagePage = false;

  Route<dynamic> getRoute(RouteSettings settings) {
    String? route = settings.name;
    if (route == 'offers') {
      return MaterialPageRoute(
          builder: (context) => OfferPage(
                id: settings.arguments.toString(),
              ));
    } else if (route == 'orders') {
      return MaterialPageRoute(
          builder: (context) => OrderDetailsPage(
                orderId: settings.arguments.toString(),
              ));
    } else if (route == 'coupons') {
      return MaterialPageRoute(builder: (context) => NotificationsPage());
    } else if (route == 'categories') {
      return MaterialPageRoute(builder: (context) => CategoriesPage());
    }
    return MaterialPageRoute(builder: (context) => HomePage());
  }

  Future<bool> checkIfFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
   return redirectToChooseLanguagePage =
        prefs.containsKey(Constants.keyFirstRunOfApp) ? false : true;
  }

  saveNotificationToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(Constants.keyUnreadNotifications, true);
  }

  subscribeToGeneralNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(Constants.keyGeneralNotifications)) {
      fireBaseMessaging.subscribeToTopic('general_notifications');
      prefs.setBool(Constants.keyGeneralNotifications, true);
    }
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _incomingUriStream!.cancel();
  }
  Future _initNotificationsConfigsIOS() async{

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );

      fireBaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true );
  }
  @override
  void initState() {

    super.initState();
    checkIfFirstRun();
    subscribeToGeneralNotifications();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var macOS = new MacOSInitializationSettings();
    var initSettings =
        new InitializationSettings(android: android, iOS: iOS, macOS: macOS);
    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);


           if(Platform.isIOS) _initNotificationsConfigsIOS();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      saveNotificationToLocalStorage();
      PushNotification notification = PushNotification.fromJson(message.data);
      showNotification(
          notification.title, notification.body, notification.imageUrl);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onResume: $message");
      saveNotificationToLocalStorage();
      PushNotification notification = PushNotification.fromJson(message.data);
      showNotification(
          notification.title, notification.body, notification.imageUrl);
    });





    _handleIncomingUri();

///usr/bin/xcrun simctl openurl booted "https://flexsolutions.biz/apps/masotti/products/view?id=1400"
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkTokenAndUnReadNotifications(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Container(
              color: Constants.whiteColor,
              child: Center(
                child: ColoredCircularProgressIndicator(),
              ),
            ),
          );
        }
        var response = snap.data;
        Widget? startingWidget;
        if (response is String) {
          startingWidget=  Scaffold(
             body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: Constants.padding),
                        child: RequestEmptyData(
                          message: response,
                        )),
                    CustomRedButton(text: 'Retry', onPressed: (){

                      setState(() {
                        checkTokenAndUnReadNotifications();
                      });
                    ;}
                    )]
             ),
           );
        }


     else   startingWidget =
            redirectToChooseLanguagePage ? FirstRunPage(productId: initialDeepLinkUri != null ? _getProductIdFromUri(initialDeepLinkUri!) : null,) : snap.data as Widget;
        return OverlaySupport(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: getRoute,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              fontFamily: 'Tajawal',
            ),
            home: startingWidget,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routes: <String, WidgetBuilder>{
              '/Home': (BuildContext context) => HomePage()
            },
          ),
        );
      },
    );
  }
   Future<bool> _isAuthentecated () async {
    final prefs = await SharedPreferences.getInstance();
   return prefs.containsKey(Constants.keyAccessToken);
  }



  Future _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  showNotification(String? title, String? content, String? imageUrl) async {
    if (imageUrl != null) {
      final String bigPicturePath =
          await (_downloadAndSaveFile(imageUrl, 'bigPicture') as FutureOr<String>);
      final BigPictureStyleInformation bigPictureStyleInformation =
          BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
              hideExpandedLargeIcon: true,
              largeIcon: FilePathAndroidBitmap(bigPicturePath),
              contentTitle: title,
              htmlFormatContentTitle: true,
              summaryText: content,
              htmlFormatSummaryText: true);

      final android = AndroidNotificationDetails(
          'channel id', 'channel NAME', channelDescription: 'CHANNEL DESCRIPTION',
          styleInformation: bigPictureStyleInformation,
          icon: '@mipmap/ic_launcher',
          largeIcon: FilePathAndroidBitmap(bigPicturePath),
          priority: Priority.high,
          importance: Importance.max);

      final iOS = IOSNotificationDetails(
          attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment(bigPicturePath)
          ]);

      final MacOSNotificationDetails macOS = MacOSNotificationDetails(
          attachments: <MacOSNotificationAttachment>[
            MacOSNotificationAttachment(bigPicturePath)
          ]);

      var platform =
          new NotificationDetails(android: android, iOS: iOS, macOS: macOS);
      await flutterLocalNotificationsPlugin.show(0, title, content, platform);
    } else {
      final android = AndroidNotificationDetails(
          'channel id', 'channel NAME',
          icon: '@mipmap/ic_launcher',channelDescription:'CHANNEL DESCRIPTION' ,
          priority: Priority.high,
          importance: Importance.max);

      final iOS = IOSNotificationDetails();

      final MacOSNotificationDetails macOS = MacOSNotificationDetails();

      var platform =
          new NotificationDetails(android: android, iOS: iOS, macOS: macOS);
      await flutterLocalNotificationsPlugin.show(0, title, content, platform);
    }
  }

  void onSelectNotification(String? payload) {
    print("payload : $payload");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NotificationsPage()));
  }
}
