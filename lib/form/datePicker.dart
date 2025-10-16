// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class DatePicker extends StatefulWidget {
//   const DatePicker({
//     super.key,
//     this.restorationId,
//     required this.title,
//     this.req,
//     required this.onDateSelected,
//     this.defaultValue,
//   });

//   final String? title;
//   final String? restorationId;
//   final String? req;
//   final ValueChanged<DateTime> onDateSelected;
//   final DateTime? defaultValue;

//   @override
//   State<DatePicker> createState() => DatePickerState();
// }

// class DatePickerState extends State<DatePicker> with RestorationMixin {
//   @override
//   String? get restorationId => widget.restorationId;

//   late final RestorableDateTime _selectedDate =
//       RestorableDateTime(widget.defaultValue ?? DateTime.now());

//   late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
//       RestorableRouteFuture<DateTime?>(
//     onComplete: _selectDate,
//     onPresent: (NavigatorState navigator, Object? arguments) {
//       return navigator.restorablePush(
//         _datePickerRoute,
//         arguments: _selectedDate.value.millisecondsSinceEpoch,
//       );
//     },
//   );

//   @pragma('vm:entry-point')
//   static Route<DateTime> _datePickerRoute(
//     BuildContext context,
//     Object? arguments,
//   ) {
//     return DialogRoute<DateTime>(
//       context: context,
//       builder: (BuildContext context) {
//         return DatePickerDialog(
//           restorationId: 'date_picker_dialog',
//           initialEntryMode: DatePickerEntryMode.calendarOnly,
//           initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
//           firstDate: DateTime(2020),
//           lastDate: DateTime(3000),
//         );
//       },
//     );
//   }

//   @override
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_selectedDate, 'selected_date');
//     registerForRestoration(
//         _restorableDatePickerRouteFuture, 'date_picker_route_future');
//   }

//   String? date;

//   void _selectDate(DateTime? newSelectedDate) {
//     if (newSelectedDate != null) {
//       setState(() {
//         _selectedDate.value = newSelectedDate;

//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text(
//               'Selected: ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}'),
//         ));

//         date = DateFormat('yyyy-MM-dd').format(newSelectedDate);
//         widget.onDateSelected(newSelectedDate);
//       });
//     }
//   }

//   // Method to clear the selected date (set to null)
//   void clearDate() {
//     setState(() {
//       date = null; // Set the date to null
//       _selectedDate.value =
//           widget.defaultValue ?? DateTime.now(); // Reset the selected date
//     });
//   }

//   // Method to update the date based on expDate from parent
//   void updateDate(DateTime? newDate) {
//     setState(() {
//       if (newDate != null) {
//         _selectedDate.value = newDate;
//         date = DateFormat('yyyy-MM-dd').format(newDate);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 50,
//       decoration: const BoxDecoration(
//           color: Color.fromARGB(255, 255, 255, 255),
//           border: Border(
//             bottom: BorderSide(
//               color: Color.fromARGB(255, 215, 213, 213),
//               width: 0.5,
//             ),
//           )),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             "${widget.title}",
//             style: const TextStyle(color: Color.fromARGB(255, 32, 31, 31)),
//           ),
//           Row(
//             children: [
//               Text(
//                 date ?? 'Expiry Date', // Display 'Expiry Date' if date is null
//                 style: const TextStyle(
//                   fontSize: 13,
//                   color: Color.fromARGB(255, 7, 7, 7),
//                 ),
//               ),
//               const SizedBox(
//                 width: 5,
//               ),
//               GestureDetector(
//                 onTap: () {
//                   _restorableDatePickerRouteFuture.present();
//                 },
//                 child: const SizedBox(
//                   width: 30,
//                   height: 30,
//                   child: Icon(
//                     Icons.date_range,
//                     size: 20,
//                     color: Colors.grey,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    required this.title,
    this.restorationId,
    this.req,
    required this.onDateSelected,
    this.defaultValue,
  });

  final String title;
  final String? restorationId;
  final String? req;
  final ValueChanged<DateTime> onDateSelected;
  final DateTime? defaultValue;

  @override
  State<DatePicker> createState() => DatePickerState();
}

class DatePickerState extends State<DatePicker> with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;

  late final RestorableDateTime _selectedDate =
      RestorableDateTime(widget.defaultValue ?? DateTime.now());

  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2020),
          lastDate: DateTime(3000),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  String? date;

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        date = DateFormat('yyyy-MM-dd').format(newSelectedDate);
        widget.onDateSelected(newSelectedDate);
      });
    }
  }

  void clearDate() {
    setState(() {
      date = null;
      _selectedDate.value = widget.defaultValue ?? DateTime.now();
    });
  }

  void updateDate(DateTime? newDate) {
    setState(() {
      if (newDate != null) {
        _selectedDate.value = newDate;
        date = DateFormat('yyyy-MM-dd').format(newDate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _restorableDatePickerRouteFuture.present(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Title on top
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 14.3,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),

          // ✅ Input-like container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                // Left side — empty (no label here)
                // const SizedBox.shrink(),

                // Right side — selected date or placeholder + icon
                Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date ?? 'Expiry Date',
                  style: TextStyle(
                    fontSize: 14,
                    color: date == null
                        ? Colors.grey
                        : const Color.fromARGB(255, 7, 7, 7),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.date_range,
                  size: 19,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
