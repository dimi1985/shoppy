import 'package:get/get.dart';

class Product extends GetxController {
  late String name;
  late double price;
  late int quantity;

  Product({
    required this.name,
    required this.price,
    required this.quantity,
  });

  static final product1 = Product(
    name: 'tomates',
    price: 2.5,
    quantity: 2,
  );
  static final product2 = Product(
    name: 'patates',
    price: 1.5,
    quantity: 2,
  );
  static final product3 = Product(
    name: 'makaronia',
    price: 0.6,
    quantity: 2,
  );
  static final product4 = Product(
    name: 'kafe',
    price: 4.5,
    quantity: 2,
  );
}
