import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_pos/service/product_model/product_model.dart';
import 'package:my_pos/service/product_model/sale_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------- AUTH --------------------

  static Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async => await _auth.signOut();

  static User? getCurrentUser() => _auth.currentUser;

  // -------------------- PRODUCTS --------------------

  static Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toJson());
  }

  static Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toJson());
  }

  static Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  static Stream<List<ProductModel>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromJson(doc.data())).toList());
  }

  // -------------------- SALES --------------------

  static Future<void> recordSale(SaleModel sale) async {
    await _firestore.collection('sales').doc(sale.id).set(sale.toMap());
  }

  // static Future<void> deductStock(String productId, int quantity) async {
  //   final doc =
  //       FirebaseFirestore.instance.collection('products').doc(productId);
  //   await FirebaseFirestore.instance.runTransaction((transaction) async {
  //     final snapshot = await transaction.get(doc);
  //     final currentStock = snapshot['stockQuantity'] ?? 0;

  //     if (currentStock >= quantity) {
  //       transaction.update(doc, {'stockQuantity': currentStock - quantity});
  //     } else {
  //       throw Exception('Not enough stock for ${snapshot['name']}');
  //     }
  //   });
  // }

  static Future<void> deductStock(String productId, int quantity) async {
    final docRef =
        _firestore.collection('products').doc(productId); // Use _firestore

    await _firestore.runTransaction((transaction) async {
      // Use _firestore
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception("Product with ID $productId not found.");
      }

      final currentStock = snapshot.data()?['stock_quantity'] as int? ?? 0;

      if (currentStock >= quantity) {
        final newStock = currentStock - quantity;
        transaction.update(docRef, {'stock_quantity': newStock});
      } else {
        final productName = snapshot.data()?['name'] ?? 'Product $productId';
        throw Exception(
            'Not enough stock for $productName. Available: $currentStock, Requested: $quantity');
      }
    });
  }

  static Stream<List<SaleModel>> getSales() {
    return FirebaseFirestore.instance
        .collection('sales')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return SaleModel(
                id: data['id'],
                date: DateTime.parse(data['date']),
                totalAmount: data['totalAmount'],
                items: List<Map<String, dynamic>>.from(data['items']),
              );
            }).toList());
  }

  // -------------------- PROFIT --------------------

  static Future<double> calculateProfit() async {
    double totalProfit = 0.0;

    final salesSnapshot = await _firestore.collection('sales').get();

    for (var saleDoc in salesSnapshot.docs) {
      final sale = SaleModel.fromJson(saleDoc.data());
      final productDoc =
          await _firestore.collection('products').doc(sale.id).get();
      final costPrice = productDoc['cost_price'];
      final sellPrice = productDoc['sell_price'];
      final profit = (sellPrice - costPrice) * sale.items;
      totalProfit += profit;
    }

    return totalProfit;
  }
}
