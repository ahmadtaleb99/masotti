class Setting{

  int? language;
  int? offerNotifications;
  int? categoryNotifications;
  int? couponNotifications;
  
  Setting();

  Map<String, dynamic> toJson() {
    return {
      'language': this.language.toString(),
      'add_offer_notifications': this.offerNotifications.toString(),
      'add_category_notifications': this.categoryNotifications.toString(),
      'receive_coupon_notifications': this.couponNotifications.toString(),
    };
  }
}