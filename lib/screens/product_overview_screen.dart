import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shop_villa/models/admob.dart';
import 'package:shop_villa/models/constants.dart';
import 'package:shop_villa/screens/search_screen.dart';
import 'package:shop_villa/widgets/build_images.dart' as buildImage;
import 'package:shop_villa/widgets/no_item.dart';
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
  var _category = 'Select Category';
  var _country = 'Select Country';

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
        .filterProduct(_country, _category);
  }

  @override
  void initState() {
    Admob.initialize(testDeviceIds: [AdmobService().getAdmobId()]);
    Admob.requestTrackingAuthorization();
    super.initState();
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
      bottomSheet: _isFilter
          ? buildFilter(context)
          : AdmobBanner(
              adUnitId: AdmobService().getBannerAddId(),
              adSize: AdmobBannerSize.FULL_BANNER,
            ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _reFreshProduct(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 55.0),
                child: Column(
                  children: [
                    buildImage.BuildImages(),
                    Provider.of<ProductsProvider>(context, listen: false)
                            .items
                            .isEmpty
                        ? Center(
                            child: NoItem(
                                text:
                                    'No Product Found!!! \n\nPlease Try With A Different Filter'),
                          )
                        : Expanded(child: ProductsGrid(false)),
                  ],
                ),
              )),
    );
  }

  Container buildFilter(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height * 0.35
          : MediaQuery.of(context).size.width * 0.30,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Filter'),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      _category = 'Select Category';
                      _country = 'Select Country';
                      _isLoading = true;
                    });
                    await Provider.of<ProductsProvider>(context, listen: false)
                        .filterProduct(_country, _category);
                    setState(() {
                      _isLoading = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Reset',
                      textAlign: TextAlign.right,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              //height: 100,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Country: ',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Container(
                      //height: 100,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: SearchableDropdown.single(
                        hint: 'Select Country',
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
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _country = value;
                          });
                        },
                      ),
                      // DropdownButton<String>(
                      //   dropdownColor: Colors.white,
                      //   value: _country,
                      //   onChanged: (value) {
                      //     setState(() {
                      //       _country = value;
                      //     });
                      //   },
                      //   items: Constants.countries.map((item) {
                      //     return DropdownMenuItem<String>(
                      //       value: item['country'],
                      //       child: Row(
                      //         children: <Widget>[
                      //           SizedBox(
                      //             width: 5,
                      //           ),
                      //           Text(
                      //             item['country'],
                      //             style: TextStyle(color: Colors.black),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   }).toList(),
                      // ),
                      ),
                ],
              ),
            ),
          ),
          Container(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              //height: 100,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Category: ',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  Container(
                    //height: 100,
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: SearchableDropdown.single(
                        hint: 'Select Category',
                        
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
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                        onChanged: (value) {
                          setState(() {
                           _category = value;
                          });
                        },
                      )
                    // DropdownButton<String>(
                    //   dropdownColor: Colors.white,
                    //   value: _category,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _category = value;
                    //     });
                    //   },
                    //   items: Constants.category.map((item) {
                    //     return DropdownMenuItem<String>(
                    //       value: item,
                    //       child: Row(
                    //         children: <Widget>[
                    //           SizedBox(
                    //             width: 5,
                    //           ),
                    //           Text(
                    //             item,
                    //             style: TextStyle(color: Colors.black),
                    //           ),
                    //         ],
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              setState(() {
                _isFilter = false;
                _isLoading = true;
              });
              await Provider.of<ProductsProvider>(context, listen: false)
                  .fetchAndSetProduc();
              await Provider.of<ProductsProvider>(context, listen: false)
                  .filterProduct(_country, _category);
              setState(() {
                _isLoading = false;
              });
            },
            child: Text(
              'Done',
              style: TextStyle(color: Colors.purple),
            ),
          )
        ],
      ),
    );
  }
}
