import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shoppy/database/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _items = [];
  final List<int> selectedBbox = [];
  double sum = 0.0;
  double totalBudget = 0.0;
  int chechBoxIndex = 0;
  bool _isLoading = true;

  double _budgetLimit = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    log(size.width.toString());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Shoppy'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 80),
            child: Center(
              child: Text(
                'Items to Buy: ${_items.length.toString()}',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                _showSettingsForm();
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _refreshItems();
                });
              },
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) => Card(
                  color: const Color.fromARGB(255, 71, 89, 223),
                  margin: const EdgeInsets.all(15),
                  child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _items[index]['title'],
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          Row(
                            children: [
                              Text(
                                _items[index]['price'].toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.euro_symbol),
                            ],
                          )
                        ],
                      ),
                      trailing: SizedBox(
                        width: 150,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                if (selectedBbox.contains(index)) {
                                  return;
                                } else {
                                  _showForm(_items[index]['id']);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteItem(_items[index]['id'], index),
                            ),
                            Checkbox(
                              activeColor: Colors.red,
                              value: selectedBbox.contains(index),
                              onChanged: (value) {
                                setState(() {
                                  // remove or add index to _selected_box
                                  if (selectedBbox.contains(index)) {
                                    selectedBbox.remove(index);
                                    sum -= _items[index]['price'];
                                  } else {
                                    selectedBbox.add(index);
                                    sum += _items[index]['price'];
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      )),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 57, 39, 176),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              )),
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //_showSavedValue
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Total Sum is: ${selectedBbox.isEmpty ? '0' : sum.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 209, 194, 239),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(totalBudget.toString()),
                ],
              ),
              if (selectedBbox.isNotEmpty)
                const Icon(
                  Icons.euro_symbol,
                  color: Color.fromARGB(255, 209, 194, 239),
                ),
              const Icon(Icons.shopping_cart),
              Text(
                selectedBbox.length.toString(),
                style: const TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // This function is used to fetch all data from the database
  void _refreshItems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  }

// This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _priceController.text = existingJournal['price'].toString();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(builder: ((context, setState) {
        return Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: _priceController.text.toString(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                    await _addItem();
                    setState(() {
                      _refreshItems();
                    });
                  }

                  if (id != null) {
                    await _updateItem(id);
                    setState(() {
                      _refreshItems();
                    });
                  }

                  // Clear the text fields
                  _titleController.text = '';
                  _priceController.text = '';

                  //Close Form
                  // ignore: use_build_context_synchronously
                  id == null ? null : Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        );
      })),
    );
  }

  // Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text,
        _priceController.text.isEmpty
            ? 0.0
            : double.parse(_priceController.text),
        sum);
    setState(() {
      _refreshItems();
    });
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, double.parse(_priceController.text), sum);
    setState(() {
      _refreshItems();
    });
  }

  // Delete an item
  void _deleteItem(int id, int index) async {
    if (selectedBbox.contains(index)) {
      return;
    } else {
      await SQLHelper.deleteItem(id);
      setState(() {
        _refreshItems();
      });
    }
  }

  _showSettingsForm() {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(builder: ((context, setState) {
        return Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 50,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Card(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 50, left: 20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Enter Budget Limit',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                      hintText: 'Budget Limit'),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Save budget to Shared
                                    var prefs =
                                        await SharedPreferences.getInstance();

                                    // Clear the text fields
                                    _priceController.text = '';
                                    _budgetLimit =
                                        prefs.getDouble('budgetLimit') ?? 0;
                                    setState(() {
                                      prefs
                                          .setDouble(
                                              'budgetLimit',
                                              double.parse(
                                                  _priceController.text))
                                          .then((bool success) {
                                        if (success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('OK'),
                                            ),
                                          );
                                        }
                                      });
                                    });
                                    //Close Form
                                    // ignore: use_build_context_synchronously
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Save'),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      })),
    );
  }
}

  // Delete an item
  // void _deleteAll() async {
  //   await SQLHelper.deleteAll();
  //   setState(() {
  //     _refreshItems();
  //   });
  // }


