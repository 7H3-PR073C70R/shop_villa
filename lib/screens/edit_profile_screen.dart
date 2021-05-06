import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shop_villa/models/providers/auth.dart';
import 'package:shop_villa/screens/auth_screen.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController country = TextEditingController();
  File imageFile;
  String imageUrl;
  bool isLoading = false;
  bool isSelected = false;

  @override
  initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserId)
        .get();
    setState(() {
      isLoading = false;
      username.text = doc['username'];
      imageUrl = doc['profilePicture'];
      email.text = doc['email'];
      phone.text = doc['phone'];
      country.text = doc['country'];
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profileImage')
            .child('${widget.currentUserId}${DateTime.now()}.jpg');
        await ref.putFile(imageFile);
        final image = await ref.getDownloadURL();
        setState(() {
          imageUrl = image;
        });
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .update({
        'email': email.text,
        'phone': phone.text,
        'username': username.text,
        'country': country.text,
        'profilePicture': imageUrl != null ? imageUrl : ''
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Profile",
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await _submit();
              getUser();
            },
            icon: Icon(
              Icons.save,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          top: 16.0,
                          bottom: 8.0,
                        ),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              maxRadius: 60.0,
                              backgroundImage: 
                                   !isSelected
                                      ? NetworkImage(imageUrl)
                                      : FileImage(imageFile)
                                  
                            ),
                            Positioned(
                                left: 80,
                                top: 70,
                                child: GestureDetector(
                                  onTap: () async {
                                    var cameraStatus =
                                        await Permission.camera.status;
                                    var medialStatus =
                                        await Permission.mediaLibrary.status;
                                    if (cameraStatus.isGranted ||
                                        medialStatus.isGranted) {
                                      try {
                                        var pickImage = ImagePicker();
                                        PickedFile picked =
                                            await pickImage.getImage(
                                                source: ImageSource.gallery);
                                        File img = File(picked.path);

                                        setState(() {
                                          imageFile = img;
                                          isSelected = true;
                                        });
                                      } on PlatformException {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              'Please Accept permission to continue'),
                                          backgroundColor:
                                              Theme.of(context).errorColor,
                                        ));
                                      }
                                    } else {
                                      await Permission.camera.request();
                                      await Permission.mediaLibrary.request();
                                    }
                                  },
                                  child: Icon(
                                    Icons.photo,
                                    size: 50,
                                    color: Colors.orange,
                                  ),
                                ))
                          ],
                          clipBehavior: Clip.none,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: username,
                                      key: ValueKey('username'),
                                      decoration: InputDecoration(
                                          labelText: 'Username'),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Username cannot be empty';
                                        }
                                        if (value.length < 3) {
                                          return 'Username must be atleast 4 characters long';
                                        }
                                        if (value.contains(' ')) {
                                          return 'Username cannot contain white space';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: email,
                                      key: ValueKey('email'),
                                      decoration:
                                          InputDecoration(labelText: 'Email'),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          if (value.isEmpty ||
                                              !value.contains('@')) {
                                            return 'Invalid email!';
                                          }
                                          return null;
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: phone,
                                      key: ValueKey('phone'),
                                      decoration:
                                          InputDecoration(labelText: 'Phone'),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Phone number cannot be empty';
                                        }
                                        if (value.length < 6) {
                                          return 'Phone number must be atleast 7 digits long';
                                        }
                                        if (value.contains(' ')) {
                                          return 'Phone number cannot contain white space';
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      controller: country,
                                      key: ValueKey('country'),
                                      decoration:
                                          InputDecoration(labelText: 'Country'),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Country cannot be empty';
                                        }
                                        if (value.length < 3) {
                                          return 'Country must be atleast 4 characters long';
                                        }
                                        if (value.contains(' ')) {
                                          return 'Country cannot contain white space';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ))
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
                            Provider.of<AuthProvider>(context).logout();
                          },
                          icon: Icon(Icons.cancel, color: Colors.red),
                          label: Text(
                            "Logout",
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
