import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _selectedItems = []; // Sepete eklenen ürünlerin listesi
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('products').get();
    setState(() {
      _cartItems.clear();
      _totalPrice = 0.0;
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Store the document ID
        _cartItems.add(data);
      }
    });
  }

  void _addItem(String name, double price) {
    // Ürünü Firestore'a ekleyin
    _firestore.collection('products').add({
      'name': name,
      'price': price,
    }).then((DocumentReference doc) {
      // Ürün eklendikten sonra yerel listeyi güncelleyin
      setState(() {
        _cartItems.add({
          'id': doc.id,
          'name': name,
          'price': price,
        });
      });
    }).catchError((error) {
      print("Failed to add product: $error");
    });
  }

  void _updateItem(String id, String name, double price) {
    // Ürünü Firestore'da güncelleyin
    _firestore.collection('products').doc(id).update({
      'name': name,
      'price': price,
    }).then((_) {
      // Ürün güncellendikten sonra yerel listeyi güncelleyin
      setState(() {
        final index = _cartItems.indexWhere((item) => item['id'] == id);
        if (index != -1) {
          _cartItems[index]['name'] = name;
          _cartItems[index]['price'] = price;
        }
      });
    }).catchError((error) {
      print("Failed to update product: $error");
    });
  }

  void _deleteItem(String id) {
    // Ürünü Firestore'dan silin
    _firestore.collection('products').doc(id).delete().then((_) {
      // Ürün silindikten sonra yerel listeyi güncelleyin
      setState(() {
        _cartItems.removeWhere((item) => item['id'] == id);
      });
    }).catchError((error) {
      print("Failed to delete product: $error");
    });
  }

  void _checkout() {
    // Ödeme işlemleri buraya eklenebilir

    // Satış kaydını yap
    _recordSale(_selectedItems, _totalPrice);

    // Sadece ödeme işlemleri gerçekleştikten sonra ürünlerin silinmesi
    // istendiği için bu kısımda sadece _totalPrice'ın sıfırlanması yeterli olacaktır.
    setState(() {
      _totalPrice = 0.0;
      _selectedItems.clear(); // Sepetten tüm ürünleri çıkar
    });
  }
  void _recordSale(List<Map<String, dynamic>> soldItems, double totalPrice) {
    soldItems.forEach((item) {
      _firestore.collection('sales').add({
        'productName': item['name'],
        'quantity': 1, // Örnek olarak her ürünün sadece bir adet satıldığını varsayalım
        'totalPrice': item['price'],
        'createdAt': DateTime.now(),
      }).then((_) {
        print('Satış kaydedildi: ${item['name']}');
      }).catchError((error) {
        print("Satış kaydedilemedi: $error");
      });
    });

    // Toplam satış fiyatını kaydetmek için ayrı bir doküman oluşturabiliriz
    _firestore.collection('sales_summary').add({
      'totalSales': totalPrice,
      'createdAt': DateTime.now(),
    }).then((_) {
      print('Toplam satış kaydedildi: $totalPrice');
    }).catchError((error) {
      print("Toplam satış kaydedilemedi: $error");
    });
  }


  void _addToTotal(String id, String name, double price) {
    setState(() {
      _totalPrice += price;
      _selectedItems.add({
        'id': id,
        'name': name,
        'price': price.toString(), // Price'ı bir stringe dönüştür
      });
    });
  }

  void _removeFromTotal(double price) {
    setState(() {
      _totalPrice -= price;
    });
  }

  void _deleteCartItem(int index) {
    setState(() {
      // Get the ID of the item to remove from the selected items list
      String idToRemove = _selectedItems[index]['id'];

      // Find the index of the item to remove in the _cartItems list
      int cartItemIndex = _cartItems.indexWhere((item) => item['id'] == idToRemove);

      // Remove the item from the selected items list
      _selectedItems.removeAt(index);

      // If the item exists in the cart items list, update the total price
      if (cartItemIndex != -1) {
        double removedItemPrice = _cartItems[cartItemIndex]['price'];
        _totalPrice -= removedItemPrice;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _selectedItems.clear();
      _totalPrice = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 140,
        backgroundColor: Colors.white,
        centerTitle: true,
          title: Column(
            children: [
              Image.asset(
                'assets/images/facebook.png',
                height: 70,
              ),
              Text(
                'Menü',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
    actions: [
    IconButton(
    icon: Icon(Icons.add_circle),
    onPressed: () {
    _showAddProductDialog(context);
    },
    ),
    IconButton(
    icon: Icon(Icons.shopping_basket),
    onPressed: () {
    _showCart(context);
    },
    ),
    ],
    ),

    body: Column(
    children: [
    Expanded(
    child: GridView.count(
    crossAxisCount: 4,               crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: _cartItems.map((item) {
        return _buildCartItem(item['id'], item['name'], item['price']);
      }).toList(),
    ),
    ),
      Divider(),
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.black, // Set trash bin icon color to black
              onPressed: _clearCart, // Call _clearCart method when pressed
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                  'Toplam Fiyat: \n        $_totalPrice ₺',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),

            IconButton(
              icon: Icon(Icons.send),
              color: Colors.black, // Set send button color to black
              onPressed: _checkout,
            ),
          ],
        ),
      ),
    ],
    ),
    );
  }

  Widget _buildCartItem(String id, String name, double price) {
    return GestureDetector(
      onTap: () {
        _addToTotal(id, name, price);
      },
      onLongPress: () {
        _showEditDeleteDialog(context, id, name, price);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                '${price.toString()} ₺',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    String productName = '';
    double productPrice = 0.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ürün Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Ürün Adı'),
                onChanged: (value) {
                  productName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  productPrice = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (productName.isNotEmpty && productPrice > 0) {
                  _addItem(productName, productPrice);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDeleteDialog(BuildContext context, String id, String name, double price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ürünü Düzenle veya Sil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Düzenle'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEditProductDialog(context, id, name, price);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Sil'),
                onTap: () {
                  Navigator.of(context).pop();
                  _deleteItem(id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProductDialog(BuildContext context, String id, String name, double price) {
    String productName = name;
    double productPrice = price;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ürünü Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Ürün Adı'),
                controller: TextEditingController(text: name),
                onChanged: (value) {
                  productName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Fiyat'),
                controller: TextEditingController(text: price.toString()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  productPrice = double.tryParse(value) ?? 0.0;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (productName.isNotEmpty && productPrice > 0) {
                  _updateItem(id, productName, productPrice);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Güncelle'),
            ),
          ],
        );
      },
    );
  }

  void _showCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sepet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _selectedItems.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return ListTile(
                title: Text(item['name']),
                subtitle: Text('${item['price']} ₺'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_shopping_cart),
                  onPressed: () {
                    _deleteCartItem(index); // Sepetten ürünü çıkar
                    Navigator.of(context).pop(); // Sepet dialogunu kapat
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
// Yatayda 4 ürün
