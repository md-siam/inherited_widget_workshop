import 'package:flutter/material.dart';

import '../main.dart';
import '../server/server.dart';

class MySorePage extends StatefulWidget {
  const MySorePage({Key? key}) : super(key: key);
  @override
  MySorePageState createState() => MySorePageState();
}

class MySorePageState extends State<MySorePage> {
  bool _inSearch = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  void _toggleSearch() {
    setState(() {
      _inSearch = !_inSearch;
    });

    _controller = TextEditingController();
    productList.currentState!.productList = Server.getProductList();
  }

  void _handleSearch() {
    _focusNode.unfocus();
    final String filter = _controller.text;
    productList.currentState!.productList =
        Server.getProductList(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/google-logo.png'),
            ),
            title: _inSearch
                ? TextField(
                    autofocus: true,
                    focusNode: _focusNode,
                    controller: _controller,
                    onSubmitted: (_) => _handleSearch(),
                    decoration: InputDecoration(
                      hintText: 'Search Google Store',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _handleSearch,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _toggleSearch,
                      ),
                    ))
                : null,
            actions: <Widget>[
              if (!_inSearch)
                IconButton(
                  onPressed: _toggleSearch,
                  icon: const Icon(Icons.search, color: Colors.black),
                ),
              ShoppingCartIcon(key: shoppingCart),
            ],
            backgroundColor: Colors.white,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: ProductList(key: productList),
          ),
        ],
      ),
    );
  }
}

class ShoppingCartIcon extends StatefulWidget {
  const ShoppingCartIcon({Key? key}) : super(key: key);
  @override
  ShoppingCartIconState createState() => ShoppingCartIconState();
}

class ShoppingCartIconState extends State<ShoppingCartIcon> {
  Set<String> get purchaseList => _purchaseList;
  Set<String> _purchaseList = <String>{};
  set purchaseList(Set<String> value) {
    setState(() {
      _purchaseList = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPurchase = purchaseList.isNotEmpty;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: hasPurchase ? 17.0 : 0.0),
          child: const Icon(
            Icons.shopping_cart,
            color: Colors.black,
          ),
        ),
        if (hasPurchase)
          Padding(
            padding: const EdgeInsets.only(left: 17.0),
            child: CircleAvatar(
              radius: 8.0,
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              child: Text(
                purchaseList.length.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({Key? key}) : super(key: key);
  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList>
    with TickerProviderStateMixin {
  List<String> get productList => _productList;
  List<String> _productList = Server.getProductList();
  set productList(List<String> value) {
    setState(() {
      _productList = value;
    });
  }

  Set<String> get purchaseList => _purchaseList;
  Set<String> _purchaseList = <String>{};
  set purchaseList(Set<String> value) {
    setState(() {
      _purchaseList = value;
    });
  }

  void _handleAddToCart(String id) {
    purchaseList = _purchaseList..add(id);
    shoppingCart.currentState!.purchaseList = purchaseList;
  }

  void _handleRemoveFromCart(String id) {
    purchaseList = _purchaseList..remove(id);
    shoppingCart.currentState!.purchaseList = purchaseList;
  }

  Widget _buildProductTile(String id) {
    return ProductTile(
      product: Server.getProductById(id),
      purchased: purchaseList.contains(id),
      onAddToCart: () => _handleAddToCart(id),
      onRemoveFromCart: () => _handleRemoveFromCart(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: productList.map(_buildProductTile).toList(),
    );
  }
}

class ProductTile extends StatelessWidget {
  final Product product;
  final bool purchased;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;

  const ProductTile({
    Key? key,
    required this.product,
    required this.purchased,
    required this.onAddToCart,
    required this.onRemoveFromCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getButtonColor(Set<MaterialState> states) {
      return purchased ? Colors.grey : Colors.black;
    }

    BorderSide getButtonSide(Set<MaterialState> states) {
      return BorderSide(
        color: purchased ? Colors.grey : Colors.black,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 40,
      ),
      color: const Color(0xfff8f8f8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(product.title),
          ),
          Text.rich(
            product.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.resolveWith(getButtonColor),
                side: MaterialStateProperty.resolveWith(getButtonSide),
              ),
              onPressed: purchased ? onRemoveFromCart : onAddToCart,
              child: purchased
                  ? const Text("Remove from cart")
                  : const Text("Add to cart"),
            ),
          ),
          Image.asset(product.pictureKey),
        ],
      ),
    );
  }
}
