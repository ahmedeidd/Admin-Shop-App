import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
class CatDialog extends StatefulWidget
{
  @override
  _CatDialogState createState() => _CatDialogState();
}

class _CatDialogState extends State<CatDialog>
{
  File image1;
  GlobalKey<FormState> _categoryFormKey = GlobalKey();
  TextEditingController categoryController = TextEditingController();
  String imgsurl,CAT_IMAGE;
  Firestore _firestore= Firestore.instance;
  bool loading=false;
  @override
  Widget build(BuildContext context)
  {
    return AlertDialog(
      content:loading == true ? Padding(padding: EdgeInsets.all(100),child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Form(
            key: _categoryFormKey,
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
                    controller: categoryController,
                    decoration: InputDecoration(
                        hintText: "add category"
                    ),
                    validator: (value)
                    {
                      if(value.isEmpty)
                      {
                        return 'category cannot be empty';
                      }
                      else
                      {
                        setState(() {
                          CAT_IMAGE=value;
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
            if(_categoryFormKey.currentState.validate())
            {
              saveANDupload();
            }
          },
          child: Text('ADD'),
        ),
        FlatButton(
            onPressed: ()
            {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
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
              padding: const EdgeInsets.fromLTRB(10, 40, 10, 40),
              child: Icon(Icons.add),
            )
                : Container(
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
      image1 = tempimage;
    });
  }
  // end build custom button
  //****************************************************************
  // start save and upload category
  void saveANDupload()
  {
    if (_categoryFormKey.currentState.validate())
    {
      if (image1 != null )
      {
        setState(() {
          loading=true;
        });
        _uploadimages(image1, CAT_IMAGE).then((value)
        {
          setState(() {
            imgsurl = value;
            if(imgsurl.isNotEmpty)
            {
              uploadcat(CAT_IMAGE, imgsurl);
              setState(() {
                loading=false;
              });
              Fluttertoast.showToast(msg: "Category added");
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
      }
      else
      {
        Fluttertoast.showToast(msg: "pick the images of the pictures");
        setState(() {
          loading=false;
        });
      }
    }
  }
  // upload images to fire base storage
  Future<String> _uploadimages(File imgfile1, String catName) async
  {
    String uploadedimages = "";
    var id1 = Uuid();
    final FirebaseStorage storage = FirebaseStorage.instance;
    final String imgname1 = "${catName + id1.v1()}.jpg";
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
  // upload images or category to fire store
  void uploadcat(String cat,String imgsurl)
  {
    var id = Uuid();
    String categoryId = id.v1();
    try{
      _firestore.collection('categories').document(categoryId).setData({'category': cat,"imgurl":imgsurl});
    }catch(e){
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  // end save and upload category
  //*****************************************************************
}
