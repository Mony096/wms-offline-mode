import 'package:flutter/material.dart';

class ComponentTitle extends StatelessWidget {
  const ComponentTitle({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: [
          // Left line
          Expanded(
            child: Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ),

          // Center text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              label,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.037,
                // fontWeight: FontWeight.w500,
                color: Color.fromARGB(221, 85, 81, 81),
              ),
            ),
          ),

          // Right line
          Expanded(
            child: Divider(
              color: Colors.grey[400],
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
