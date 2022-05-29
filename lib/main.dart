import 'package:flutter/material.dart';
import 'package:inherited_widget_workshop/view/store_page.dart';

final GlobalKey<ShoppingCartIconState> shoppingCart =
    GlobalKey<ShoppingCartIconState>();
final GlobalKey<ProductListState> productList = GlobalKey<ProductListState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inherited Widget Workshop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MySorePage(),
    );
  }
}
