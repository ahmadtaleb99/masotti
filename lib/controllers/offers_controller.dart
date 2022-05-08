import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import '../widgets/offer.dart';
import 'dart:convert';
import '../constants.dart';

class OffersController{

  static Future getOffers(String orderBy) async {
    final String url = 'get-all-offers?order_by=' + orderBy;
    final response = await http.get(Uri.parse(Constants.apiUrl + url), headers: {
      'referer': Constants.apiReferer
    });

    List<OfferWidget> offers;
    if(response.statusCode == 200){
      var data = jsonDecode(response.body);
      if(data['status']){
        data = data['data'] as List;
        offers =  <OfferWidget>[];
        for(int i = 0; i < data.length; i++){
          offers.add(OfferWidget(
            id: data[i]['id'].toString(),
            nameEn: data[i]['name_en'],
            nameAr: data[i]['name_ar'],
            detailsEn: data[i]['details_en'],
            detailsAr: data[i]['details_ar'],
            oldPrice: data[i]['old_price'].toString(),
            newPrice: data[i]['new_price'].toString(),
            imagePath: data[i]['image'],
            timer: data[i]['timer'],
          ));
        }
        return offers;
      }
      return data['message'].toString();
    }
    return Constants.requestErrorMessage;
  }

  static Future getOffer(String offerId) async {
    AsyncMemoizer memoizer = AsyncMemoizer();
    return memoizer.runOnce(() async {
      final String url = 'get-offer?offer_id=' + offerId;
      final response = await http.get(Constants.apiUrl + url as Uri, headers: {
        'referer': Constants.apiReferer
      });

      if(response.statusCode == 200){
        var data = jsonDecode(response.body);
        if(data['status']){
          data = data['data'];
          var offer = data['offer'];
          return OfferWidget(
            id: offer['id'].toString(),
            nameEn: offer['name_en'],
            nameAr: offer['name_ar'],
            detailsEn: offer['details_en'],
            detailsAr: offer['details_ar'],
            oldPrice: offer['products_prices_before_offer'].toString(),
            newPrice: offer['products_prices_after_offer'].toString(),
            imagePath: offer['offer_image'],
            timer: data['timer'],
            hasBeenExpired: data['has_been_expired'].toString().toLowerCase() == 'true',
            products: data['products'],
          );
        }
        return data['message'].toString();
      }
      return Constants.requestErrorMessage;
    });
  }
  
}
