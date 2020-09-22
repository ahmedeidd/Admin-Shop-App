import 'package:firebase_storage/firebase_storage.dart';
import 'dart:core';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ProductDatabase
{
  Firestore _firestore = Firestore.instance;
  // start upload images
  Future<List<String>> uploadimages(File imgfile1, File imgfile2, File imgfile3, String productName) async
  {
    List<String> uploadedimages = [];
    var id1 = Uuid();
    var id2 = Uuid();
    var id3 = Uuid();
    final FirebaseStorage storage = FirebaseStorage.instance;
    final String imgname1 = "${productName + id1.v1()}.jpg";
    final String imgname2 = "${productName + id2.v1()}.jpg";
    final String imgname3 = "${productName + id3.v1()}.jpg";
    String imgurl1;
    String imgurl2;
    String imgurl3;
    StorageUploadTask task1 = storage.ref().child(imgname1).putFile(imgfile1);
    StorageUploadTask task2 = storage.ref().child(imgname2).putFile(imgfile2);
    StorageUploadTask task3 = storage.ref().child(imgname3).putFile(imgfile3);
    StorageTaskSnapshot snapshot1 = await task1.onComplete.then((snap1) {
      return snap1;
    });
    StorageTaskSnapshot snapshot2 = await task2.onComplete.then((snap2) {
      return snap2;
    });
    StorageTaskSnapshot snapshot3 = await task3.onComplete.then((snap3) {
      return snap3;
    });
    imgurl1 = await snapshot1.ref.getDownloadURL();
    imgurl2 = await snapshot2.ref.getDownloadURL();
    imgurl3 = await snapshot3.ref.getDownloadURL();
    uploadedimages = [imgurl1, imgurl2, imgurl3];
    return uploadedimages;
  }
  // end upload images
  //**************************************************************
  // start upload product
  void uploadProduct(
      String name,
      String description,
      String cat,
      String brand,
      String quantity,
      String price,
      List<String> sizes,
      List<String> imgsurl,
      List<String> Colors,
      )
  {
    var id = Uuid();
    String productid = id.v1();
    try {
      _firestore.collection('products').document(productid).setData({
        'name': name,
        "description": description,
        "category": cat,
        "brand": brand,
        "quantuty": quantity,
        "price": price,
        "sizes": sizes,
        "images url": imgsurl,
        "colors": Colors
      });
    }catch (e) {
      Fluttertoast.showToast(msg: e.toString(),toastLength: Toast.LENGTH_LONG);
    }
  }
  // end upload product
  //**************************************************************
 // start update product
  void updateProduct(
      String productid,
      String name,
      String description,
      String cat,
      String brand,
      String quantity,
      String price,
      List<String> sizes,
      List<String> imgsurl,
      List<String> Colors,
      ) {
    try {
      _firestore.collection('products').document(productid).setData({
        'name': name,
        "description": description,
        "category": cat,
        "brand": brand,
        "quantuty": quantity,
        "price": price,
        "sizes": sizes,
        "images url": imgsurl,
        "colors": Colors
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
  // end update product
  //**************************************************************
  // start getAll products
  Future<List<DocumentSnapshot>> getallproducts(String CAT, String BRAND) async
  {
    List<DocumentSnapshot> documentSnapshot;

    if ((CAT != null && CAT != "All") || (BRAND != null && BRAND != "All"))
    {
      if (CAT != "All" && BRAND != "All") {
        QuerySnapshot querytSnapshot = await Firestore.instance
            .collection("products")
            .where("category", isEqualTo: CAT)
            .where("brand", isEqualTo: BRAND)
            .getDocuments();
        documentSnapshot = querytSnapshot.documents;
      } else if (CAT == "All") {
        QuerySnapshot querytSnapshot = await Firestore.instance
            .collection("products")
            .where("brand", isEqualTo: BRAND)
            .getDocuments();
        documentSnapshot = querytSnapshot.documents;
      } else if (BRAND == "All") {
        QuerySnapshot querytSnapshot = await Firestore.instance
            .collection("products")
            .where("category", isEqualTo: CAT)
            .getDocuments();
        documentSnapshot = querytSnapshot.documents;
      }
    }else {
      QuerySnapshot querytSnapshot =
      await Firestore.instance.collection("products").getDocuments();
      documentSnapshot = querytSnapshot.documents;
    }
    return documentSnapshot;
  }
  // end getAll products
  //****************************************************************
  // start get suggestions
  Future<List<DocumentSnapshot>> getSuggestions(String pattern) async
  {
    List<DocumentSnapshot> documentSnapshot;
    QuerySnapshot querytSnapshot = await Firestore.instance.collection("products").where("name",isEqualTo: pattern).getDocuments();
    documentSnapshot = querytSnapshot.documents;
    return documentSnapshot;
  }
  // end get suggestions
  //****************************************************************
  // start delete products
  void deleteproducts(List<String> products) async
  {
    for (String id in products) {
      await Firestore.instance.collection("products").document(id).delete();
    }
  }
  // end delete products
  //****************************************************************
  // start get product count
  Future<int> productCount() async
  {
    int count = 0;
    await getallproducts("All", "All").then((value) => count = value.length);
    return count;
  }
  // end get product count
}