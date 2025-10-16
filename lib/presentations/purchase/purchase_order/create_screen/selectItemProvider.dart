import 'package:flutter/material.dart';

class SelectedItemsProvider extends ChangeNotifier {
  List<dynamic> _selectedItems = [];

  List<dynamic> get selectedItems => _selectedItems;

  void updateSelectedItems(List<dynamic> items) {
    _selectedItems = items;
    notifyListeners();
  }

  // bool contains(int index) {}

  void remove(int index) {}

  void add(int index) {}

bool contains(int index) {
    return _selectedItems.contains(index);
  }
}
