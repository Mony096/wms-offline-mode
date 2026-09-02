import 'package:flutter_bloc/flutter_bloc.dart';

class ReceiptTypeOfflineCubit extends Cubit<List<dynamic>> {
  ReceiptTypeOfflineCubit() : super(const [
    {'Code': 'SA', 'Name': 'Stock Adjustment'},
    {'Code': 'RB', 'Name': 'Receipt from Borrowing Stock'},
    {'Code': 'PE', 'Name': 'Product Exchange'},
    {'Code': 'PM', 'Name': 'Promotion'},
  ]);

  // Methods are kept to avoid breaking changes in UI but are no-ops
  void loadData() {}

  void addData(dynamic item) {}

  void clearData() {}

  void printAllData() {
    print("🟢 Predefined Goods Receipt Data: $state");
  }
}
