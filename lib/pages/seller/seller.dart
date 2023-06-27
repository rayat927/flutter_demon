import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:untitled/objects/Category.dart';
import 'package:untitled/objects/Product.dart';
import 'package:untitled/components/TextField.dart';
import 'package:untitled/components/Button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';


class Seller extends StatefulWidget {
  const Seller({super.key});

  @override
  State<Seller> createState() => _SellerState();
}

class _SellerState extends State<Seller> {
  List<Categories> categories = [];

  TextEditingController quantityController = TextEditingController();

  TextEditingController unitSellingPriceController = TextEditingController();

  List<Product> products = [];

  List<String> units = [];

  Categories? selectedCategory;

  String? selectedUnit;

  Product? selectedProduct;

  DateTime selectedDate = DateTime.now();


  @override
  void initState() {
    super.initState();
    getCategory();
    getProduct();
    getUnit();

  }

  void getCategory() async {
    final res = await get(Uri.parse('http://192.168.0.105:5000/category/'));
    print(res.body);
    for(var i in jsonDecode(res.body)){
      setState(() {
        categories.add(Categories(name: i['name'], category_code: i['category_code']));
      });
    }
  }

  void getProduct() async {
    final res = await get(Uri.parse('http://192.168.0.105:5000/product/'));
    print(res.body);
    for(var i in jsonDecode(res.body)){
      setState(() {
        products.add(Product(name: i['name'], product_code: i['product_code']));
      });
    }
  }

  void getUnit() async {
    final res = await get(Uri.parse('http://192.168.0.105:5000/unit/'));
    print(res.body);
    for(var i in jsonDecode(res.body)){
      setState(() {
        units.add(i['name']);
      });
    }
  }

  void submitStoreReport() async{
    final uri = Uri.parse('http://192.168.0.105:5000/selling_report/add');
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {'unit_selling_price': unitSellingPriceController.text, 'quantity': quantityController.text, 'date': selectedDate.toIso8601String(), 'category': selectedCategory!.category_code, 'product': selectedProduct!.product_code, 'unit': selectedUnit};
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    String responseBody = response.body;

    if(statusCode == 200){
      Fluttertoast.showToast(
          msg: "Selling Report added",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }


    print(responseBody);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: DropdownButton<Categories>(
              value: selectedCategory,
              items: categories.map(
                      (category) => DropdownMenuItem<Categories>(
                    value: category,
                    child: Text(category.name, style: TextStyle(fontSize: 24),),
                  )
              ).toList(),
              onChanged: (category) => setState(() {
                selectedCategory = category;
              }),
              hint: Text('Choose Category'),
              isExpanded: true,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: DropdownButton<Product>(
              value: selectedProduct,
              items: products.map(
                      (product) => DropdownMenuItem<Product>(
                    value: product,
                    child: Text(product.name, style: TextStyle(fontSize: 24),),
                  )
              ).toList(),
              onChanged: (product) => setState(() {
                selectedProduct = product;
              }),
              hint: Text('Choose Product'),
              isExpanded: true,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                color: Colors.grey[900],
                height: 70,
                width: 190,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text("Select Date ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      side: BorderSide(width:5, color: Colors.black),
                    ),
                  ),
                ),
              ),

            ),
          ),

          LoginTextField(controller: quantityController, hintText: 'Quantity', obscureText: false, textinputtypephone: true),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: DropdownButton<String>(
              value: selectedUnit,
              items: units.map(
                      (unit) => DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit, style: TextStyle(fontSize: 24),),
                  )
              ).toList(),
              onChanged: (unit) => setState(() {
                selectedUnit = unit;
              }),
              hint: Text('Choose Unit'),
              isExpanded: true,
            ),
          ),

          LoginTextField(controller: unitSellingPriceController, hintText: 'Unit Cost Price', obscureText: false, textinputtypephone: true),

          GestureDetector(
            onTap: submitStoreReport,
            child: Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
