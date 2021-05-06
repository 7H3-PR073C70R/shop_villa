import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/providers/cart.dart' show CartProvider;
import '../widgets/cart_item.dart';
import '../models/providers/order.dart';

class CartScreen extends StatelessWidget {
  static const rounteName = '/Cart';
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Padding(
                      padding: const EdgeInsets.all(10),
                      child: FittedBox(
                        child: Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).primaryTextTheme.headline6,
                        ),
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
              child: cart.itemCount != 0
                  ? ListView.builder(
                      itemCount: cart.itemCount,
                      itemBuilder: (context, index) => CartItem(
                        id: cart.items.values.toList()[index].id,
                        title: cart.items.values.toList()[index].title,
                        quantity: cart.items.values.toList()[index].quantity,
                        price: cart.items.values.toList()[index].price,
                        productId: cart.items.keys.toList()[index],
                        imgUrl: cart.items.values.toList()[index].imgUrl,
                      ),
                    )
                  : Center(
                      child: Card(
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          //color: Theme.of(context).primaryColor,
                        ),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'What are you expecting? Oga go shop joor!!!',
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent),
                          ),
                        )),
                      ),
                    )))
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final CartProvider cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: widget.cart.totalAmount <= 0 || _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });
                await Provider.of<OrderProvider>(context, listen: false)
                    .addOrder(widget.cart.items.values.toList(),
                        widget.cart.totalAmount);
                setState(() {
                  _isLoading = false;
                });
                widget.cart.clear();
              },
        child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'));
  }
}
