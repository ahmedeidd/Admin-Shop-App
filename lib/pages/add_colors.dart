import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ColorDialog extends StatefulWidget
{
  @override
  _ColorDialogState createState() => _ColorDialogState();
}

class _ColorDialogState extends State<ColorDialog>
{
  List<String> selectedColors=[];
  String pickedColor;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content:  SingleChildScrollView(
        child:Container(
          height: 185,
          width: 250,
          child: MaterialColorPicker(
            circleSize: 70,
            onColorChange: (color){
              pickedColor = color.toString().substring(6,16);
            },
            selectedColor: Colors.grey,
            colors: [Colors.red,Colors.blue,Colors.green,Colors.yellow,Colors.grey,Colors.pink,Colors.teal,Colors.cyan,Colors.orange],
          ),
        )
      ),
      actions: [
        FlatButton(
            onPressed: ()
            {
              if(pickedColor != null){
                selectedColors.add(pickedColor.toString());
                Navigator.pop(context,selectedColors);
              }else{
                Fluttertoast.showToast(msg: "choolse a color please");
              }
            },
            child: Text('ADD')
        ),
        FlatButton(
            onPressed: ()
            {
              Navigator.pop(context,selectedColors);
            },
            child: Text('CANCEL'),
        ),
      ],
    );
  }
}
