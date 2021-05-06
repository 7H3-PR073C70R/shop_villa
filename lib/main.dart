import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/screens/favorite_screen.dart';
import 'package:shop_villa/screens/search_screen.dart';
import 'models/providers/auth.dart';
import 'screens/auth_screen.dart';
import 'screens/cart_screen.dart';
import 'models/providers/cart.dart';
import 'screens/product_detail_screen.dart';
import 'screens/product_overview_screen.dart';
import 'models/providers/product_provider.dart';
import 'models/providers/order.dart';
import 'screens/order_screen.dart';
import 'screens/user_product_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<AuthProvider, ProductsProvider>(
            update: (context, auth, previousProducts) => ProductsProvider(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items)),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<AuthProvider, OrderProvider>(
            update: (context, auth, previousOrders) => OrderProvider(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders)),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shop Villa',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato'),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapShot) =>
                      authResultSnapShot.connectionState ==
                              ConnectionState.waiting
                          ? Loading()
                          : AuthScreen()),
          routes: {
            ProductsOverviewScreen.routeName: (context) =>
                ProductsOverviewScreen(),
            FavoriteScreen.routeName: (context) => FavoriteScreen(),
            ProductDetailsScreen.route: (context) => ProductDetailsScreen(),
            CartScreen.rounteName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductScreen.routeName: (context) => UserProductScreen(),
            SearchScreen.routeName: (context) => SearchScreen(),
            
          },
        ),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop Villa'),),
      body: Center(child: Text('Loading...')),
    );
  }
}
