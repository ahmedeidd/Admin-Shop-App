import 'package:admin_shop_app/data_base/brand_database.dart';
import 'package:admin_shop_app/pages/add_brand_EID.dart';
import 'package:admin_shop_app/pages/update_brand_page_EID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AllBrands extends StatefulWidget
{
  @override
  _AllBrandsState createState() => _AllBrandsState();
}

class _AllBrandsState extends State<AllBrands>
{
  Color iconcolor = Colors.blueGrey;
  List<String> selectedbrands=[];
  bool allselected=false;
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        title: Text("All Brands", style: TextStyle(color: Colors.blueGrey)),
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: iconcolor,),
            onPressed: ()
            {
              Navigator.of(context).pop();
            }),
        actions:
        [
          IconButton(
              icon: Icon(Icons.delete, color: iconcolor,),
              onPressed: ()
              {
                _deletebrands(selectedbrands);
              }
            ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: BrandService().getallBrand(),
        builder: (context,snapshot)
        {
          if(snapshot.hasData)
          {
            return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                itemCount: snapshot.data.length,
                itemBuilder: (context,index) =>InkWell(
                  child: Card(
                    child: GridTile(
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:
                        [
                          Checkbox(
                            value: selectedbrands.contains(snapshot.data[index].documentID),
                            onChanged: (value)
                            {
                              changcheck(value,snapshot.data[index].documentID,snapshot);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: ()async
                            {
                              await _dialogCall(context,"update",snapshot.data[index]);
                            }
                          ),
                        ],
                      ),
                      child: Image.network(snapshot.data[index]["imgurl"]),
                      footer: Container(
                        height: 50,
                        color: Colors.black54,
                        child: Row(
                          children:
                          [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                    child: Text(
                                      snapshot.data[index]["brand"],
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                      ),
                                    ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            );
          }
          else if (snapshot.hasError)
          {
            return Center(
              child: Text("Error    " + snapshot.error.toString()),
            );
          }
          return Center(child: Text("Loading ......."));
        },
      ),
    );
  }
  //*************************************************************
  // srart delete brands
  void _deletebrands(List<String> selectedbrands)
  {
    if(selectedbrands.isNotEmpty)
    {
      setState(() {
        BrandService().deleteBrands(selectedbrands);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AllBrands()));
      });
    }
    else
    {
      Fluttertoast.showToast(msg: "Select at least one brand");
    }
  }
  // end delete brands
  //***************************************************************
  // start chang check
  void changcheck(bool val, String Brand_ID,AsyncSnapshot<List<DocumentSnapshot>> snapshot)
  {
    if (val) {
      setState(() {
        selectedbrands.add(Brand_ID);
      });
    } else {
      setState(() {
        selectedbrands.remove(Brand_ID);
      });
    }
    if(snapshot.data.length!=selectedbrands.length){
      setState(() {
        allselected=false;
      });
    }
    else{
      allselected=true;
    }
  }
  //end chang check
  //****************************************************************
  // start dialog call
  Future<void> _dialogCall(BuildContext context,String type, DocumentSnapshot _snapshot)
  {
    return showDialog(
        context: context,
        builder: (BuildContext context)
        {
          if(type=="update")
          {
            return UpdateBrandDialog(_snapshot);
          }
          return BrandDialog();
        }
     );
  }
  //end dialog call
}
