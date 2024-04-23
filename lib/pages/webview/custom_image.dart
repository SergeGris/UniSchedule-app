
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

import 'dart:convert';

import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
    const CustomImage({super.key,
            this.url,
            this.width,
            this.height,
            this.maxWidth = double.infinity,
            this.maxHeight = double.infinity,
            this.minWidth = 0.0,
            this.minHeight = 0.0});

    final double? width;
    final double? height;
    final double maxWidth;
    final double maxHeight;
    final double minWidth;
    final double minHeight;
    final Uri? url;

    @override
    Widget build(BuildContext context) {
        return Container(
            constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                minHeight: minHeight,
                minWidth: minWidth),
            width: width,
            height: height,
            child: getImage(),
        );
    }

    Widget? getImage() {
        if (url != null) {
            if (url!.scheme == 'data') {
                final bytes = const Base64Decoder().convert(url.toString().replaceFirst('data:image/png;base64,', ''));
                return Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => getBrokenImageIcon(),
                );
            }
            return Image.network(
                url.toString(),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => getBrokenImageIcon(),
            );
        }
        return getBrokenImageIcon();
    }

    Widget getBrokenImageIcon() {
        return Icon(
            Icons.broken_image,
            size: width ?? height ?? maxWidth,
        );
    }
}
