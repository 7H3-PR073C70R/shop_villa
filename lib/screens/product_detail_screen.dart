import 'package:admob_flutter/admob_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/admob.dart';
import 'package:shop_villa/models/providers/product.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/providers/product_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const route = '/productScreen';

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isPressed = false;

  @override
  initState() {
    Admob.initialize(testDeviceIds: [AdmobService().getAdmobId()]);
    Admob.requestTrackingAuthorization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final product = Provider.of<ProductsProvider>(context, listen: false)
        .findById(productId);
    return Scaffold(
        appBar: AppBar(
          title: Text(product.title.toUpperCase()),
        ),
        bottomSheet: AdmobBanner(
          adUnitId: AdmobService().getBannerAddId(),
          adSize: AdmobBannerSize.FULL_BANNER,
        ),
        body: MediaQuery.of(context).orientation == Orientation.portrait
            ? Padding(
                padding: const EdgeInsets.only(bottom: 55.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    BuildImages(
                      product: product,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: BuildInfo(
                        product: product,
                      ),
                    )
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(bottom: 55.0),
                child: Row(
                  children: [
                    BuildImages(
                      product: product,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: BuildInfo(
                        product: product,
                      ),
                    )
                  ],
                ),
              ));
  }
}

class BuildInfo extends StatelessWidget {
  final Product product;

  const BuildInfo({Key key, this.product}) : super(key: key);

  _sendMail(String mail) async {
    // Android and iOS
   
    var uri = 'mailto:$mail?subject=&body=';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      final sendEmail = Mailto(
      to: ['$mail'],
      subject: '',
      body: '',
    );
     await launch('$sendEmail');
      //throw 'Could not launch $uri';
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
    return SingleChildScrollView(
      clipBehavior: Clip.none,
      child: Container(
        alignment: Alignment.bottomCenter,
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.35
            : MediaQuery.of(context).size.width * 0.35,
        child: ListView(
          clipBehavior: Clip.none,
          scrollDirection: Axis.vertical,
          children: [
            Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Price:\$${product.price}',
                style: Theme.of(context).textTheme.headline6,
              ),
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
            Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(product.creatorId)
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
                                                  BorderRadius.circular(20),
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          child: IconButton(
                                              icon: Icon(Icons.phone,
                                                  color: Colors.white),
                                              onPressed: () {
                                                _callMe(
                                                    documents.data()['phone']);
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
                                                  BorderRadius.circular(20),
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          child: IconButton(
                                              icon: Icon(Icons.message,
                                                  color: Colors.white),
                                              onPressed: () {
                                                _textMe(
                                                    documents.data()['phone']);
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
                                                  BorderRadius.circular(20),
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          child: IconButton(
                                              icon: Icon(
                                                Icons.email,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                _sendMail(
                                                    documents.data()['email']);
                                              }),
                                        ),
                                        Text('Email'),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BuildImages extends StatefulWidget {
  final Product product;

  const BuildImages({Key key, this.product}) : super(key: key);
  @override
  _BuildImagesState createState() => _BuildImagesState();
}

class _BuildImagesState extends State<BuildImages> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double height =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.35
            : MediaQuery.of(context).size.width * 0.25;
    return Column(
      children: [
        Container(
          height: height,
          width: MediaQuery.of(context).orientation == Orientation.portrait
              ? double.infinity
              : MediaQuery.of(context).size.width * 0.60,
          color: Colors.grey,
          child: widget.product.images.length > 1
              ? CarouselSlider(
                  items: widget.product.images
                      .map((e) => Image.network(
                            e,
                            fit: BoxFit.fill,
                            height: height,
                            width: double.infinity,
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
                  widget.product.images[0],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  //height: MediaQuery.of(context).size.height * 0.40,
                ),
        ),
        widget.product.images.length > 1
            ? Center(
                child: Container(
                  height: 30,
                  width: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.product.images.length,
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
      ],
    );
  }
}
