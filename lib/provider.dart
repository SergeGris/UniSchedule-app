import 'dart:convert';
import 'dart:async';
import 'dart:io';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './models/schedule.dart';
import './configuration.dart';
import './globalkeys.dart';

part 'provider.g.dart';

@riverpod
Future<Schedule> schedule(ScheduleRef ref) async {
    final prefs = ref.listen(settingsProvider, (previous, next) {}).read().value!;

    final universityId = prefs.getString('universityId')!;
    final facultyId    = prefs.getString('facultyId')!;
    final yearId       = prefs.getString('yearId')!;
    final groupId      = prefs.getString('groupId')!;
    final path = '${globalUniScheduleConfiguration.schedulePathPrefix}/$scheduleFormatVersion/$universityId/$facultyId/$yearId/$groupId.json';

    //TODO print(scheduleJsonRawUri);

    //TODO RENAME
    Future<http.Response> getAndTrack(ScheduleRef ref, Uri uri) async {
        try {
            final response = await http.get(uri);
            final link = ref.keepAlive();

            ref.onAddListener(
                () async {
                    final newResponse = await http.get(uri);
                    // Resumed

                    if (newResponse.body != response.body) {
                        // Flagged
                        link.close();
                        ref.invalidateSelf();
                    }
                }
            );

            return response;
        } catch (e) {
            throw Exception('Ошибка подключения к серверу: проверьте доступ к интернету');
        }
    }

    bool cached = false;
    var schedule;

    try {
        // Download gziped version.
        final scheduleJsonGzipUri = Uri.https(globalUniScheduleConfiguration.serverIp, '$path.gz');
        var response = await getAndTrack(ref, scheduleJsonGzipUri);
        schedule = utf8.decode(GZipCodec().decode(response.bodyBytes));
    } catch (e) {
        try {
            // Or try download json as is.
            final scheduleJsonRawUri = Uri.https(globalUniScheduleConfiguration.serverIp, '$path');
            var response = await getAndTrack(ref, scheduleJsonRawUri);
            schedule = response.body;
        } catch (e) {
            // Or... Maybe we cached something?
            final prefs = ref.watch(settingsProvider).value!;
            final fallbackSchedule = prefs.getString('fallbackSchedule');

            if (fallbackSchedule != null) {
                cached = true;
                final scheduleLastUpdate = prefs.getString('scheduleLastUpdate');
                schedule = fallbackSchedule;
            } else {
                final error = 'Не удалось обновить расписание';
                GlobalKeys.showWarningBanner(error);
                throw Exception(error);
            }
        }
    }

    GlobalKeys.hideWarningBanner();

    // * Decoding no longer needed when using GitHub Pages
    // // Because there are cyrillic characters in the json we have to decode it.
    // // final utf8 = const Utf8Decoder().convert(response.body.codeUnits);
    // // final decompressed = ZstdDecoder().convert(response.body.codeUnits);
    // // final decoded = const Utf8Decoder().convert(response.body.codeUnits);

    final json;

    try {
        // Use for get 01.01.1970, but not 1.1.1970.
        String f(int s) {
            if (s >= 10) {
                return '$s';
            } else {
                return '0$s';
            }
        }

        json = jsonDecode(schedule) as Map<String, dynamic>;
        await prefs.setString('fallbackSchedule', schedule);
        final dt = await DateTime.now();
        await prefs.setString('scheduleLastUpdate', '${f(dt.hour)}:${f(dt.hour)} ${f(dt.day)}.${f(dt.month)}.${dt.year}');
    } catch (e) {
        throw Exception('Не удалось обработать расписание');
    }

    final s = Schedule.fromJson(json);

    if (cached) {
        GlobalKeys.showWarningBanner('Отображается версия расписания на ${prefs.getString("scheduleLastUpdate")}');
    }

    return s;
}

/*
// For automatic group list resolution
@riverpod
Future<
    Map< // Schools
        String,
        Map< // Faculties
            String,
            Map< // Years
                String,
                String // Groups
                >>>> manifest(ManifestRef ref) async {
  final Uri manifestUri = Uri.https(serverIp, "/manifest.json");
}
*/

@riverpod
Future<SharedPreferences> settings(SettingsRef ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
Future<DateTime> datetime(DatetimeRef ref) async {
    final now = DateTime.now();
    // Invalidate ref every minute.
    Timer(Duration(minutes: 0, seconds: 60 - now.second), () => ref.invalidateSelf());
    return now;
}

@riverpod
Future<UniScheduleConfiguration> uniScheduleConfiguration(UniScheduleConfigurationRef ref) async {
    try {
        final uri = Uri.https(
            defaultServerIp,
            defaultSchedulePathPrefix + '/configuration.json',
        );

        final manifestDataJson = await http.get(uri);
        final json = jsonDecode(manifestDataJson.body);
        return UniScheduleConfiguration.fromJson(json);
    } catch (e) {
        return UniScheduleConfiguration.createEmpty();
    }
}
