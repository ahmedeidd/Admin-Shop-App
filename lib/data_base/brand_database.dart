import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BrandService
{
  Firestore _firestore = Firestore.instance;

  // start create brand
  void createBrand(String name)
  {
    var id = Uuid();
    String brandId = id.v1();

    _firestore.collection('brands').document(brandId).setData({'brand': name});
  }
  // end create brand
  //********************************************************
  // start get all brand
  Future<List<DocumentSnapshot>> getallBrand() async
  {
    List<DocumentSnapshot> documentSnapshot;
    QuerySnapshot querytSnapshot =
    await Firestore.instance.collection("brands").getDocuments();
    documentSnapshot = querytSnapshot.documents;
    return documentSnapshot;
  }
  // end get all brand
  //********************************************************
  // start delete brand
  void deleteBrands(List<String> brandsid)async
  {
    for(String id in brandsid){
      await Firestore.instance.collection("brands").document(id).delete();
    }
  }
  // end delete brand
  //********************************************************
  // start get brand id
  Future<String > getbrandID(String brandname)async
  {
    if(brandname=="All"){
      return "All";
    }
    else{
      String id="";
      QuerySnapshot querytSnapshot = await _firestore.collection('brands').where("brand",isEqualTo:brandname ).getDocuments();
      DocumentSnapshot snapshot=querytSnapshot.documents[0];
      id=snapshot.documentID;
      return id;
    }
  }
  // end get brand id
  //********************************************************
  // start get brand
  Future<String > getbrand(String brandID)async
  {
    String brand="";
    DocumentSnapshot snapshot = await _firestore.collection('brands').document(brandID).get();
    brand=snapshot["brand"];
    return brand;
  }
  // end get brand
}