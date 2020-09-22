import 'package:admin_shop_app/data_base/category_database.dart';
import 'package:admin_shop_app/data_base/orders_database.dart';
import 'package:admin_shop_app/data_base/product_database.dart';
import 'package:admin_shop_app/data_base/users_database.dart';
import 'package:admin_shop_app/pages/add_brand_EID.dart';
import 'package:admin_shop_app/pages/add_cat_EID.dart';
import 'package:admin_shop_app/pages/add_products_page_EID.dart';
import 'package:admin_shop_app/pages/all_brands_page_EID.dart';
import 'package:admin_shop_app/pages/all_cats_page_EID.dart';
import 'package:admin_shop_app/pages/all_products_page_EID.dart';
import 'package:admin_shop_app/pages/order_page_EID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Page { dashboard, manage }
class Admin extends StatefulWidget
{
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin>
{
  Page _selectedPage = Page.dashboard;
  MaterialColor active = Colors.orange;
  MaterialColor notActive = Colors.grey;
  TextEditingController categoryController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  ProductDatabase _productDatabase = ProductDatabase();
  UsersDatabase _usersDatabase = UsersDatabase();
  CategoryService _categoryService = CategoryService();
  OrdersDatabase _ordersDatabase = OrdersDatabase();
  @override
  void initState()
  {
    super.initState();
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions:
        [
          FlatButton.icon(
            autofocus: true,
            onPressed: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
              setState(()
              {
                _selectedPage = Page.dashboard;
              });
            },
            icon: Icon(
              Icons.dashboard,
              color: _selectedPage == Page.dashboard ? active : notActive,
            ),
            label: Text("Dashboard"),
          ),
          SizedBox(width: 10,),
          FlatButton.icon(
            onPressed: ()
            {
              setState(() => _selectedPage = Page.manage);
            },
            icon: Icon(
              Icons.sort,
              color: _selectedPage == Page.manage ? active : notActive,
            ),
            label: Text('Manage'),
          ),
          SizedBox(width: 40,),
        ],
      ),
      body: _loadScreen(),
    );
  }
  //*************************************************
  // start build load screen
  Widget _loadScreen()
  {
    switch(_selectedPage)
    {
      case Page.dashboard:
        return Column(
          children:
          [
            Center(
              child: Text(
                'EID Company',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 39,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                children:
                [
                  FutureBuilder<List<DocumentSnapshot>>(
                      future: _usersDatabase.getusers(),
                      builder: (context, snapshot) {
                        return Card(
                          elevation: 5,
                          child: ListTile(
                              title: FlatButton.icon(
                                  onPressed: null,
                                  icon: Icon(Icons.people_outline),
                                  label: Text("Users",overflow: TextOverflow.ellipsis,),
                              ),
                              subtitle: Text(
                                snapshot.hasData ? "${snapshot.data.length}" : snapshot.hasError ? "Error" : "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              ),
                          ),
                        );
                      }),
                  FutureBuilder<List<DocumentSnapshot>>(
                      future: _categoryService.getallCategories(),
                      builder: (context, snapshot) {
                        return Card(
                          elevation: 5,
                          child: ListTile(
                              title: FlatButton.icon(
                                  onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context) => AllCATs()));},
                                  icon: Icon(Icons.category),
                                  label: Text(
                                    "CATs",
                                    overflow: TextOverflow.ellipsis,
                                  )
                              ),
                              subtitle: Text(
                                snapshot.hasData ? "${snapshot.data.length}" : snapshot.hasError ? "Error" : "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              )),
                        );
                      }),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _productDatabase.getallproducts("All", "All"),
                    builder: (context,snapshot){
                      return Card(
                        elevation: 5,
                        child: ListTile(
                          title: FlatButton.icon(
                              onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (context) => AllPruductsPage()));},
                              icon: Icon(Icons.track_changes),
                              label: Text("Producs")
                          ),
                          subtitle: Text(
                              snapshot.hasData ? "${snapshot.data.length}" : snapshot.hasError ? "Error" : "0",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: active, fontSize: 60.0),
                            )
                        ),
                      );
                    },
                  ),
                  FutureBuilder<List<DocumentSnapshot>>(
                      future: _ordersDatabase.getorders("all"),
                      builder: (context, snapshot)
                      {
                        return Card(
                          elevation: 5,
                          child: ListTile(
                              title: FlatButton.icon(
                                  onPressed: ()
                                  {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrdersPage()));
                                  },
                                  icon: Icon(Icons.shopping_cart),
                                  label: Text("Orders")),
                              subtitle: Text(
                                snapshot.hasData ? "${snapshot.data.length}" : snapshot.hasError ? "Error" : "0",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: active, fontSize: 60.0),
                              ),
                          ),
                        );
                      }),
                ],
              ),
            ),
          ],
        );
        break;
      case Page.manage:
        return ListView(
          children:
          [
            ListTile(
              leading: Icon(Icons.add),
              title: Text("Add product"),
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AddProduct()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.change_history),
              title: Text("Products list"),
              onTap: ()
              {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AllPruductsPage()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text("Add category"),
              onTap: () async {
                await _dialogCall(context, "cat");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.category),
              title: Text("Category list"),
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllCATs()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text("Add brand"),
              onTap: () async
              {
                await _dialogCall(context, "brand");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.library_books),
              title: Text("brand list"),
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllBrands()));
              },
            ),
            Divider(),
          ],
        );
      default:
        return Container();
    }
  }
  // end build load screen
  //*********************************************************
  // start dialog call
  Future<void> _dialogCall(BuildContext context, String type)
  {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (type == "cat")
        {
          return CatDialog();
        }
        else if (type == "brand")
        {
          return BrandDialog();
        }
        else
        {
          return SizedBox();
        }
      },
    );
  }
  // end dialog call
}
