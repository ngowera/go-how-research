import 'package:flutter/material.dart';

/// Keeps toolbars and bounded lists reachable in landscape and with a keyboard.
class PhoneWorkspace extends StatelessWidget {
  const PhoneWorkspace({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final minimumHeight = constraints.maxWidth < 360 ? 1000.0 : 760.0;
          if (constraints.maxWidth >= 900 ||
              constraints.maxHeight >= minimumHeight) {
            return child;
          }
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: SizedBox(
                height: minimumHeight,
                width: constraints.maxWidth,
                child: child),
          );
        },
      );
}
