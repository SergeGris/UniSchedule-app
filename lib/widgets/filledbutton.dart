
import 'package:flutter/material.dart';

import '../utils.dart';

class UniScheduleFilledButton extends StatelessWidget {
    const UniScheduleFilledButton({super.key, this.child, this.onPressed});

    final child;
    final onPressed;

    @override
    Widget build(BuildContext context) {
        return TextButton(
            style: TextButton.styleFrom(
                backgroundColor: primaryContainerColor(context),
            ),
            child: child,
            onPressed: onPressed
        );
    }
}
