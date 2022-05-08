import 'package:flutter/material.dart';

class Customer{
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  String? oldPassword;
  String? mobilePhone;
  String? birthDate;
  String? gender;
  String? resetPasswordCode;

  Customer();

  Customer.fromValues({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.mobilePhone,
    required this.birthDate,
    required this.gender,
    this.oldPassword,
    this.resetPasswordCode
  });

  static Customer getCustomerFromData(data){
    return Customer.fromValues(
      firstName: data['first_name'],
      lastName: data['last_name'],
      email: data['email'],
      mobilePhone: data['phone'],
      birthDate: data['birth_date'],
      gender: data['gender'],
      password: '',
      confirmPassword: ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': this.firstName.toString(),
      'last_name': this.lastName.toString(),
      'email': this.email.toString(),
      'password': this.password.toString(),
      'phone': this.mobilePhone.toString(),
      'birth_date': this.birthDate.toString(),
      'gender': this.gender.toString(),
      'old_password': this.oldPassword.toString(),
      'reset_password_code': this.resetPasswordCode.toString()
    };
  }

  @override
  String toString() {
    return 'First Name: ' + this.firstName.toString() + 
      ', Last Name: ' + this.lastName.toString() + 
      ', Email: ' + this.email.toString() + 
      ', Mobile Phone: ' + this.mobilePhone.toString() +
      ', Birth Date: ' + this.birthDate.toString() +
      ', Gender: ' + this.gender.toString() +
      ', Password: ' + this.password.toString() + 
      ', Confirm Password: ' + this.confirmPassword!.toLowerCase() + 
      ', Old Password: ' + this.oldPassword.toString() + 
      ', Reset Paassword Code: ' + this.resetPasswordCode.toString();
  }
}