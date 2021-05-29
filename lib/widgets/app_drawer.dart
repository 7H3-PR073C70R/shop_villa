import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/providers/auth.dart';
import 'package:shop_villa/screens/edit_profile_screen.dart';
import 'package:shop_villa/screens/favorite_screen.dart';
import '../screens/user_product_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<AuthProvider>(context).userId;
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
          ),
          Container(
            color: Theme.of(context).primaryColor,
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height * 0.30
                : MediaQuery.of(context).size.width * 0.25,
            width: double.infinity,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  final DocumentSnapshot documents = snapshot.data;
                  return Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            maxRadius: 60.0,
                            backgroundImage: documents
                                    .data()['profilePicture']
                                    .toString()
                                    .isNotEmpty
                                ? NetworkImage(
                                    documents.data()['profilePicture'])
                                : null,
                          ),
                          Positioned(
                              left: 80,
                              top: 70,
                              child: GestureDetector(
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (_) => EditProfile(
                                              currentUserId: userId,
                                            ))),
                                child: Icon(
                                  Icons.settings,
                                  size: 50,
                                  color: Colors.deepOrange,
                                ),
                              ))
                        ],
                        clipBehavior: Clip.none,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Welcome ${documents.data()['username'].toString().isNotEmpty ? documents.data()['username'] : ''}",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                }),
          ),
          Expanded(
            child: Container(
                child: ListView(
              shrinkWrap: true,
              clipBehavior: Clip.none,
              children: [
                Divider(),
                ListTile(
                  leading: Icon(Icons.shop),
                  title: Text('Shop'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Favorites'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(FavoriteScreen.routeName);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Manage Products'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed(UserProductScreen.routeName);
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                    Provider.of<AuthProvider>(context, listen: false).logout();
                  },
                ),
              ],
            )),
          )
        ],
      ),
    );
  }
}
