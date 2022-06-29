import 'package:get/get.dart';

class Product extends GetxController {
  late String name;
  late double price;
  late int quantity;
  late String imgPath;

  Product(
      {required this.name,
      required this.price,
      required this.quantity,
      required this.imgPath});

  static final product1 = Product(
      name: 'tomates',
      price: 2.5,
      quantity: 2,
      imgPath: 'assets/images/tomato.jpg');
  static final product2 = Product(
      name: 'patates',
      price: 1.5,
      quantity: 2,
      imgPath: 'assets/images/potatoes.jpg');
  static final product3 = Product(
      name: 'makaronia',
      price: 0.6,
      quantity: 2,
      imgPath: 'assets/images/makaronia.jpg');
  static final product4 = Product(
      name: 'kafe',
      price: 4.5,
      quantity: 2,
      imgPath: 'assets/images/coffee.jpg');
}
