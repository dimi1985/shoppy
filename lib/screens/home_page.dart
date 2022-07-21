import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoppy/database/sql_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoppy/providers/dark_theme_provider.dart';
import 'package:shoppy/utils/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _items = [];
  List<int> selectedBbox = [];
  double sum = 0.0;
  double totalBudget = 0.0;
  bool _isLoading = true;
  double _budgetLimit = 0.0;
  double progressValue = 0.0;
  double remainSpend = 0.0;
  double multiplier = 0.0;
  int quantity = 1;
  int isChecked = 0;
  bool selectedOne = false;
  bool selectedTwo = false;

//   final themeChange = Provider.of<DarkThemeProvider>(context);
  @override
  void initState() {
    super.initState();
    _refreshItems();

    readDouble('budgetLimit').then((value) {
      setState(() {
        if (value != null) {
          _budgetLimit = value;
        } else {
          saveDouble('budgetLimit', _budgetLimit = 0.0);
        }
      });
    });
  }

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    log(size.width.toString());
    return Consumer<DarkThemeProvider>(builder: (context, value, child) {
      final themeChange =
          Provider.of<DarkThemeProvider>(context, listen: false);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: !themeChange.darkTheme
              ? AppColors.appBarBGLightMode
              : AppColors.appBarBGDarkMode,
          elevation: 0,
          title: Text(
            'Shoppy'.tr(),
            style: TextStyle(
                color: !themeChange.darkTheme
                    ? AppColors.appBarTextsLightMode
                    : AppColors.appBarTextsDarkMode),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 80),
              child: Center(
                //remainSpend.toStringAsFixed(2)
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          'Items to Buy:'.tr() +
                              (' ${_items.length.toString()}'),
                          style: TextStyle(
                            fontSize: 18,
                            color: !themeChange.darkTheme
                                ? AppColors.appBarTextsLightMode
                                : AppColors.appBarTextsDarkMode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: size.width <= 400 ? 20 : 25,
                    color: !themeChange.darkTheme
                        ? AppColors.appBarIconsLightMode
                        : AppColors.appBarIconsDarkMode,
                  ),
                  Text(
                    selectedBbox.length.toString(),
                    style: TextStyle(
                        color: !themeChange.darkTheme
                            ? AppColors.appBarTextsLightMode
                            : AppColors.appBarTextsDarkMode,
                        fontSize: size.width <= 400 ? 20 : 25),
                  ),
                ],
              ),
            ),
            IconButton(
                onPressed: () {
                  _showSettingsForm(themeChange);
                },
                icon: Icon(
                  Icons.settings,
                  color: !themeChange.darkTheme
                      ? AppColors.appBarIconsLightMode
                      : AppColors.appBarIconsDarkMode,
                ))
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
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    multiplier =
                        _items[index]['price'] * _items[index]['quantity'];
                    return Card(
                      color: !themeChange.darkTheme
                          ? AppColors.cardProductBGLightMode
                          : AppColors.cardProductBGDarkMode,
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Item:'.tr() + (' ${item['title']}'),
                                        style: TextStyle(
                                            fontSize:
                                                size.width <= 400 ? 20 : 25,
                                            color: !themeChange.darkTheme
                                                ? AppColors
                                                    .cardProductTextLightMode
                                                : AppColors
                                                    .cardProductTextDarkMode,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Items to Quantity:'.tr() +
                                            (' ${_items[index]['quantity'].toString()}'),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: !themeChange.darkTheme
                                                ? AppColors
                                                    .cardProductTextLightMode
                                                : AppColors
                                                    .cardProductTextDarkMode,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Price:'.tr() +
                                    (' ${multiplier.toStringAsFixed(2)}'),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: !themeChange.darkTheme
                                        ? AppColors.cardProductTextLightMode
                                        : AppColors.cardProductTextDarkMode,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: !themeChange.darkTheme
                                      ? AppColors
                                          .cardProductDeleteColorLightMode
                                      : AppColors
                                          .cardProductDeleteColorDarkMode,
                                ),
                                onPressed: () =>
                                    _deleteItem(_items[index]['id'], index),
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                icon: Icon(
                                  Icons.assignment_outlined,
                                  color: !themeChange.darkTheme
                                      ? AppColors.cardProductEditColorLightMode
                                      : AppColors.cardProductEditColorDarkMode,
                                ),
                                onPressed: () {
                                  if (selectedBbox.contains(index)) {
                                    return;
                                  } else {
                                    _showForm(_items[index]['id'], themeChange);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: Checkbox(
                                activeColor: Colors.red,
                                value: selectedBbox.contains(index),
                                onChanged: (value) {
                                  setState(() {
                                    // remove or add index to _selected_box
                                    if (selectedBbox.contains(index)) {
                                      selectedBbox.remove(index);
                                      multiplier = _items[index]['price'] *
                                          _items[index]['quantity'];
                                      sum -= multiplier;
                                    } else {
                                      selectedBbox.add(index);
                                      multiplier = _items[index]['price'] *
                                          _items[index]['quantity'];

                                      sum += multiplier;
                                    }
                                    if (_budgetLimit == 0.0) {
                                      return;
                                    } else {
                                      progressValue = sum / _budgetLimit;
                                      remainSpend = _budgetLimit - sum;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: !themeChange.darkTheme
                  ? AppColors.appBarBGLightMode
                  : AppColors.appBarBGDarkMode,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(60),
              ),
            ),
            height: 100,
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Total is:'.tr() +
                                (' ${selectedBbox.isEmpty ? '0' : sum.toStringAsFixed(2)}'),
                            style: TextStyle(
                                fontSize: size.width <= 400
                                    ? 18
                                    : sum >= _budgetLimit
                                        ? _budgetLimit == 0.0
                                            ? 25
                                            : 25
                                        : 30,
                                color: sum >= _budgetLimit
                                    ? _budgetLimit == 0.0
                                        ? const Color.fromARGB(
                                            255, 39, 219, 251)
                                        : const Color.fromARGB(
                                            255, 209, 194, 239)
                                    : const Color.fromARGB(255, 251, 39, 49),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (selectedBbox.isNotEmpty)
                          Icon(
                            Icons.euro_symbol,
                            size: size.width <= 400 ? 15 : 25,
                            color: const Color.fromARGB(255, 209, 194, 239),
                          ),
                        SizedBox(
                          width: size.width <= 400 ? 15 : 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                _budgetLimit == 0.0
                                    ? 'Remain:'.tr() + ('-')
                                    : 'Remain:'.tr() +
                                        (' ${remainSpend.toStringAsFixed(2)}'),
                                style: TextStyle(
                                    color: remainSpend < 0
                                        ? Colors.red
                                        : Colors.white,
                                    fontSize: 12),
                              ),
                              if (_budgetLimit != 0.0)
                                Icon(
                                  Icons.euro_symbol,
                                  size: size.width <= 400 ? 15 : 25,
                                  color:
                                      const Color.fromARGB(255, 209, 194, 239),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                            height: 25,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                value: _budgetLimit == 0.0
                                    ? _budgetLimit
                                    : progressValue,
                                backgroundColor:
                                    const Color.fromARGB(255, 247, 247, 247),
                                color: _budgetLimit == 0.0
                                    ? const Color.fromARGB(255, 39, 219, 251)
                                    : const Color.fromARGB(255, 39, 159, 251),
                              ),
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text(
                              _budgetLimit == 0.0
                                  ? 'No Limit'.tr()
                                  : _budgetLimit.toStringAsFixed(2),
                              style: TextStyle(
                                  fontSize: size.width <= 400 ? 15 : 28,
                                  color: _budgetLimit == 0.0
                                      ? const Color.fromARGB(255, 39, 219, 251)
                                      : const Color.fromARGB(255, 233, 59, 7),
                                  fontWeight: FontWeight.bold),
                            ),
                            if (_budgetLimit != 0.0)
                              Icon(
                                Icons.euro_symbol,
                                size: size.width <= 400 ? 15 : 25,
                                color: const Color.fromARGB(255, 209, 194, 239),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showForm(null, themeChange),
          child: const Icon(
            Icons.add,
            size: 30,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      );
    });
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

  void _showForm(int? id, DarkThemeProvider themeChange) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingProduct =
          _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingProduct['title'];
      _priceController.text = existingProduct['price'].toString();
    }
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: !themeChange.darkTheme
          ? AppColors.cardProductBGLightMode
          : AppColors.cardProductBGDarkMode,
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
              Container(
                decoration: BoxDecoration(
                  color: !themeChange.darkTheme
                      ? AppColors.textfieldBGLightMode
                      : AppColors.textfieldBGDarkMode,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Title'.tr(),
                    contentPadding: const EdgeInsets.all(10.0),
                    labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: !themeChange.darkTheme
                      ? AppColors.textfieldBGLightMode
                      : AppColors.textfieldBGDarkMode,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Price'.tr(),
                    contentPadding: const EdgeInsets.all(10.0),
                    labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    height: 38,
                    width: 80,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: AppColors.primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              setState(() {
                                if (quantity <= 1) {
                                  return;
                                } else {
                                  quantity--;

                                  _priceController.text * quantity;
                                }
                              });
                            },
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 16,
                            )),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 3, vertical: 2),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.white),
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              setState(() {
                                if (quantity >= 100) {
                                  return;
                                } else {
                                  quantity++;

                                  _priceController.text * quantity;
                                }
                              });
                            },
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16,
                            )),
                      ],
                    ),
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
                    child: Text(id == null ? 'Create New'.tr() : 'Update'.tr()),
                  )
                ],
              )
            ],
          ),
        );
      })),
    );
  }

  // Insert a new item to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text,
        _priceController.text.isEmpty
            ? 0.0
            : double.parse(_priceController.text),
        quantity,
        sum);
    setState(() {
      _refreshItems();
    });
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        double.parse(_priceController.text), quantity, sum);
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

