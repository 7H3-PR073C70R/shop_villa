import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/admob.dart';
import 'package:shop_villa/models/providers/product_provider.dart';
import 'package:shop_villa/widgets/build_images.dart';
import 'package:shop_villa/widgets/no_item.dart';
import 'package:shop_villa/widgets/products_grid.dart';
import '../widgets/app_drawer.dart';

class FavoriteScreen extends StatefulWidget {
  static const routeName = '/fav';

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  var _isInit = true;
  var _isLoading = false;

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
  }
  @override
  void initState() {
    Admob.initialize(testDeviceIds:[AdmobService().getAdmobId()]);
    Admob.requestTrackingAuthorization();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {}),
        ],
      ),
      bottomSheet: AdmobBanner(
           adUnitId: AdmobService().getBannerAddId(), 
           adSize: AdmobBannerSize.FULL_BANNER,
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 55.0),
                child: Column(
                  children: [
                    BuildImages(),
                    Provider.of<ProductsProvider>(context, listen: false)
                            .items.where((element) => element.isFavorite).toList()
                            .isEmpty
                        ? Center(
                          child: NoItem(
                              text:
                                  '\tOH NO!!! \n\nYou do not have any favorite product yet'),
                        )
                        : 
                    Expanded(child: ProductsGrid(true)),
                  ],
                ),
              )),
    );
  }
}

