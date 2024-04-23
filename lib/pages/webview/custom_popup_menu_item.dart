
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

class CustomPopupMenuItem<T> extends PopupMenuEntry<T> {
    const CustomPopupMenuItem({
            super.key,
            this.value,
            this.enabled = true,
            this.height = kMinInteractiveDimension,
            this.textStyle,
            this.isIconButtonRow = false,
            required this.child,
    });

    final T? value;

    final bool enabled;

    @override
    final double height;

    final TextStyle? textStyle;

    final Widget child;

    final bool isIconButtonRow;

    @override
    bool represents(T? value) => value == this.value;

    @override
    CustomPopupMenuItemState<T, CustomPopupMenuItem<T>> createState() => CustomPopupMenuItemState<T, CustomPopupMenuItem<T>>();
}

class CustomPopupMenuItemState<T, W extends CustomPopupMenuItem<T>> extends State<W> {
    @protected
    Widget buildChild() => widget.child;

    @protected
    void handleTap() {
        Navigator.pop<T>(context, widget.value);
    }

    @override
    Widget build(BuildContext context) {
        final ThemeData theme = Theme.of(context);
        final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
        TextStyle style = (widget.textStyle ?? popupMenuTheme.textStyle ?? theme.textTheme.titleMedium ?? TextStyle())!;

        if (!widget.enabled) style = style.copyWith(color: theme.disabledColor);

        Widget item = AnimatedDefaultTextStyle(
            style: style,
            duration: kThemeChangeDuration,
            child: Container(
                alignment: AlignmentDirectional.centerStart,
                constraints: BoxConstraints(minHeight: widget.height),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: buildChild(),
            ),
        );

        if (!widget.enabled) {
            final bool isDark = theme.brightness == Brightness.dark;
            item = IconTheme.merge(
                data: IconThemeData(opacity: isDark ? 0.5 : 0.38),
                child: item,
            );
        }

        if (widget.isIconButtonRow) {
            return Material(
                color: Colors.white,
                child: item,
            );
        }

        return InkWell(
            onTap: widget.enabled ? handleTap : null,
            canRequestFocus: widget.enabled,
            child: item,
        );
    }
}
