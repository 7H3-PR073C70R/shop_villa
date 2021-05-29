import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shop_villa/models/admob.dart';
import 'package:shop_villa/models/constants.dart';
import 'package:shop_villa/models/providers/auth.dart';
import '../models/providers/product.dart';
import 'package:provider/provider.dart';
import '../models/providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit';
  final bool isAdd;
  final String productId;
  EditProductScreen({Key key, @required this.isAdd, this.productId})
      : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _titleFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();

  var _category = '';

  String category = 'Appliances';
  final _formKey = GlobalKey<FormState>();
  List<File> images = [];
  List imageUrls = [];
  var _edittedProduct = Product(
      id: null,
      title: '',
      description: '',
      price: 0,
      images: [],
      category: '',
      country: '',
      address: '');
  var _isInit = true;
  var _isLoading = false;
  var _userId;

  Map<String, dynamic> _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'images': [],
    'category': '',
    'address': '',
    'country': '',
  };

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      if (widget.productId != null) {
        _edittedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(widget.productId);
        _initValue = {
          'title': _edittedProduct.title,
          'description': _edittedProduct.description,
          'price': _edittedProduct.price.toString(),
          'images': _edittedProduct.images,
          'category': _edittedProduct.category,
          'address': _edittedProduct.address,
          'country': _edittedProduct.country
        };

        _category = _initValue['category'];

        category = _category;
        imageUrls = _edittedProduct.images;

        
        _userId = Provider.of<AuthProvider>(context, listen: false).userId;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  initState() {
    super.initState();
    Admob.initialize(testDeviceIds:[AdmobService().getAdmobId()]);
    Admob.requestTrackingAuthorization();
    super.initState();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    _categoryFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 90,
    );
    
    return result;
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState.validate();
    setState(() {
      _isLoading = true;
    });
    if (!isValid) {
      return;
    }
    if (widget.isAdd && images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("At least one image must be added")));
      return;
    }
    _formKey.currentState.save();
    if (_edittedProduct.id != null) {
      if (images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('products')
              .child('$_userId${DateTime.now()}.jpg');
          
          await ref.putFile(images[i]);
          if ((imageUrls.length - 1) >= i) {
            await Provider.of<ProductsProvider>(context, listen: false)
                .removeImage(_edittedProduct.id, i);
          }
          imageUrls.add(await ref.getDownloadURL());
        }
      }
      _edittedProduct = Product(
          id: _edittedProduct.id,
          title: _edittedProduct.title,
          description: _edittedProduct.description,
          price: _edittedProduct.price,
          images: imageUrls,
          category: category,
          address: _edittedProduct.address,
          country: await Provider.of<ProductsProvider>(context).getCountry(),
          isFavorite: _edittedProduct.isFavorite);

      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_edittedProduct.id, _edittedProduct);
    } else {
      try {
        if (images != null)
          for (File image in images) {
            final ref = FirebaseStorage.instance
                .ref()
                .child('products')
                .child('$_userId${DateTime.now()}.jpg');
               
            await ref.putFile(image);
            
            imageUrls.add(await ref.getDownloadURL());
          }
          
        _edittedProduct = Product(
            id: _edittedProduct.id,
            title: _edittedProduct.title,
            description: _edittedProduct.description,
            price: _edittedProduct.price,
            images: imageUrls,
            category: category,
            address: _edittedProduct.address,
            country: '',
            isFavorite: _edittedProduct.isFavorite);
            
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_edittedProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('An error occurred!!!'),
                  content: Text('Something went wrong. Please try again later'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay'))
                  ],
                ));
      }

      setState(() {
        _isLoading = false;
      });
    }
    Navigator.of(context).pop();
  }

  void _pickedImage(File image) {
    if (image != null) {
      setState(() {
        images.add(image);
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.isAdd ? "Add Product" : "Edit Product"),
          actions: [
            GestureDetector(
              child: Icon(
                Icons.save,
                color: Colors.white,
              ),
              onTap: _saveForm,
            )
          ],
        ),
         bottomSheet: AdmobBanner(
           adUnitId: AdmobService().getBannerAddId(), 
           adSize: AdmobBannerSize.FULL_BANNER,
          ),
        body: SingleChildScrollView(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                padding: const EdgeInsets.only(bottom: 55.0),
                child: Container(
                    child: Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    autocorrect: true,
                                    initialValue: _initValue['title'],
                                    decoration:
                                        InputDecoration(labelText: 'Title'),
                                    textInputAction: TextInputAction.next,
                                    focusNode: _titleFocusNode,
                                    // controller: _titleController,

                                    onSaved: (value) {
                                      _edittedProduct = Product(
                                          id: _edittedProduct.id,
                                          title: value,
                                          description:
                                              _edittedProduct.description,
                                          price: _edittedProduct.price,
                                          images: _edittedProduct.images,
                                          category: _edittedProduct.category,
                                          address: _edittedProduct.address,
                                          country: '',
                                          isFavorite: _edittedProduct.isFavorite);
                                    },
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Title cannot be empty';
                                      }
                                      if (value.length < 4) {
                                        return 'Title too short \n Hint: Description should be at least 4 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 18.0),
                                    child: Container(
                                      //height: 100,
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Category',
                                            style: TextStyle(
                                                color: Colors.grey.shade700),
                                          ),
                                          DropdownButton<String>(
                                            focusNode: _categoryFocusNode,
                                            dropdownColor: Colors.white,
                                            value: category,
                                            onChanged: (value) {
                                              setState(() {
                                                category = value;
                                                _category = value;
                                              });
                                            },
                                            items: Constants.category
                                                .map((String item) {
                                              return DropdownMenuItem<String>(
                                                value: item,
                                                child: Row(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      item,
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    autocorrect: true,
                                    initialValue: _initValue['address'],
                                    decoration:
                                        InputDecoration(labelText: 'Address'),
                                    textInputAction: TextInputAction.next,
                                    focusNode: _addressFocusNode,
                                    //controller: _addressController,

                                    onSaved: (value) {
                                      _edittedProduct = Product(
                                          id: _edittedProduct.id,
                                          title: _edittedProduct.title,
                                          description:
                                              _edittedProduct.description,
                                          price: _edittedProduct.price,
                                          images: _edittedProduct.images,
                                          category: _edittedProduct.category,
                                          address: value,
                                          country: '',
                                          isFavorite: _edittedProduct.isFavorite);
                                    },
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Address cannot be empty';
                                      }
                                      if (value.length < 10) {
                                        return 'Address too short \n Hint: Description should be at least 10 characters long. Provide City and Country';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    autocorrect: true,
                                    initialValue: _initValue['price'],
                                    decoration:
                                        InputDecoration(labelText: 'Price'),
                                    textInputAction: TextInputAction.next,
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    focusNode: _priceFocusNode,
                                    //controller: _priceController,

                                    onSaved: (value) {
                                      _edittedProduct = Product(
                                          id: _edittedProduct.id,
                                          title: _edittedProduct.title,
                                          description:
                                              _edittedProduct.description,
                                          price: double.parse(value),
                                          images: _edittedProduct.images,
                                          category: _edittedProduct.category,
                                          address: _edittedProduct.address,
                                          country: '',
                                          isFavorite: _edittedProduct.isFavorite);
                                    },
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Price cannot be empty';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Enter a valid price';
                                      }
                                      if (double.parse(value) <= 0) {
                                        return 'Please enter a number greater than 0 for the price';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    autocorrect: true,
                                    maxLines: 3,
                                    initialValue: _initValue['description'],
                                    decoration:
                                        InputDecoration(labelText: 'Description'),
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.multiline,
                                    focusNode: _descriptionFocusNode,
                                    //controller: _descriptionController,
                                    // onChanged: (value) {
                                    //   setState(() {
                                    //     _description = value;
                                    //   });
                                    // },
                                    onSaved: (value) {
                                      _edittedProduct = Product(
                                          id: _edittedProduct.id,
                                          title: _edittedProduct.title,
                                          description: value,
                                          price: _edittedProduct.price,
                                          images: _edittedProduct.images,
                                          category: _edittedProduct.category,
                                          address: _edittedProduct.address,
                                          country: '',
                                          isFavorite: _edittedProduct.isFavorite);
                                    },
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Description cannot be empty';
                                      }
                                      if (value.length < 10) {
                                        return 'Description too short \n Hint: Description should be at least 10 characters long';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ImageGrid(
                                    pickedImage: _pickedImage,
                                    isLoadPrevious: widget.isAdd,
                                    imageUrl:
                                        imageUrls.isEmpty ? '' : imageUrls[0]),
                                ImageGrid(
                                    pickedImage: _pickedImage,
                                    isLoadPrevious: widget.isAdd,
                                    imageUrl: imageUrls.isEmpty
                                        ? ''
                                        : imageUrls.length > 1
                                            ? imageUrls[1]
                                            : '')
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ImageGrid(
                                  pickedImage: _pickedImage,
                                  isLoadPrevious: widget.isAdd,
                                  imageUrl: imageUrls.isEmpty
                                      ? ''
                                      : imageUrls.length > 2
                                          ? imageUrls[2]
                                          : '',
                                ),
                                ImageGrid(
                                  pickedImage: _pickedImage,
                                  isLoadPrevious: widget.isAdd,
                                  imageUrl: imageUrls.isEmpty
                                      ? ''
                                      : imageUrls.length > 3
                                          ? imageUrls[3]
                                          : '',
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  )),
              ),
        ));
  }
}

class ImageGrid extends StatefulWidget {
  final Function(File image) pickedImage;
  final String imageUrl;
  final bool isLoadPrevious;
  ImageGrid({
    Key key,
    @required this.pickedImage,
    @required this.imageUrl,
    this.isLoadPrevious,
  }) : super(key: key);

  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  bool isSelected = false;
  File image;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
                border: Border.all(
                    style: BorderStyle.solid,
                    color: Theme.of(context).accentColor,
                    width: 3.0),
                borderRadius: BorderRadius.circular(10)),
            child: !isSelected && widget.imageUrl != ''
                ? Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                  )
                : image != null
                    ? Image.file(
                        image,
                        fit: BoxFit.cover,
                      )
                    : Container()),
        GestureDetector(
          child: Icon(
            Icons.photo,
            size: 60,
            color: Theme.of(context).primaryColor,
          ),
          onTap: () async {
            var cameraStatus = await Permission.camera.status;
            var medialStatus = await Permission.mediaLibrary.status;
            if (cameraStatus.isGranted || medialStatus.isGranted) {
              try {
                var pickImage = ImagePicker();
                PickedFile picked =
                    await pickImage.getImage(source: ImageSource.gallery);
                File img = File(picked.path);
                widget.pickedImage(img);
                setState(() {
                  image = img;
                  isSelected = true;
                });
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
          },
        )
      ],
    );
  }
}
