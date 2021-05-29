import 'dart:io';
import 'dart:math';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shop_villa/models/constants.dart';
import 'package:shop_villa/models/http_exception.dart';
import '../models/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Colors.blue,
                  // Colors.orange
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Shop Villa',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 44,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;

  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  File imageFile;
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  var isNext = false;
  var _country = 'Select Country';
  var _countryCode = '234';
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(begin: Offset(0, -1.5), end: Offset(0, 0))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showErrorDialog(String errormsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(errormsg),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }

    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<AuthProvider>(context, listen: false)
            .login(_emailController.text, _passwordController.text);
      } else {
        // Sign user up
        if (imageFile != null && _country != 'Select Country') {
          await Provider.of<AuthProvider>(context, listen: false).signup(
              email: _emailController.text,
              password: _passwordController.text,
              username: _usernameController.text,
              phone: '$_countryCode${_phoneController.text}',
              country: _country,
              image: imageFile);
          //print('done setting up user');
        } else
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No Profile Picture Or Country Selected!!!'),
            backgroundColor: Theme.of(context).errorColor,
          ));
      }
    } on HttpException catch (error) {
      var errorMessage = "Authentication failed";
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Invalid Email Address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is to weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND') ||
          error.toString().contains('INVALID_PASSWORD')) {
        errorMessage =
            'The email address or password provided does not match the one on record';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          "Could not authenticate you at the moment. Please check your internet conncet and try again";
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  void pikedImage() async {
    var cameraStatus = await Permission.camera.status;
    var medialStatus = await Permission.mediaLibrary.status;
    if (cameraStatus.isGranted || medialStatus.isGranted) {
      try {
        var picker = ImagePicker();
        PickedFile pickedFile =
            await picker.getImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            imageFile = File(pickedFile.path);
          });
        }
      } on PlatformException {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please Accept permission to continue'),
          backgroundColor: Theme.of(context).errorColor,
        ));
      }
    } else {
      await Permission.camera.request();
      await Permission.mediaLibrary.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var randeredText = !isNext
        ? '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'
        : 'BACK';
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        curve: Curves.easeInOutSine,
        // _authMode == AuthMode.Signup ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.Signup && !isNext
              ? deviceSize.height * 0.90
              : deviceSize.height * 0.40,
        ),
        width: deviceSize.width * 0.90,
        padding: EdgeInsets.all(16.0),
        duration: Duration(milliseconds: 300),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (!isNext)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 160 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 160 : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                          position: _slideAnimation,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                  maxRadius: 70,
                                  backgroundImage: imageFile != null
                                      ? FileImage(
                                          imageFile,
                                        )
                                      : null),
                              Positioned(
                                left: 85,
                                top: 100,
                                child: GestureDetector(
                                  child: Icon(
                                    Icons.photo,
                                    size: 50,
                                    color: Theme.of(context).accentColor,
                                  ),
                                  onTap: pikedImage,
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                if (isNext)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 60 : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          controller: _usernameController,
                          key: ValueKey('username'),
                          decoration: InputDecoration(labelText: 'Username'),
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
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
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                if (isNext)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 60 : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          //height: 100,
                          width: MediaQuery.of(context).size.width,
                          child: Container(
                            //height: 100,
                            width: MediaQuery.of(context).size.width * 0.75,
                            child: SearchableDropdown.single(
                              hint: 'Select A Country',
                              items: Constants.countries.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['country'],
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        item['country'],
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _country = value;
                                });
                              },
                            ),
                          ),
                          // DropdownButton<String>(
                          //   dropdownColor: Colors.white,
                          //   value: _country,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _country = value;
                          //       var selectedCountry = Constants.countries
                          //           .where((element) =>
                          //               element['country'] == value)
                          //           .toList();
                          //       _countryCode = selectedCountry[0]['code'];
                          //     });
                          //   },
                          //   items: Constants.countries.map((item) {
                          //     return DropdownMenuItem<String>(
                          //       value: item['country'],
                          //       child: Row(
                          //         children: <Widget>[
                          //           SizedBox(
                          //             width: 5,
                          //           ),
                          //           Text(
                          //             item['country'],
                          //             style: TextStyle(color: Colors.black),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   }).toList(),
                          // ),
                        ),

                        // TextFormField(
                        //   enabled: _authMode == AuthMode.Signup,
                        //   controller: _countryController,
                        //   decoration: InputDecoration(labelText: 'Country'),
                        //   //key: ValueKey('con'),
                        //   validator: _authMode == AuthMode.Signup
                        //       ? (value) {
                        //           if (value.isEmpty) {
                        //             return 'Country cannot be empty';
                        //           }
                        //           if (value.length < 3) {
                        //             return 'Country name must be atleast 4 characters long';
                        //           }
                        //           return null;
                        //         }
                        //       : null,
                        // ),
                      ),
                    ),
                  ),
                if (isNext)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 60 : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 8.0, left: 8.0),
                              child: Text(_countryCode),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: TextFormField(
                                enabled: _authMode == AuthMode.Signup,
                                keyboardType: TextInputType.number,
                                controller: _phoneController,
                                key: ValueKey('phone'),
                                decoration: InputDecoration(
                                  labelText: 'Phone',
                                ),
                                validator: _authMode == AuthMode.Signup
                                    ? (value) {
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
                                      }
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isNext)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value.isEmpty || !EmailValidator.validate(value, true)) {
                        return 'Invalid email!';
                      }
                      if ((value.contains('gmail') || value.contains('yahoo') || value.contains('hotmail') || value.contains('outlook')) && !value.endsWith('.com')) {
                        return 'Invalid email!';
                      }
                      return null;
                    },
                    controller: _emailController,
                  ),
                if (!isNext)
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    key: ValueKey('pass'),
                    validator: (value) {
                      if (value.isEmpty || value.length < 6) {
                        return 'Password is too short!';
                      }
                      return null;
                    },
                  ),
                if (!isNext)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                        maxHeight: _authMode == AuthMode.Signup ? 60 : 0),
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              InputDecoration(labelText: 'Confirm Password'),
                          obscureText: true,
                          key: ValueKey('firm'),
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                if (!isNext)
                  Container(
                    alignment: Alignment.centerRight,
                    // duration: Duration(milliseconds: 300),
                    // curve: Curves.easeIn,
                    constraints: BoxConstraints(
                        minHeight: _authMode == AuthMode.Login ? 30 : 0,
                        maxHeight: _authMode == AuthMode.Login ? 30 : 0),
                    child: GestureDetector(
                        child: Text('Forget Password?',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ForgotPassword()),
                            )),
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Text(_authMode == AuthMode.Login
                        ? 'LOGIN'
                        : isNext
                            ? 'SIGN UP'
                            : 'NEXT'),
                    onPressed: () {
                      if (isNext || _authMode == AuthMode.Login) {
                        _submit();
                      } else {
                        if (_formKey.currentState.validate() &&
                            imageFile != null)
                          setState(() {
                            isNext = !isNext;
                          });
                        else {
                          if (imageFile == null)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('No Profile Picture Selected'),
                              backgroundColor: Theme.of(context).errorColor,
                            ));
                          else
                            return;
                        }
                      }
                    },
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0)),
                        textStyle: MaterialStateProperty.all(TextStyle(
                            color: Theme.of(context)
                                .primaryTextTheme
                                .button
                                .color)),
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor)),
                  ),
                TextButton(
                  child: Text(randeredText),
                  onPressed: () {
                    if (isNext) {
                      setState(() {
                        isNext = !isNext;
                      });
                    } else {
                      _switchAuthMode();
                    }
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 4)),
                      textStyle: MaterialStateProperty.all(TextStyle(
                        color: Theme.of(context).primaryColor,
                      )),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    var _email = '';
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Colors.blue,
                  // Colors.orange
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Shop Villa',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 44,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 8.0,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          TextFormField(
                            onSaved: (newEmail) {
                              _email = newEmail;
                            },
                            style: TextStyle(color: Colors.grey),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              icon: Icon(
                                Icons.mail,
                                color: Colors.grey,
                              ),
                              errorStyle: TextStyle(color: Colors.red),
                              labelStyle: TextStyle(color: Colors.grey),
                              hintStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            child: Text('SEND EMAIL'),
                            onPressed: () async {
                              if (_email.contains('@') &&
                                  _email.contains('.')) {
                                await Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .resetPassword(_email);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'An email has just been sent to you, Click the link provided to complete password reset')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Invalid Email Address. Please check your email address and try again')));
                              }
                            },
                          ),
                          TextButton(
                            child: Text('LOGIN'),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => AuthScreen()));
                            },
                            style: ButtonStyle(
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(
                                        horizontal: 30.0, vertical: 4)),
                                textStyle: MaterialStateProperty.all(TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
