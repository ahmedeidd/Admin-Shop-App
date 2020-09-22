import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class UpdateCATDialog extends StatefulWidget
{
  DocumentSnapshot _snapshot;
  UpdateCATDialog(this._snapshot);
  @override
  _UpdateCATDialogState createState() => _UpdateCATDialogState(_snapshot);
}

class _UpdateCATDialogState extends State<UpdateCATDialog>
{
  DocumentSnapshot _snapshot;
  _UpdateCATDialogState(this._snapshot);
  File image1;
  GlobalKey<FormState> _CATFormKey = GlobalKey();
  TextEditingController CATController = TextEditingController();
  String imgsurl,CAT_name;
  Firestore _firestore= Firestore.instance;
  bool loading=false;
  @override
  Widget build(BuildContext context)
  {
    return AlertDialog(
      content: loading == true ? Padding(padding: EdgeInsets.all(100),child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Form(
          key: _CATFormKey,
          child: Column(
            children: [
              Row(
                children: [
                  _Custombutton(1,image1,_snapshot["imgurl"]),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: _snapshot["category"],
                  validator: (value){
                    if(value.isEmpty){
                      return 'brand cannot be empty';
                    } else{
                      setState(() {
                        CAT_name=value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                      hintText: "update category"
                  ),
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
            if(_CATFormKey.currentState.validate())
            {
              saveandupload();
            }
          },
         child: Text('Update'),
        ),
        FlatButton(
          onPressed: ()
          {
            Navigator.pop(context);
          },
          child: Text('CANCEL')
        ),
      ],
    );
  }

  //**************************************************
  // start custom button
  Widget _Custombutton(int imagnum, File image,String imgurl)
  {
    return Container(
      width: 190,
      height: 200,
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: OutlineButton(
          onPressed: () {
            (_pickimage(imagnum));
          },
          child: image == null ? Image.network(imgurl, width: double.infinity, fit: BoxFit.fill,) : Container(
            height: 120,
            child: Image.file(
              image,
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
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
  // end custom button
  //*******************************************************
  // start save and upload
  saveandupload()
  {
    if (_CATFormKey.currentState.validate())
    {
      if (image1 != null )
      {
        setState(() {
          loading = true;
        });
        _uploadimages(image1, CAT_name).then((value){
          setState(() {
            imgsurl = value;
            if(imgsurl.isNotEmpty){
              uploadCATtofirestore(CAT_name, imgsurl);
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "category updated");
              Navigator.of(context).pop();
            }else{
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "something wrong had happened ");
            }
          });
        });
      }
      else if(_snapshot["imgurl"]!=null)
      {
        uploadCATtofirestore(CAT_name, _snapshot["imgurl"]);
        setState(() {
          loading = false;
        });
        Fluttertoast.showToast(msg: "category updated");
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
  Future<String> _uploadimages(File imgfile1, String CATName) async
  {
    String uploadedimages = "";
    var id1 = Uuid();
    final FirebaseStorage storage = FirebaseStorage.instance;
    final String imgname1 = "${CATName + id1.v1()}.jpg";
    StorageUploadTask task1 = storage.ref().child(imgname1).putFile(imgfile1);
    StorageTaskSnapshot snapshot1 = await task1.onComplete.then((value) {
      return value;
    });
    String imgurl1 = await snapshot1.ref.getDownloadURL();
    setState(() {
      uploadedimages=imgurl1;
    });
    return uploadedimages;
  }
  void uploadCATtofirestore(String cat_name, String imgsurl)
  {
    try{
      setState(() {
        _firestore.collection('categories').document(_snapshot.documentID).setData({
          'category': cat_name,
          "imgurl":imgsurl
        });
      });
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  // end save and upload
  //*******************************************************
}

