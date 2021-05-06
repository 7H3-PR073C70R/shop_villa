import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/no_item.dart';
import '../widgets/app_drawer.dart';
import '../models/providers/order.dart' show OrderProvider;
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _obtainedOrdersFuture() async {
    return await Provider.of<OrderProvider>(context, listen: false)
        .fetchAndSetOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: RefreshIndicator(
          onRefresh: () => _obtainedOrdersFuture(),
          child: FutureBuilder(
              future: Provider.of<OrderProvider>(context, listen: false)
                  .fetchAndSetOrders(),
              builder: (context, dataSnapShot) {
                if (dataSnapShot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (dataSnapShot.hasData) {
                    return NoItem(text:'What are you expecting? Oga go shop joor!!!');
                  } else {
                    return Consumer<OrderProvider>(
                        builder: (context, orderData, child) {
                      return orderData.orders.length != 0 ? ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (context, index) =>
                              OrderItem(orderData.orders[index])):NoItem(text:'What are you expecting? Oga go shop joor!!!');
                    });
                  }
                }
              }),
        ));
  }
}

