import 'package:flutter/material.dart';

class LatestCategory {
  String? id;
  String? nameEn;
  String? nameAr;
  bool? hasSubCategories;

  LatestCategory();

  LatestCategory.fromValues({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.hasSubCategories,
  });
}