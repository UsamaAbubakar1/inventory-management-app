class ProductModel {
  final String id;
  final String name;
  final int stockQuantity;
  final double costPrice;
  final double sellPrice;

  ProductModel({
    required this.id,
    required this.name,
    required this.stockQuantity,
    required this.costPrice,
    required this.sellPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      stockQuantity: json['stock_quantity'],
      costPrice: json['cost_price'].toDouble(),
      sellPrice: json['sell_price'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stock_quantity': stockQuantity,
        'cost_price': costPrice,
        'sell_price': sellPrice,
      };
}
