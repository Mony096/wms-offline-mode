import 'package:flutter_bloc/flutter_bloc.dart';

class IssueTypeOfflineCubit extends Cubit<List<dynamic>> {
  IssueTypeOfflineCubit() : super(const [
    {'Code': 'SA', 'Name': 'Stock Adjustment'},
    {'Code': 'PE', 'Name': 'Product Exchange'},
    {'Code': 'OS', 'Name': 'Offer Stock'},
    {'Code': 'PM', 'Name': 'Promotion'},
    {'Code': 'WO', 'Name': 'Write off'},
    {'Code': 'TS', 'Name': 'Tester'},
  ]);

  // Methods are kept to avoid breaking changes in UI but are no-ops
  void loadData() {}

  void addData(dynamic item) {}

  void clearData() {}

  void printAllData() {
    print("🟢 Predefined Goods Issue Data: $state");
  }
}
