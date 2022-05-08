import 'package:flutter/material.dart';
import './featured_product.dart';
import './featured_category.dart';

class HomePageData {
  List<String>? sliderImages;
  List<String>? sliderProducts;
  bool? displayAboutBtn;
  bool? availableOffers;
  List<LatestCategory>? latestCategories;
  List<LatestProduct>? latestProducts;

  HomePageData();

  HomePageData.fromValues({
    required this.sliderImages,
    required this.sliderProducts,
    required this.displayAboutBtn,
    required this.availableOffers,
    required this.latestCategories,
    required this.latestProducts,
  });
}