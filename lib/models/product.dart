import 'package:flutter/material.dart';

class Product{
  String id;
  String? nameEn;
  String? nameAr;
  List? images;
  String? price;
  String salesPrice;
  String? detailsEn;
  String? detailsAr;
  Map? variants;
  List? dropDownVariants;
  List? relatedProducts;

  Product({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.images,
    required this.price,
    required this.salesPrice,
    required this.detailsEn,
    required this.detailsAr,
    required this.variants,
    required this.dropDownVariants,
    this.relatedProducts
  });

  static Product getProductFromData(data, variantsChoices){
    return Product(
      id: data['id'].toString(),
      nameEn: data['name_en'],
      nameAr: data['name_ar'],
      detailsEn: data['details_en'],
      detailsAr: data['details_ar'],
      price: data['price'],
      salesPrice: data['sales_price'].toString().toLowerCase(),
      variants: data['variants'],
      dropDownVariants: variantsChoices,
      images: data['images'],
      relatedProducts: data['related_products']
    );
  }
}