import 'package:admin_shop_app/data_base/brand_database.dart';
import 'package:admin_shop_app/data_base/category_database.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class OrderDetails extends StatefulWidget
{
  DocumentSnapshot ordersnapshot;
  OrderDetails(DocumentSnapshot ordersnapshot) {
    this.ordersnapshot = ordersnapshot;
  }
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails>
{
  CategoryService _CATDatabase = CategoryService();
  BrandService _BrandDatabase = BrandService();
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ordersnapshot.data["name"]),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children:
        [
          Container(
            height: 300,
            color: Colors.transparent,
            child: GridTile(
              child: Container(
                child: Carousel(
                  images:
                  [
                    Image.network(widget.ordersnapshot["images url"][0]),
                    Image.network(widget.ordersnapshot["images url"][1]),
                    Image.network(widget.ordersnapshot["images url"][2]),
                  ],
                  autoplay: false,
                  boxFit: BoxFit.cover,
                  dotBgColor: Colors.white.withOpacity(.5),
                  dotSize: 4,
                  indicatorBgPadding: .5,
                  showIndicator: false,
                ),
              ),
              footer:Container(
                color: Colors.white70,
                child: ListTile(
                  leading: Text(
                    widget.ordersnapshot["name"],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                  title: Row(
                    children:
                    [
                      Expanded(
                        child: Text(
                          widget.ordersnapshot["price"].toString() + "  L.E",
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Text(
              "Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            subtitle: Text(widget.ordersnapshot["description"]),
          ),
          ListTile(
            title: Row(
              children:
              [
                Text(
                "Color  : ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
                Container(
                height: 15,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(int.parse(widget.ordersnapshot["colors"])),
                ),
              ),
              ],
            ),
          ),
          ListTile(
            leading: Text(
              "Quantity  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text(
              "  ${widget.ordersnapshot["quantuty"]}",
            ),
          ),
          ListTile(
            leading: Text(
              "price  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text("${widget.ordersnapshot["price"]}"),
          ),
          ListTile(
            leading: Text(
              "Total  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text("${double.parse(widget.ordersnapshot["quantuty"].toString()) * double.parse(widget.ordersnapshot["price"])}"),
          ),
          ListTile(
              leading: Text(
                "Category  :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              title: FutureBuilder<String>(
                future: _CATDatabase.getcat(
                  widget.ordersnapshot["category"],
                ),
                builder: (context, snapshot)
                {
                  if (snapshot.hasData)
                  {
                    return ListTile(
                      title: Text(snapshot.data),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error please try later");
                  }
                  return Text("loading ....");
                },
              ),
          ),
          ListTile(
              leading: Text(
                "Brand  :",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              title: FutureBuilder<String>(
                future: _BrandDatabase.getbrand(
                  widget.ordersnapshot["brand"],
                ),
                builder: (context, snapshot)
                {
                  if (snapshot.hasData)
                  {
                    return ListTile(
                      title: Text(snapshot.data),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error please try later");
                  }
                  return Text("loading ....");
                },
              ),
          ),
          ListTile(
            leading: Text(
              "Ordered  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text(widget.ordersnapshot["ordered"]),
          ),
          widget.ordersnapshot["shipped"] != null ? ListTile(
            leading: Text(
              "Shipped  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text(widget.ordersnapshot["shipped"]),
          ) : SizedBox(),
          widget.ordersnapshot["delivered"] != null ? ListTile(
            leading: Text(
              "Delivered  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text(widget.ordersnapshot["delivered"]),
          ) : SizedBox(),
          widget.ordersnapshot["canceled"] != null ? ListTile(
            leading: Text(
              "Canceled  :",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            title: Text(widget.ordersnapshot["canceled"]),
          ) : SizedBox(),
        ],
      ),
    );
  }
}
