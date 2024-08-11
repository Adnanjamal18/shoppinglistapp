import 'dart:convert';

import 'package:grocery_store/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:grocery_store/data/categories.dart';
import 'package:grocery_store/models/category.dart';


class NewItem extends StatefulWidget{
  const NewItem({super.key});
@override
  State<StatefulWidget> createState() {
    return _NewItemState();
    
  }
}

class _NewItemState extends State <NewItem>{
  final _formkey =GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
   if( _formkey.currentState!.validate())/*validate will rach out to all form fields widgets  inside of the form*/{
    _formkey.currentState!.save(); //we enter here only if value name ot numter is validated by validate method
    setState(() {
      _isSending= true ;
    });
    final url = Uri.https('flutter-prep-b83b1-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.post(
      url,
      headers:{
    'Content-Type':'appication/json',
    },
    body: json.encode({
      'category': _selectedCategory.title,
       'name': _enteredName,
        'quantity': _enteredQuantity,
    }
    )
    );
    final Map <String,dynamic> resData = json.decode(response.body);
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).pop(GroceryItem(category: _selectedCategory, id: resData['name'], name: _enteredName, quantity: _enteredQuantity),);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Item '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
      child: Form(
        key: _formkey ,
        child: 
        Column(children: [
     TextFormField(
      maxLength: 50,
      decoration: const InputDecoration(
        label: Text('Name'),
      ),
      validator: (value)/*Alert dialod alternative in form*/ {
        if (value == null || value.isEmpty || value.trim().length<=1||value.trim().length >50) {
        return 'Must be Between 1 and 50 characters';
        }
        return null;
      },
     onSaved: (value) {
       _enteredName = value!;
     },
     ),
     Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration:const InputDecoration(
              label: Text('Quantity'),
            ),
            keyboardType: TextInputType.number,
            initialValue: _enteredQuantity.toString(),
            validator: (value) {
        if ( value == null ||
         value.isEmpty ||
          int.tryParse(value)==null||
          int.tryParse(value)!<=0) {
        return 'Must be av valid , positive number';
        }
        return null;
      },
       onSaved: (value) {
       _enteredQuantity = int.parse(value!);
     },
          ),
        ),
        const SizedBox(width: 8,),
        Expanded(
          child: DropdownButtonFormField(
            value: _selectedCategory,
            items: [
            for(final category in categories.entries)
            DropdownMenuItem(
              value: category.value,
              child:Row(
                children: [ 
                  Container(
                width: 16,
                height: 16,
                color: category.value.color,),
               const SizedBox(width: 6,),
              Text(category.value.title
              ),],
            ),
            )
          ], onChanged: (value){
            setState(() {
              _selectedCategory=value!;
            });
            }),
        ),
      ],),
      Row(children: [
        
        TextButton(onPressed: _isSending ? null : (){
          _formkey.currentState!.reset();
        },
         child:_isSending ?const SizedBox(height: 16,width: 16,child:  CircularProgressIndicator()):const Text('reset')),

        ElevatedButton(onPressed:_isSending? null: _saveItem,
         child:_isSending ?const    SizedBox(height: 16,width: 16,child:  CircularProgressIndicator()) : const Text( 'add item'))
        ],)
        ],)
      
      ),
      ),
    );
}
}