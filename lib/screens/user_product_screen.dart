import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/no_item.dart';
import '../screens/edit_product_screen.dart';
import '../models/providers/product_provider.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/product';

  

  Future<void> _reFreshProduct(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProduc(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () =>
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditProductScreen(isAdd: true,))))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: FutureBuilder(
          future: _reFreshProduct(context),
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _reFreshProduct(context);
                  },
                  child: Consumer<ProductsProvider>(
                    builder: (context, productsData, _) => Padding(
                      padding: const EdgeInsets.all(8),
                      child: productsData.items.length != 0 ? ListView.builder(
                          itemCount: productsData.items.length,
                          itemBuilder: (_, index) => Column(
                                children: [
                                  UserProductItem(
                                    id: productsData.items[index].id,
                                    title: productsData.items[index].title,
                                    imageUrl: productsData.items[index].images[0],
                                  ),
                                  Divider(),
                                ],
                              )
                              ):NoItem(text:'\tOH NO!!!\n You haven\'t post any product yet.\n You can click on the "+" button to do so.'),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
