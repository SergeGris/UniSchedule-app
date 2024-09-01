
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

// <https://stackoverflow.com/a/52272545>.
class OverflowedText extends StatelessWidget {
    // Require style to make this widget work great.
    const OverflowedText({super.key,
                          required this.text,
                          required this.shortText,
                          this.textAlign = TextAlign.left,
                          this.textDirection = TextDirection.ltr,
                          required this.style,
                          this.maxLines = 1});

    final String text;
    final String? shortText;
    final TextAlign textAlign;
    final TextDirection textDirection;
    final TextStyle style;
    final int maxLines;

    @override
    Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, size) {
            // Build the TextSpan().
            final span = TextSpan(
                text: text,
                style: style
            );

            // Use a TextPainter to determine if it will exceed max lines.
            final tp = TextPainter(
                maxLines: maxLines,
                textAlign: textAlign,
                textDirection: textDirection,
                text: span,
                textScaler: MediaQuery.textScalerOf(context) // Pay attention to text scaler.
            );

            // Trigger it to layout.
            tp.layout(maxWidth: size.maxWidth);

            // Whether the text overflowed or not.
            final exceeded = tp.didExceedMaxLines;

            if (exceeded && shortText == null) {
                return const SizedBox.shrink();
            }

            return Text(
                exceeded ? shortText! : text,
                maxLines: maxLines,
                textAlign: textAlign,
                textDirection: textDirection,
                style: style
            );
        }
    );
}
