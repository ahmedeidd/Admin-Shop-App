import 'package:cloud_firestore/cloud_firestore.dart';

class UsersDatabase
{
  Firestore _firestore = Firestore.instance;

  Future<List<DocumentSnapshot>> getusers()async{
    QuerySnapshot _querySnapshot =await _firestore.collection("users").getDocuments();
    List<DocumentSnapshot> _docs=_querySnapshot.documents;
    if(_docs==null){return [];}
    return _docs;
  }
}