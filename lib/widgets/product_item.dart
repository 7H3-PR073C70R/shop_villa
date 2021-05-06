import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/providers/auth.dart';
import '../models/providers/product.dart';
import '../screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final authData = Provider.of<AuthProvider>(context, listen: false);
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailsScreen.route, arguments: product.id);
          },
          child: GridTile(
            child: FadeInImage(
              placeholder:
                  AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(
                product.images.isNotEmpty ? product.images[0] : '',
                
              ),
              fit: BoxFit.fill,
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black54,
              leading: Consumer<Product>(
                  builder: (context, product, child) => IconButton(
                      icon: Icon(product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border),
                      onPressed: () {
                        product.toggleFavoriteStatus(
                            authData.token, authData.userId);
                      },
                      color: Theme.of(context).accentColor)),
              title: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              // trailing: IconButton(
              //   icon: Icon(Icons.shopping_cart),
              //   onPressed: () {
              //     cart.addItem(product.id, product.price, product.title,
              //         product.images[0]);
              //     ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //       backgroundColor: Theme.of(context).primaryColor,
              //       content: Container(
              //         //height: 25,
              //         width: double.infinity,
              //         child: Text(
              //           'Added Item to Cart',
              //           textAlign: TextAlign.left,
              //           style: TextStyle(
              //               fontSize: 18, fontWeight: FontWeight.normal),
              //         ),
              //       ),
              //       duration: Duration(seconds: 2),
              //       action: SnackBarAction(
              //           label: 'UNDO',
              //           onPressed: () {
              //             cart.removeSingleItem(product.id);
              //           }),
              //     ));
              //   },
              //   color: Colors.redAccent.shade700,
              // ),
            ),
          ),
        ));
  }
}
