import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/providers/auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/providers/product_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const route = '/productScreen';

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isPressed = false;
  int _currentIndex = 0;

  _sendMail(String mail) async {
    // Android and iOS
    var uri = 'mailto:$mail?subject= &body=';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  _callMe(String phone) async {
    // Android
    var uri = 'tel:+$phone';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      var uri = 'tel:00$phone';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  _textMe(String phone) async {
    // Android
    var uri = 'sms:+$phone';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      // iOS
      var uri = 'sms:00$phone';
      if (await canLaunch(uri)) {
        await launch(uri);
      } else {
        throw 'Could not launch $uri';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<AuthProvider>(context).userId;
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<ProductsProvider>(context, listen: false)
        .findById(productId);
    return Scaffold(
        appBar: AppBar(
          title: Text(product.title),
        ),
        body: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.45,
              color: Colors.grey,
              child: product.images.length > 1
                  ? CarouselSlider(
                      items: product.images
                          .map((e) => Image.network(
                                e,
                                fit: BoxFit.fill,
                                width: 250,
                              ))
                          .toList(),
                      options: CarouselOptions(
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        autoPlay: true,
                        enlargeCenterPage: true,
                      ))
                  : Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      //height: MediaQuery.of(context).size.height * 0.40,
                    ),
            ),
            product.images.length > 1
                ? Center(
                    child: Container(
                      height: 55,
                      width: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 13.0,
                            height: 13.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == index
                                    ? Colors.purple
                                    : Colors.grey),
                          );
                        },
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 5,
            ),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.30,
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: [
                    Center(
                        child: Text(
                      'D${product.price}',
                      style: Theme.of(context).textTheme.headline6,
                    )),
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            Text(
                              'Product Discription',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              softWrap: true,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              }
                              final DocumentSnapshot documents = snapshot.data;
                              return Container(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  children: [
                                    Text(
                                      'Contact ${documents.data()['username']}',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                      softWrap: true,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                child: IconButton(
                                                    icon: Icon(Icons.phone,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      _callMe(documents
                                                          .data()['phone']);
                                                    }),
                                              ),
                                              Text('Phone')
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                child: IconButton(
                                                    icon: Icon(Icons.message,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      _textMe(documents
                                                          .data()['phone']);
                                                    }),
                                              ),
                                              Text('Message')
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                child: IconButton(
                                                    icon: Icon(
                                                      Icons.email,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      _sendMail(documents
                                                          .data()['email']);
                                                    }),
                                              ),
                                              Text('Email')
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
