import 'package:flutter/material.dart';

class Constants{
  static final String apiUrl                  = 'http://flexsolutions.biz/apps/masotti/api-v2/';
  static final String apiFilesUrl             = 'http://flexsolutions.biz/apps/masotti/';

  // static final String apiUrl                  = 'http://flexsolutions.technology/masotti/api/';
  // static final String apiFilesUrl             = 'http://flexsolutions.technology/masotti/';

  // static final String apiUrl                  = 'http://192.168.0.190/masotti/api/';
  // static final String apiFilesUrl             = 'http://192.168.0.190/masotti/';
  static final String apiReferer              = 'http://flexsolution.biz';
  static final String requestErrorMessage     = 'Error ocurred while getting data';
  static final String requestNoDataMessage    = 'No results found';

  static final Color? borderColor              = Colors.grey[200];
  static final Color whiteColor               = Colors.white;
  static final Color identityColor            = Color(0xFF414141); 
  static final Color linkColor                = Colors.blueAccent;
  static final Color redColor                 = Color(0xFFEE1D23);
  static final Color greyColor                = Color(0xFF707070);
  static final Color greenColor               = Color(0xFF1AB534);


  static final String logoImage               = 'assets/images/logo.png';
  static final String flexSolutionsLogoImage  = 'assets/images/flex-logo.png';
  static final String privacyPolicyImage      = 'assets/images/privacy_policy.svg';
  static final String sideMenuImage           = 'assets/images/side_menu_icon.svg';
  static final String sideMenuImage2           = 'assets/images/side_menu_icon_2.svg';
  static final String defaultCategoryImage    = 'assets/images/default-category.jpg';
  static final String defaultSubCategoryImage = 'assets/images/default-sub-category.jpg';
  
  static final double padding                 = 20;
  static final double halfPadding             = 10;
  static final double doublePadding           = 40;
  static final double fontSize                = 20;
  static final double fontSizeOnSmallScreens  = 16;
  static final double borderRadius            = 12;
  static final double buttonsVerticalPadding  = 15;

  static final String keyActiveSideMenuItem           = 'keyActiveSideMenuItem';
  static final String keyUnreadNotifications          = 'keyUnreadNotifications';
  static final String keyAccountStatus                = 'keyAccountStatus';
  static final String keyAccessToken                  = 'keyAccessToken';
  static final String keyCustomerSettings             = 'keyCustomerSettings';
  static final String keyProductsIDsInCart            = 'keyProductsIDsInCart';
  static final String keyProductsQuantitiesInCart     = 'keyProductsQuantitiesInCart';
  static final String keyProductsVariantsInCart       = 'keyProductsVariantsInCart';
  static final String keyOffersIDsInCart              = 'keyOffersIDsInCart';
  static final String keyOffersQuantitiesInCart       = 'keyOffersQuantitiesInCart';
  static final String keyOffersProductsIDs            = 'keyOffersProductsIDs';
  static final String keyOffersProductsVariants       = 'keyOffersProductsVariants';
  static final String keyOrderIDToUpdate              = 'keyOrderIDToUpdate';
  static final String keyNumberOfItemsInCart          = 'keyNumberOfItemsInCart';
  static final String keyFirstRunOfApp                = 'keyFirstRunOfApp';
  static final String keyRegisteringMinutiesTime      = 'keyRegisteringMinutiesTime';
  static final String keyNotVerifiedAccount           = 'keyNotVerifiedAccount';
  static final String keyNotVerifiedAccountMobile     = 'keyNotVerifiedAccountMobile';
  static final String keyGeneralNotifications         = 'keyGeneralNotifications';

  static final Color orderStatusPendingColor                   = Color(0xFF0E117D);
  static final Color orderStatusInProgressColor                = Color(0xFFE5B700);
  static final Color orderStatusWaitingForCustomerActionColor  = Color(0xFF242424);
  static final Color orderStatusCanceledColor                  = Color(0xFFEE1D23);
  static final Color orderStatusDeliveringColor                = Color(0xFF00B300);
  static final Color orderStatusDeliveredColor                 = Color(0xFF00B300);
  static final Color orderStatusNotDeliveredColor              = Color(0xFFD60CBC);


  static  String day(int seconds) { 
    int days = (seconds / 86400).truncate();
    String daysStr = (days).toString().padLeft(2, '0'); 
    return "$daysStr";
  }

  static String hours(int seconds) {
    int hours = (seconds / 3600).truncate();
    String hoursStr = (hours%24).toString().padLeft(2, '0');
    return "$hoursStr";
  }

  static String minutes(int seconds) {
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes%60).toString().padLeft(2, '0');
    return "$minutesStr";
  }

  static String seconds(int seconds) {
    seconds = (seconds % 3600).truncate();
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return "$secondsStr";
  }

}