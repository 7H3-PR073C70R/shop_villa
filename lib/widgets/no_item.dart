import 'package:flutter/material.dart';

class NoItem extends StatelessWidget {
  final String text;
  const NoItem({
    Key key, @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
            text,
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        )),
      ),
    ));
  }
}
