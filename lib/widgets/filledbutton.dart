
// Copyright (C) 2024 Sergey Sushilin <sushilinsergey@yandex.ru>.
// This file is part of UniSchedule.

// UniSchedule is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.

// UniSchedule is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with UniSchedule.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '../utils.dart';

class UniScheduleFilledButton extends StatelessWidget {
    const UniScheduleFilledButton({super.key, this.child, required this.onPressed, this.onLongPress});

    final child;
    final onPressed;
    final onLongPress;

    @override
    Widget build(BuildContext context) {
        return TextButton(
            style: TextButton.styleFrom(
                backgroundColor: primaryContainerColor(context),
            ),
            child: child,
            onPressed: onPressed,
            onLongPress: onLongPress
        );
    }
}
