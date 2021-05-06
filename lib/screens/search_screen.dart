import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/providers/product.dart';
import 'package:shop_villa/models/providers/product_provider.dart';
import 'package:shop_villa/widgets/product_item.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  //var _isInit = true;
  TextEditingController _searchedController = new TextEditingController();

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProduc();

  //     _isInit = false;
  //   }
  //   super.didChangeDependencies();
  // }

  searchedAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 5),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            controller: _searchedController,
            cursorColor: Colors.black,
            autofocus: true,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 35, color: Colors.white),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _searchedController.clear());
                  setState(() {
                    query = '';
                  });
                },
              ),
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 35,
                color: Color(0x88ffffff),
              ),
            ),
            onChanged: (val) {
              setState(() {
                query = val;
              });
            },
          ),
        ),
      ),
    );
  }

  buildSuggestion(String query) {
    final List<Product> product = query.isEmpty
        ? []
        : Provider.of<ProductsProvider>(context).searchedItems(query);
    return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: product.length,
        itemBuilder: (context, index) => ChangeNotifierProvider.value(
              value: product[index],
              child: ProductItem(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: searchedAppBar(context),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildSuggestion(query),
        ));
  }
}
