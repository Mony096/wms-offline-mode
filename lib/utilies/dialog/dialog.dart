import 'package:flutter/material.dart';
import 'package:wms_mobile/constant/style.dart';

import '../../component/loading_circle.dart';

class MaterialDialog {
  static Future<void> success(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onOk,
  }) async {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Header Row (icon + title)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title ?? 'Success',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // 💬 Body
                    if (body != null && body.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          body,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 🔘 OK Button (aligned right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_COLOR,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 10,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (onOk != null) onOk();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> warning(
    BuildContext context, {
    String? title,
    String? body,
    Function()? onConfirm,
    Function()? onCancel,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
  }) async {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 5),

                        // Title
                        Text(
                          title ?? 'Warning',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),

                    // Body
                    if (body != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        body,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: width * 0.038,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          onPressed: () {
                            if (onCancel != null) onCancel();
                            Navigator.of(context).pop();
                          },
                          child: Text(cancelLabel),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMARY_COLOR,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                          ),
                         onPressed: () async {
                            Navigator.of(context).pop();
                            await Future.delayed(
                                const Duration(milliseconds: 5));
                            if (onConfirm != null) onConfirm();
                          },

                          child: Text(
                            confirmLabel,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static close(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

static Future<void> loading(BuildContext context,
      {bool? barrierDismissible}) async {
    final screenWidth = MediaQuery.of(context).size.width;

    return showDialog<void>(
      context: context,
      barrierDismissible:
          barrierDismissible ?? false, // prevent accidental dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(10),
          // 👇 Dynamically adjust padding based on screen width
          insetPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.3, // takes 40% of width
          ),
          content: const Center(
            child: SizedBox(
              height: 100,
              width: 100,
              child: LoadingCircle(enableShadow: false),
            ),
          ),
        );
      },
    );
  }


  static snackBar(BuildContext context, message) {
    final snackBar = SnackBar(
      // width: MediaQuery.of(context).size.width,'
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade600,
          borderRadius: BorderRadius.circular(
            30,
          ),
        ),
        child: Text(message),
      ),
      padding: const EdgeInsets.all(12),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
