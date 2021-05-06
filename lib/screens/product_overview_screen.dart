import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/constants.dart';
import 'package:shop_villa/screens/search_screen.dart';
import '../widgets/app_drawer.dart';
import '../models/providers/product_provider.dart';
import '../widgets/products_grid.dart';

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = '/poscreen';
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _isInit = true;
  var _isLoading = false;
  var _isFilter = false;
  var _category = 'Any';
  var _country = 'Any';

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductsProvider>(context, listen: false)
          .fetchAndSetProduc()
          .then((value) {
        setState(() {
          _isLoading = false;
        });
      });

      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _reFreshProduct(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProduc();
    await Provider.of<ProductsProvider>(context, listen: false)
        .filterProduct(_country, _category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Villa'),
        actions: [
          // PopupMenuButton(
          //     onSelected: (FilterOptions selectedValue) {
          //       setState(() {
          //         if (selectedValue == FilterOptions.Favorites) {
          //           _showOnlyFavorites = true;
          //         } else {
          //           _showOnlyFavorites = false;
          //         }
          //       });
          //     },
          //     icon: Icon(Icons.more_vert),
          //     itemBuilder: (_) => [
          //           PopupMenuItem(
          //             child: Text('Only Favourite'),
          //             value: FilterOptions.Favorites,
          //           ),
          //           PopupMenuItem(
          //             child: Text('Show All'),
          //             value: FilterOptions.All,
          //           ),
          //         ]),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).pushNamed(SearchScreen.routeName);
              }),
          IconButton(
              icon: Icon(Icons.settings_outlined),
              onPressed: () {
                setState(() {
                  _isFilter = !_isFilter;
                });
              }),
          // Consumer<CartProvider>(
          //   builder: (_, cart, child) => Padding(
          //     padding: const EdgeInsets.only(right: 12.0, left: 5),
          //     child: GestureDetector(
          //       onTap: () {
          //         Navigator.of(context).pushNamed(CartScreen.rounteName);
          //       },
          //       child: Badge(
          //         child: child,
          //         value: '${cart.itemCount}',
          //       ),
          //     ),
          //   ),
          //   child: Icon(Icons.shopping_cart),
          // )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _reFreshProduct(context);
              },
              child: Row(
                children: [
                  _isFilter
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.35,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text('Filter'),
                                  GestureDetector(
                                    onTap: () {
                                      Provider.of<ProductsProvider>(context)
                                          .fetchAndSetProduc();
                                    },
                                    child: Text(
                                      'Reset',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                //height: 100,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category: ',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                    DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      value: _country,
                                      onChanged: (value) {
                                        setState(() {
                                          _category = value;
                                        });
                                      },
                                      items: Constants.category.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item,
                                          child: Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                item,
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                //height: 100,
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Country: ',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),
                                    DropdownButton<String>(
                                      dropdownColor: Colors.white,
                                      value: _country,
                                      onChanged: (value) {
                                        setState(() {
                                          _country = value;
                                        });
                                      },
                                      items: Constants.countries.map((item) {
                                        return DropdownMenuItem<String>(
                                          value: item['country'],
                                          child: Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                item['country'],
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isFilter = false;
                                  });
                                  _reFreshProduct(context);
                                },
                                child: Text(
                                  'Done',
                                  style: TextStyle(color: Colors.purple),
                                ),
                              )
                            ],
                          ),
                        )
                      : Container(),
                  ProductsGrid(false),
                ],
              )),
    );
  }
}
