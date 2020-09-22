import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class BrandDialog extends StatefulWidget
{
  @override
  _BrandDialogState createState() => _BrandDialogState();
}

class _BrandDialogState extends State<BrandDialog>
{
  File image1;
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  TextEditingController brandController = TextEditingController();
  String imgsurl,brand_IMAGE;
  Firestore _firestore= Firestore.instance;
  bool loading=false;
  @override
  Widget build(BuildContext context)
  {
    return AlertDialog(
      content: loading==true?Padding(padding: EdgeInsets.all(100),child: CircularProgressIndicator(),): SingleChildScrollView(
        child: Form(
          key: _brandFormKey,
          child: Column(
            children:
            [
              Row(
                children:
                [
                  _Custombutton(1,image1),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: brandController,
                  decoration: InputDecoration(
                      hintText: "add brand"
                  ),
                  validator: (value)
                  {
                    if(value.isEmpty)
                    {
                      return 'brand cannot be empty';
                    }
                    else{
                      setState(() {
                        brand_IMAGE=value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions:
      [
        FlatButton(
            onPressed: ()
            {
              if(_brandFormKey.currentState.validate()){
                uploadimages();
              }
            },
            child: Text('ADD')
        ),
        FlatButton(
            onPressed: ()
            {
              Navigator.pop(context);
            },
            child: Text('CANCEL'),
        ),
      ],
    );
  }
  //**************************************************************
  // start build custom button
  Widget _Custombutton(int imagnum, File image)
  {
    return Container(
      width: 190,
      height: 200,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: OutlineButton(
            onPressed: ()
            {
              (_pickimage(imagnum));
            },
            child: image == null ? Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 40, 14, 40),
              child: Icon(Icons.add),
            ) : Container(
              height: 120,
              child: Image.file(
                image,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            )
        ),
      ),
    );
  }
  _pickimage(int imgnum) async
  {
    File tempimage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image1=tempimage;
    });
  }
  // end build custom button
  //**************************************************************
  // start uplad images
  void uploadimages()
  {
    if (_brandFormKey.currentState.validate())
    {
      if (image1 != null )
      {
        setState(() {
          loading=true;
        });
        _uploadimages(image1, brand_IMAGE).then((img){
          setState(() {
            imgsurl=img;
            if(imgsurl.isNotEmpty)
            {
              uploadbrand(brand_IMAGE, imgsurl);
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "brand added");
              Navigator.of(context).pop();
            }
            else{
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "something wrong had happened ");
            }
          });
        });
      }else{
        Fluttertoast.showToast(msg: "pick the images from the pictures");
        setState(() {
          loading=false;
        });
      }
    }
  }
  // upload image to fire base storage
  Future<String> _uploadimages(File imgfile1, String brandName) async
  {
    String uploadedimages = "";
    var id1 = Uuid();
    final FirebaseStorage storage = FirebaseStorage.instance;
    final String imgname1 = "${brandName + id1.v1()}.jpg";
    String imgurl1;

    StorageUploadTask task1 = storage.ref().child(imgname1).putFile(imgfile1);
    StorageTaskSnapshot snapshot1 = await task1.onComplete.then((snap1) {
      return snap1;
    });
    imgurl1=await snapshot1.ref.getDownloadURL();
    setState(() {
      uploadedimages=imgurl1;
    });
    return uploadedimages;
  }
  // upload image to fire store
  void uploadbrand(String brand,String imgsurl)
  {
    var id = Uuid();
    String brandId = id.v1();
    try{
      setState(() {
        _firestore.collection('brands').document(brandId).setData({'brand': brand,"imgurl":imgsurl});
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  // end upload images
  //*********************************************************************
}
