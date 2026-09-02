import 'dart:convert';

void main() {
  var list = [
    {
      "DocNum": 1,
      "DocumentLines": [
        {"RemainingOpenQuantity": 0.0},
        {"RemainingOpenQuantity": 0}
      ]
    },
    {
      "DocNum": 2,
      "DocumentLines": [
        {"RemainingOpenQuantity": 5},
        {"RemainingOpenQuantity": 0}
      ]
    },
    {
      "DocNum": 3,
      "DocumentLines": [
        {"RemainingOpenQuantity": null}
      ]
    },
    {
      "DocNum": 4,
      "DocumentLines": []
    }
  ];

  var filtered = list.where((doc) {
    var lines = doc['DocumentLines'] as List<dynamic>? ?? [];
    if (lines.isEmpty) return false;
    
    // Check if there is at least one line with RemainingOpenQuantity > 0
    bool hasOpenQty = lines.any((line) {
      double qty = double.tryParse(line['RemainingOpenQuantity']?.toString() ?? '0') ?? 0.0;
      return qty > 0;
    });
    
    return hasOpenQty;
  }).toList();
  
  print(filtered);
}
