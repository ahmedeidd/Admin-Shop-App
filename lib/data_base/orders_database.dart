import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersDatabase
{
  String dateAndtime;
  Firestore _firestore = Firestore.instance;
  // start get orders
  Future<List<DocumentSnapshot>> getorders(String orderCase) async
  {
    List<DocumentSnapshot> orders = [];
    QuerySnapshot querySnapshot =
    await _firestore.collection('orders').getDocuments();
    orders = querySnapshot.documents;
    switch (orderCase) {
      case "all":
        {
          return orders;
        }
        break;
      case "ordered":
        {
          List<DocumentSnapshot> orderedlist = [];
          orders.forEach((doc) {
            if (doc.data["ordered"] != null && doc.data["shipped"] == null && doc.data["canceled"] == null &&
                doc.data["delivered"] == null) {
              orderedlist.add(doc);
            }
          });
          return orderedlist;
        }
        break;
      case "proccess":
        {
          List<DocumentSnapshot> shippedlist = [];
          orders.forEach((doc) {
            if ((doc.data["shipped"] != null ||doc.data["rejected"] != null) && doc.data["delivered"] == null) {
              shippedlist.add(doc);
            }
          });
          return shippedlist;
        }
        break;
      case "delivered":
        {
          List<DocumentSnapshot> deliveredlist = [];
          orders.forEach((doc) {
            if (doc.data["delivered"] != null) {
              deliveredlist.add(doc);
            }
          });
          return deliveredlist;
        }
        break;
      case "canceled":
        {
          List<DocumentSnapshot> canceledlist = [];
          orders.forEach((doc) {
            if (doc.data["canceled"] != null) {
              canceledlist.add(doc);
            }
          });
          return canceledlist;
        }
        break;
      default:
        return [];
    }
  }
  // end get orders
  //************************************************
  // start get time
  void _getTime()
  {
    DateTime now = DateTime.now();
    dateAndtime = DateFormat('EEE d MMM').format(now);
  }
  // end get time
  //************************************************
  // start ship product
  Future<void> ship_product(String order_id) async
  {
    _getTime();

    await  _firestore
        .collection("orders")
        .document(order_id)
        .updateData({"shipped": dateAndtime});
  }
  // end ship product
  //************************************************
  // start reject product
  Future<void> reject_product(String order_id) async
  {
    _getTime();
    await  _firestore
        .collection("orders")
        .document(order_id)
        .updateData({"regected": dateAndtime});
  }
  // end reject product
  //************************************************
  // start delever product
  Future<void> delever_product(String order_id) async
  {
    _getTime();
    await _firestore
        .collection("orders")
        .document(order_id)
        .updateData({"delivered": dateAndtime});
  }
  //************************************************
  // end delever product
}