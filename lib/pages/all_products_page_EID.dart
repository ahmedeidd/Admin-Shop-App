import 'package:admin_shop_app/data_base/brand_database.dart';
import 'package:admin_shop_app/data_base/category_database.dart';
import 'package:admin_shop_app/data_base/product_database.dart';
import 'package:admin_shop_app/pages/update_products_page_EID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AllPruductsPage extends StatefulWidget
{
  @override
  _AllPruductsPageState createState() => _AllPruductsPageState();
}

class _AllPruductsPageState extends State<AllPruductsPage>
{
  CategoryService _categoryService = CategoryService();
  BrandService _brandService = BrandService();
  String selectedbrand;
  String selectedcat;
  String brandId;
  String CATId;
  Color iconcolor = Colors.blueGrey;
  List<String> selectedproducts = [];
  bool tosearch = false;
  TextStyle textStyle = new TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  Icon Iconsearch = Icon(Icons.search, color: Colors.blueGrey);
  Icon Iconclose = Icon(Icons.close, color: Colors.blueGrey);
  Widget Titletext = Text("All products", style: TextStyle(color: Colors.blueGrey));
  bool loading = false;
  bool allselected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        title: tosearch ? Titlesearch() : Titletext,
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: iconcolor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          IconButton(
              icon: tosearch ? Iconclose : Iconsearch,
              onPressed: () {
                if (tosearch) {
                  setState(() {
                    tosearch = false;
                  });
                } else {
                  setState(() {
                    tosearch = true;
                  });
                }
              }),
          IconButton(
              icon: Icon(
                Icons.delete,
                color: iconcolor,
              ),
              onPressed: () {
                if (selectedproducts.isNotEmpty) {
                  _confirmdelete();
                } else {
                  Fluttertoast.showToast(msg: "select products to delete");
                }
              }),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Card(
              elevation: 1,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Brand",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<List<String>>(
                            future: _getelements("brands", "brand"),
                            builder: (context,snapshot){
                              if(snapshot.hasData){
                                return DropdownButton<String>(
                                  value: selectedbrand,
                                  isExpanded: true,
                                  isDense: true,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  onChanged: changebrand,
                                  hint: Text(
                                    "All",
                                  ),
                                  items: snapshot.data.map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem(
                                      child: Text(value),
                                      value: value,
                                    );
                                  }).toList(),
                                );
                              }
                              else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              } else {
                                return Text("Loading  . . . ");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "Category",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<List<String>>(
                            future: _getelements("categories", "category"),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return DropdownButton<String>(
                                  value: selectedcat,
                                  isExpanded: true,
                                  isDense: true,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  onChanged: changecat,
                                  hint: Text(
                                    "All",
                                  ),
                                  items: snapshot.data
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem(
                                          child: Text(value),
                                          value: value,
                                        );
                                      }).toList(),
                                );
                              } else if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              } else {
                                return Text("Loading  . . . ");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
                      child: ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Name",
                              style: textStyle,
                            ),
                            Text(
                              "Quantity",
                              style: textStyle,
                            ),
                            Text(
                              "Price",
                              style: textStyle,
                            ),
                            Row(
                              children: [
                                Text(
                                  "All",
                                  style: textStyle,
                                ),
                                Checkbox(
                                  value: allselected,
                                  onChanged: _selectall,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading ? CircularProgressIndicator() : FutureBuilder<List<DocumentSnapshot>>(
              future: ProductDatabase().getallproducts(CATId,brandId),
              builder: (context,snapshot){
                if(snapshot.hasData)
                {
                  if(snapshot.data.length == 0)
                  {
                    return Center(child: Padding(
                      padding: const EdgeInsets.all(80.0),
                      child: Text("The list is empty"),
                    ),);
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemBuilder:((context,index){
                        return GestureDetector(
                          onLongPress: (){
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(200, 200, 200, 200),
                              items: menu(index:index,snapshot: snapshot),
                            );
                          },
                          onTap: ()
                          {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EditProduct(snapshot.data[index])));
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListTile(
                                title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:
                                    [
                                      Text(snapshot.data[index]["name"]),
                                      SizedBox(width: 10,),
                                      Text(snapshot.data[index]["quantuty"].toString()),
                                      SizedBox(width: 10,),
                                      Text(snapshot.data[index]["price"].toString() + "  L.E"),
                                      Checkbox(
                                          value: selectedproducts.contains(snapshot.data[index].documentID),
                                          onChanged: (val)
                                          {
                                            changcheck(val, snapshot.data[index].documentID, snapshot);
                                          }),
                                    ],
                                  ),
                              ),
                            ),
                          ),
                        );
                      }),
                      itemCount: snapshot.data.length,
                    ),
                  );
                }else if (snapshot.hasError) {
                  return Center(child: Text("Error    " + snapshot.error.toString()),);
                }
                return Center(child: Center(child:CircularProgressIndicator()));
              },
            ),
          ],
        ),
      ),
    );
  }
  //*******************************************************************
  // start select all
  _selectall(bool selectall)
  {
    if(selectall)
    {
      ProductDatabase().getallproducts(CATId, brandId).then((value) {
        for(int i=0; i < value.length ; i++){
          setState(() {
            selectedproducts.add(value[i].documentID);
            allselected = true;
          });
        }
      });
    }else{
      setState(() {
        selectedproducts.clear();
        allselected = false;
      });
    }
  }
  // end select all
  //********************************************************************
  // start change cat and change brand
  void changecat(String value)
  {
    setState(() {
      loading =true;
      selectedcat = value;
      selectedproducts.clear();
    });

    _categoryService.getCATID(selectedcat).then((id){
      setState(() {
        CATId=id;
        loading=false;
      });
    });

  }
  void changebrand(String value)
  {
    setState(() {
      loading=true;
      selectedbrand = value;
      selectedproducts.clear();
    });
    _brandService.getbrandID(selectedbrand).then((id){
      setState(() {
        brandId=id;
        loading=false;
      });
    });
  }
  // end change cat and change brand
  //*************************************************************
  // start get elements
  Future<List<String>> _getelements(String col_name, String snap_elements) async
  {
    QuerySnapshot querytSnapshot = await Firestore.instance.collection(col_name).getDocuments();
    List<DocumentSnapshot> documentSnapshot = querytSnapshot.documents;
    List<String> list = [];
    for (int i = 0; i < documentSnapshot.length; i++) {
      list.add(documentSnapshot[i][snap_elements]);
    }
    list.add("All");
    return list;
  }
  // end get elements
  //*************************************************************
  // start make menu
  List<PopupMenuEntry> menu({DocumentSnapshot documentSnapshot=null, AsyncSnapshot<List<DocumentSnapshot>> snapshot=null,int index=null})
  {
    List<PopupMenuEntry> list =
    [
      PopupMenuItem(
        value: index == null ? documentSnapshot["name"] : snapshot.data[index]["name"],
        child: Row(
          children: [
            FlatButton.icon(
              icon: Icon(Icons.edit), 
              label: Text("Edit"),
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    EditProduct(index == null ? documentSnapshot:snapshot.data[index]))
                );
              },
            ),
          ],
        ),
      ),
      PopupMenuItem(
        value: index==null?documentSnapshot["name"]:snapshot.data[index]["name"],
        child: Row(
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.delete),
              label: Text("Delete"),
              onPressed: ()
              {
                  selectedproducts.add( index == null ? documentSnapshot.documentID : snapshot.data[index].documentID);
                  _confirmdelete();
              },
            )
          ],
        ),
      )
    ];
    return list;
  }
  // end make menu
  //*************************************************************
  // start build title search
  Widget Titlesearch()
  {
    return TypeAheadField(
      hideOnEmpty: true,
      textFieldConfiguration: TextFieldConfiguration(
        decoration: InputDecoration(
            hintText: "Search "
        ),
        autofocus: false,
      ),
      suggestionsCallback: (pattern) async
      {
        return await ProductDatabase().getSuggestions(pattern);
      },
      itemBuilder: (context, suggestion)
      {
        return ListTile(
          leading: Icon(Icons.shopping_cart),
          title: Text(suggestion['name']),
          subtitle: Text('\$${suggestion['price']}'),
        );
      },
      onSuggestionSelected: (suggestion) {
        showMenu(
            position: RelativeRect.fromLTRB( 200, 20, 200,200),
            context: context,
            items: menu(documentSnapshot: suggestion)
        );
      },
    );
  }
  // end build title search
  //*****************************************************************
  // start confirm delete
  Future<void> _confirmdelete() async
  {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warnning'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Are you want to delete selectesd products'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color: Colors.red,
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.grey[200]),
                          ),
                          onPressed: () {
                            _deleteproduct(selectedproducts);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: Colors.red,
                          child: Text(
                            'Not now',
                            style: TextStyle(color: Colors.grey[200]),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  void _deleteproduct(List<String> products)
  {
    if (products.isNotEmpty)
    {
      setState(() {
        ProductDatabase().deleteproducts(products);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AllPruductsPage()));
      });
    } else {
      Fluttertoast.showToast(msg: "please select product to delete");
    }
  }
  // end confirm delete
  //*******************************************************************
  // start change check
  void changcheck(bool val, String PRODUCT_ID, AsyncSnapshot<List<DocumentSnapshot>> snapshot)
  {
    if (val)
    {
      setState(() {
        selectedproducts.add(PRODUCT_ID);
      });
    } else {
      setState(() {
        selectedproducts.remove(PRODUCT_ID);
      });
    }

    if (snapshot.data.length != selectedproducts.length)
    {
      setState(() {
        allselected = false;
      });
    } else {
      allselected = true;
    }
  }
  // end change check
}
