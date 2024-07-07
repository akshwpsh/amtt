import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'ProductDetailPage.dart';

class WishListPage extends StatefulWidget {
  @override
  _WishListPageState createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchWishProducts() async {
    User? user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(code: 'ERROR_NO_USER', message: '로그인먼저');
    }
    QuerySnapshot wishlistSnapshot = await _firestore
        .collection('wishlist')
        .where('userID', isEqualTo: user.uid)
        .get();

    List<String> postIds =
        wishlistSnapshot.docs.map((doc) => doc['postId'] as String).toList();
    List<Map<String, dynamic>> wishProducts = [];
    for (String postId in postIds) {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(postId).get();
      if (productSnapshot.exists) {
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;
        productData['postId'] = postId;
        wishProducts.add(productData);
      }
    }
    return wishProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('찜 리스트'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchWishProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final data = snapshot.data![index];
              final String postname = data['postName'] ?? 'No title';
              final String userName = data['userName'] ?? 'Unknown';
              final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
              final String formattedDate =
                  DateFormat('yyyy-MM-dd').format(timestamp.toDate());
              final List<dynamic> imageUrls = data['imageUrls'] ?? [];

              return Card(
                child: ListTile(
                  leading: imageUrls.isNotEmpty
                      ? Image.network(
                          imageUrls[0],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error);
                          },
                        )
                      : null,
                  title: Text(postname),
                  subtitle: Text('by $userName\n$formattedDate'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          postId: data['postId'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
