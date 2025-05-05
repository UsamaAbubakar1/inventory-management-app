// class SaleModel {
//   final String productId;
//   final int quantity;
//   final double total;

//   SaleModel({
//     required this.productId,
//     required this.quantity,
//     required this.total,
//   });

//   factory SaleModel.fromJson(Map<String, dynamic> json) {
//     return SaleModel(
//       productId: json['product_id'],
//       quantity: json['quantity'],
//       total: json['total'].toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'product_id': productId,
//         'quantity': quantity,
//         'total': total,
//       };
// }

class SaleModel {
  final String id;
  final DateTime date;
  final double totalAmount;
  final List<Map<String, dynamic>> items;

  SaleModel({
    required this.id,
    required this.date,
    required this.totalAmount,
    required this.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      totalAmount: json['totalAmount'].toDouble(),
      items: List<Map<String, dynamic>>.from(json['items']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'items': items,
    };
  }
}
