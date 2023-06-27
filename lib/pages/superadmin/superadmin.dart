import 'package:flutter/material.dart';
import 'package:untitled/components/TextField.dart';
import 'package:untitled/components/Button.dart';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:untitled/objects/Product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SuperAdmin extends StatefulWidget {
  const SuperAdmin({super.key});

  @override
  State<SuperAdmin> createState() => _SuperAdminState();
}

class _SuperAdminState extends State<SuperAdmin> {
  late TextEditingController nameController;
  late TextEditingController productCodeController;

  late TextEditingController categoryNameController;
  late TextEditingController categoryCodeController;

  Map<String, dynamic> user = {};

  List<Product> products = [
    Product(name: 'test', product_code:'001'),

  ];

  @override
  void initState(){
    super.initState();
        nameController = TextEditingController();
        productCodeController = TextEditingController();
        categoryNameController = TextEditingController();
        categoryCodeController = TextEditingController();
        getProduct();
        print(products[0].name);
  }

  @override
  void dispose() {
    nameController.dispose();
    productCodeController.dispose();

    super.dispose();
  }

  getProduct() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
     String userMap = prefs.getString('user') ?? '{}';
     user = jsonDecode(userMap);
     print(user);
    });
    final res = await get(Uri.parse('http://192.168.0.102:5000/product/'));
    // print(res.body);
    for(var i in jsonDecode(res.body)){
        setState(() {
          products.add(Product(name: i['name'], product_code: i['product_code']));
        });
    }



  }


   addProduct() async {
    print(nameController.text);
    print(productCodeController.text);

    // var res = await http.post(
    //   Uri.parse('http://192.168.0.102:5000/product/add'),
    //   body: jsonEncode(<String, String>{
    //     'name': nameController.text,
    //     'product_code': productCodeController.text,
    //   }),
    // );
    //
    // var data = jsonDecode(res.body);
    //
    // print(data);

    final uri = Uri.parse('http://192.168.0.105:5000/product/add');
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {'name': nameController.text, 'product_code': productCodeController.text};
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


  print(responseBody);

  Navigator.of(context).pop();



  }

  addCategory() async {
    print(categoryNameController.text);
    print(categoryCodeController.text);

    // var res = await http.post(
    //   Uri.parse('http://192.168.0.102:5000/product/add'),
    //   body: jsonEncode(<String, String>{
    //     'name': nameController.text,
    //     'product_code': productCodeController.text,
    //   }),
    // );
    //
    // var data = jsonDecode(res.body);
    //
    // print(data);

    final uri = Uri.parse('http://192.168.0.102:5000/category/add');
    final headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {'name': categoryNameController.text, 'product_code': categoryCodeController.text};
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


    print(responseBody);

    Navigator.of(context).pop();



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(user['username'] ?? 'Admin'),
        ),
        body: Column(
          children: [
            Container(
                padding: EdgeInsets.all(32),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  child: Text('Add Product'),
                  onPressed: () {
                    openPopup();
                  },
                )
            ),

            SizedBox(height: 20,),

            Container(
                padding: EdgeInsets.all(32),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  child: Text('Add Category'),
                  onPressed: () {
                    openCategoryPopup();
                  },
                )
            ),


            SizedBox(height: 50,),
            Table(
              border: TableBorder.all(color: Colors.black),
              columnWidths: {
                0: FixedColumnWidth(100.0),
                1: FixedColumnWidth(100.0)
              },
              children: [
                TableRow(
                  children: [
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          'Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(
                          'Product Code',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                    )
                  ]
                ),
                for (var product in products)
                  TableRow(children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(product.name)
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: Text(product.product_code)
                    )
                  ])
              ],
            ),
          ],
        )
    );


  }
  Future openPopup() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Product'),
      content: Column(
        children :  [

        const SizedBox(height: 50,),

        LoginTextField(
          controller: nameController,
          hintText: 'name',
          obscureText: false,
          textinputtypephone: false,
        ),

        const SizedBox(height: 10),

        // password textfield
        LoginTextField(
          controller: productCodeController,
          hintText: 'product code',
          obscureText: false,
          textinputtypephone: false,
        ),
        // const SizedBox(height: 25),

        // sign in button

      ]
    ),
      actions: [
        TextButton(
          child: Text('Submit'),
          onPressed: addProduct
        )
      ],
    ),
  );

  Future openCategoryPopup() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add Product'),
      content: Column(
          children :  [

            const SizedBox(height: 50,),

            LoginTextField(
              controller: nameController,
              hintText: 'name',
              obscureText: false,
              textinputtypephone: false,
            ),

            const SizedBox(height: 10),

            // password textfield
            LoginTextField(
              controller: productCodeController,
              hintText: 'product code',
              obscureText: false,
              textinputtypephone: false,
            ),
            // const SizedBox(height: 25),

            // sign in button

          ]
      ),
      actions: [
        TextButton(
            child: Text('Submit'),
            onPressed: addProduct
        )
      ],
    ),
  );
}

