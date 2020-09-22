import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CategoryService
{
  Firestore _firestore = Firestore.instance;
  // start create category
  void createCategory(String name)
  {
    var id = Uuid();
    String categoryId = id.v1();

    _firestore.collection('categories').document(categoryId).setData({'category': name});
  }
  // end create category
  //********************************************************
  // start get all category
  Future<List<DocumentSnapshot>> getallCategories() async
  {
    List<DocumentSnapshot> documentSnapshot;
    QuerySnapshot querytSnapshot =
    await Firestore.instance.collection("categories").getDocuments();
    documentSnapshot = querytSnapshot.documents;
    return documentSnapshot;
  }
  // end get all category
  //********************************************************
  // start delete catgorys
  void deleteCATs(List<String> categoriesid)async
  {
    for(String id in categoriesid){    await Firestore.instance.collection("categories").document(id).delete();
    }
  }
  // end delete catgorys
  //********************************************************
  // start get cat id
  Future<String > getCATID(String catname)async
  {
    if(catname=="All"){
      return "All";
    }else{
      String id="";
      QuerySnapshot querytSnapshot = await _firestore.collection('categories').where("category",isEqualTo:catname ).getDocuments();
      DocumentSnapshot snapshot=querytSnapshot.documents[0];
      id=snapshot.documentID;
      return id;
    }
  }
  // end get cat id
  //********************************************************
  // start get cat
  Future<String > getcat(String CATID)async
  {
    String CAT="";
    DocumentSnapshot snapshot = await _firestore.collection('categories').document(CATID).get();
    CAT=snapshot["category"];
    return CAT;
  }
}