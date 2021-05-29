import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BuildImages extends StatefulWidget {
  @override
  _BuildImagesState createState() => _BuildImagesState();
}

class _BuildImagesState extends State<BuildImages> {
  var _currentIndex = 0;
  final displayImages = [
    'assets/images/laptops.jpg',
    'assets/images/computers.jpg',
    'assets/images/shopping.png'
  ];
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.20;
    return Column(
      children: [
        Container(
            height: height,
            width: double.infinity,
            color: Colors.grey,
            child: CarouselSlider(
                items: displayImages
                    .map((e) => Image.asset(
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
                ))),
        Center(
          child: Container(
            height: 30,
            width: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 13.0,
                  height: 13.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index ? Colors.purple : Colors.grey),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
