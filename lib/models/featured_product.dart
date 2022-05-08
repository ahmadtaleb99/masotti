import 'package:flutter/material.dart';

class LatestProduct{
  String? id;
  String? nameEn;
  String? nameAr;
  String? categoryId;
  String imagePath;
  double? price;
  String? salesPrice;


  LatestProduct.fromValues({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categoryId,
    required this.imagePath,
    required this.price,
    required this.salesPrice
  });
}