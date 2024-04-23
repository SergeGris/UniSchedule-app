
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

import 'package:flutter/foundation.dart';

class Util {
    static bool urlIsSecure(Uri url) {
        return (url.scheme == 'https') || isLocalizedContent(url);
    }

    static bool isLocalizedContent(Uri url) {
        return url.scheme == 'file'
            || url.scheme == 'chrome'
            || url.scheme == 'data'
            || url.scheme == 'javascript'
            || url.scheme == 'about';
    }

    static bool isAndroid() {
        return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    }

    static bool isIOS() {
        return !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    }

    static bool isWeb() {
        return kIsWeb;
    }
}
