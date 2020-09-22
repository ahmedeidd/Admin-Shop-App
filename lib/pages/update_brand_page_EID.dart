import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class UpdateBrandDialog extends StatefulWidget
{
  DocumentSnapshot _snapshot;
  UpdateBrandDialog(this._snapshot);
  @override
  _UpdateBrandDialogState createState() => _UpdateBrandDialogState(_snapshot);
}

class _UpdateBrandDialogState extends State<UpdateBrandDialog>
{
  DocumentSnapshot _snapshot;
  _UpdateBrandDialogState(this._snapshot);
  File image1;
  GlobalKey<FormState> _brandFormKey = GlobalKey();
  TextEditingController brandController = TextEditingController();
  String imgsurl,brand_name;
  Firestore _firestore= Firestore.instance;
  bool loading=false;
  @override
  Widget build(BuildContext context)
  {
    return AlertDialog(
      content: loading == true ? Padding(padding: EdgeInsets.all(100),child: CircularProgressIndicator(),) : SingleChildScrollView(
          child: Form(
            key: _brandFormKey,
            child: Column(
              children:
              [
                Row(
                  children: [
                    _Custombutton(1,image1,_snapshot["imgurl"]),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: "update brand"
                    ),
                    initialValue: _snapshot["brand"],
                    validator: (value)
                    {
                      if(value.isEmpty){
                        return 'brand cannot be empty';
                      }
                      else{
                        setState(() {
                          brand_name=value;
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
              saveANDupload();
            }
          },
          child: Text('Update'),
        ),
        FlatButton(
            onPressed: (){Navigator.pop(context);},
            child: Text('Cancel'),
        ),
      ],
    );
  }
  //******************************************************************
  // start custom button
  Widget _Custombutton(int imagnum, File image,String imgurl)
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
            child: image == null ? Image.network(
              imgurl,
              width: double.infinity,
              fit: BoxFit.fill,
            ) : Container(
              height: 120,
              child: Image.file(
                image,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            )),
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
  // end custom button
  //********************************************************************
  // start save and update
  void saveANDupload()
  {
    if (_brandFormKey.currentState.validate())
    {
      if (image1 != null )
      {
        setState(() {
          loading = true;
        });
        _uploadimages(image1, brand_name).then((img)
        {
          setState(() {
            imgsurl = img;
            if(imgsurl.isNotEmpty)
            {
              uploadbrand(brand_name, imgsurl);
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "brand updated");
              Navigator.of(context).pop();
            }
            else {
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "something wrong had happened ");
            }
          });
        });
      }
      else if(_snapshot["imgurl"] != null)
      {
        uploadbrand(brand_name, _snapshot["imgurl"]);
        setState(() {
          loading=false;
        });
        Fluttertoast.showToast(msg: "brand updated");
        Navigator.of(context).pop();
      }
      else
      {
        Fluttertoast.showToast(msg: "pick the images from the pictures");
        setState(() {
          loading=false;
        });
      }
    }
  }
  // upload images of brands to fire storage
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
  // upload brand to fire store
  void uploadbrand(String brand,String imgsurl)
  {
    try{
      setState(() {
        _firestore.collection('brands').document(_snapshot.documentID).setData({'brand': brand,"imgurl":imgsurl});
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  // end save and update
  //*********************************************************************
}
