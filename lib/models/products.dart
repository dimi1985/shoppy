class Product {
  int id;
  late String name;
  late double price;
  late int quantity;
  late double totalPrice;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });
  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        quantity: json["quantity"],
        totalPrice: json["totalPrice"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "price": price,
        "quantity": quantity,
        "totalPrice": totalPrice,
      };
}
