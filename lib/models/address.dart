import 'package:flutter/material.dart';
import './city.dart';

class Address{
  String? name;
  City? city;
  String? district;
  String? street;
  String? building;
  String? home;
  String? floor;
  String? details;

  Address();

  Address.fromValues({
    required this.name,
    required this.city,
    required this.district,
    required this.street,
    required this.building,
    required this.home,
    required this.floor,
    required this.details,
  });

  static Address getAddressFromData(data, city){
    return Address.fromValues(
      name: data['name'],
      city: city,
      district: data['district'],
      street: data['street'],
      floor: data['floor'],
      home: data['home'],
      building: data['building'],
      details: data['more_details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'city_id': this.city!.id.toString(),
      'district': this.district,
      'street': this.street,
      'building': this.building,
      'home': this.home,
      'floor': this.floor,
      'details': this.details
    };
  }

  @override
  String toString() {
    return 'Name: ' + this.name! + ', District: ' + this.district! + ', Street: ' + this.street! + ', City: ' + city!.name!;
  }
}