// This function will be triggered when the settins button is pressed
  // here you can make a bughet limit the will be saved to Shared Preferece
  _showSettingsForm(DarkThemeProvider themeChange) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50, left: 20),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Enter Budget Limit'.tr(),
                                style: const TextStyle(
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
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !themeChange.darkTheme
                                          ? AppColors.textfieldBGLightMode
                                          : AppColors.textfieldBGDarkMode,
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      controller: _priceController,
                                      decoration: InputDecoration(
                                        hintText: 'Budget Limit'.tr(),
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        labelStyle: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 30,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      // Save budget to Shared
                                      getTextAndSave(_priceController.text);
                                    },
                                    child: Text('Save'.tr()),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text('-OR-'.tr()),
                          const SizedBox(
                            height: 20,
                          ),
                          Wrap(
                              // space between chips
                              spacing: 10,
                              // list of chips
                              children: [
                                ActionChip(
                                  label: const Text('5'),
                                  avatar: const Icon(
                                    Icons.euro_symbol,
                                    color: Colors.red,
                                  ),
                                  backgroundColor: Colors.amberAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  onPressed: () {
                                    setState(() {
                                      getTextAndSave(
                                          _priceController.text = 5.toString());
                                    });
                                  },
                                ),
                                ActionChip(
                                  label: const Text('10'),
                                  avatar: const Icon(Icons.euro_symbol),
                                  backgroundColor: Colors.lightBlueAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  onPressed: () {
                                    setState(() {
                                      getTextAndSave(_priceController.text =
                                          10.toString());
                                    });
                                  },
                                ),
                                ActionChip(
                                  label: const Text('20'),
                                  avatar: const Icon(
                                    Icons.euro_symbol,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.pinkAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  onPressed: () {
                                    setState(() {
                                      getTextAndSave(_priceController.text =
                                          20.toString());
                                    });
                                  },
                                ),
                                ActionChip(
                                  label: const Text('30'),
                                  avatar: const Icon(
                                    Icons.euro_symbol,
                                    color: Colors.pink,
                                  ),
                                  backgroundColor: Colors.greenAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  onPressed: () {
                                    setState(() {
                                      getTextAndSave(_priceController.text =
                                          30.toString());
                                    });
                                  },
                                ),
                                ActionChip(
                                  label: Text('No Limit'.tr()),
                                  avatar: const Icon(
                                    Icons.emoji_emotions,
                                    color: Colors.pink,
                                  ),
                                  backgroundColor: Colors.greenAccent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  onPressed: () {
                                    setState(() {
                                      getTextAndSave(
                                          _priceController.text = 0.toString());
                                    });
                                  },
                                )
                              ]),
                          const Divider(
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Empty Database'.tr(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //  'Remain:'.tr() + (' ${remainSpend.toStringAsFixed(2)}'),
                                Text(
                                  'Delete all Items'.tr(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 255, 64, 121)),
                                ),
                                IconButton(
                                  onPressed: _deleteAll,
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Divider(
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Theme Change'.tr(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final themeChange =
                                        Provider.of<DarkThemeProvider>(context,
                                            listen: false);
                                    setState(() {
                                      selectedOne = true;
                                      selectedTwo = false;
                                      themeChange.darkTheme = false;
                                    });
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: selectedOne
                                              ? const Color.fromARGB(
                                                  255, 48, 19, 179)
                                              : const Color.fromARGB(
                                                  26, 48, 19, 179),
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 25),
                                          child: Icon(Icons.light_mode),
                                        ),
                                        Text(
                                          'Light mode'.tr(),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final themeChange =
                                        Provider.of<DarkThemeProvider>(context,
                                            listen: false);
                                    setState(() {
                                      selectedOne = false;
                                      selectedTwo = true;
                                      themeChange.darkTheme = true;
                                    });
                                  },
                                  child: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: selectedTwo
                                              ? const Color.fromARGB(
                                                  255, 48, 19, 179)
                                              : const Color.fromARGB(
                                                  26, 48, 19, 179),
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(right: 25),
                                          child: Icon(Icons.dark_mode),
                                        ),
                                        Text(
                                          'Dark mode'.tr(),
                                          maxLines: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      })),
    );
  }

//save to Shared Preferece
  saveDouble(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble(key, value);
  }

//read from Shared Preferece
  Future readDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    //Return double
    double? doubleValue = prefs.getDouble('budgetLimit');
    setState(() {
      _refreshItems();
    });
    return doubleValue;
  }

//remove Shared Preferece
  removeDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  void getTextAndSave(String textValue) {
    removeDouble('budgetLimit');
    saveDouble(
        'budgetLimit', textValue.isEmpty ? 0.0 : double.parse(textValue));
    // Clear the text fields
    _priceController.text = '';
    readDouble('budgetLimit').then((value) {
      setState(() {
        _budgetLimit = value;
      });
    });

    Navigator.of(context).pop();
  }

  // Delete all items
  void _deleteAll() async {
    await SQLHelper.deleteAll();
    setState(() {
      _refreshItems();
    });
    Navigator.of(context).pop();
  }
}
