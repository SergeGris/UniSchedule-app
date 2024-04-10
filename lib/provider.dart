import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './configuration.dart';
import './globalkeys.dart';
import './models/schedule.dart';

part 'provider.g.dart';

@riverpod
Future<Schedule> schedule(ScheduleRef ref) async {
    final prefs = ref.listen(settingsProvider, (previous, next) {}).read().value!;

    final universityId = prefs.getString('universityId')!;
    final facultyId    = prefs.getString('facultyId')!;
    final yearId       = prefs.getString('yearId')!;
    final groupId      = prefs.getString('groupId')!;
    final path = '${UniScheduleConfiguration.schedulePathPrefix}/${UniScheduleConfiguration.scheduleFormatVersion}/$universityId/$facultyId/$yearId/$groupId.json';

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

    String? scheduleLastUpdate = null;
    String schedule;

    try {
        // Download gziped version.
        final scheduleJsonGzipUri = Uri.https(UniScheduleConfiguration.serverIp, '$path.gz');
        final response = await getAndTrack(ref, scheduleJsonGzipUri);
        schedule = utf8.decode(GZipCodec().decode(response.bodyBytes));
    } catch (e) {
        try {
            // Or try download json as is.
            final scheduleJsonRawUri = Uri.https(UniScheduleConfiguration.serverIp, path);
            final response = await getAndTrack(ref, scheduleJsonRawUri);
            schedule = response.body;
        } catch (e) {
            // Or... Maybe we cached something?
            final fallbackSchedule = prefs.getString('fallbackSchedule');

            if (fallbackSchedule != null) {
                scheduleLastUpdate = prefs.getString('scheduleLastUpdate');
                schedule = fallbackSchedule;
            } else {
                const error = 'Не удалось обновить расписание';
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
        String dateTimeToString(DateTime datetime) {
            // Returns at least two-digit stringified number
            String _twoDigits(int n) => (n >= 10) ? '$n' : '0$n';

            final year   = datetime.year;
            final month  = _twoDigits(datetime.month);
            final day    = _twoDigits(datetime.day);
            final hour   = _twoDigits(datetime.hour);
            final minute = _twoDigits(datetime.minute);

            return '$hour:$minute $day.$month.$year';
        }

        json = jsonDecode(schedule) as Map<String, dynamic>;
        await prefs.setString('fallbackSchedule', schedule);
        final dt = DateTime.now();
        await prefs.setString('scheduleLastUpdate', dateTimeToString(dt));
    } catch (e) {
        throw Exception('Не удалось обработать расписание');
    }

    if (scheduleLastUpdate != null) {
        GlobalKeys.showWarningBanner('Отображается версия расписания на $scheduleLastUpdate');
    }

    return Schedule.fromJson(json);
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
  return SharedPreferences.getInstance();
}

// @riverpod
// Future<DateTime> datetime(DatetimeRef ref) async {
//     final now = DateTime.now();//.add(Duration(days: 0, hours: 18)); //.subtract(Duration(days: 0, hours: 5)); ///TODO OOOOOOO
//     // Invalidate ref every minute.
//     Timer(Duration(minutes: 0, seconds: 60 - now.second), () => ref.invalidateSelf());
//     return now;
// }

@riverpod
Future<void> uniScheduleConfiguration(UniScheduleConfigurationRef ref) async {
    final stopwatch = Stopwatch();
    stopwatch.start();

    try {
        final uri = Uri.https(
            UniScheduleConfiguration.defaultServerIp,
            '${UniScheduleConfiguration.defaultSchedulePathPrefix}/configuration.json',
        );

        final manifestDataJson = await http.get(uri);
        UniScheduleConfiguration.fromJson(await jsonDecode(manifestDataJson.body));
    } catch (e) {
        UniScheduleConfiguration.createEmpty();
    }

    stopwatch.stop();
    ref.read(scheduleProvider); // TODO (it works?) Initialize schedule when configuration downloaded

    // NOTE: We a doing a delation for at least 300 for showing logo
    if (stopwatch.elapsed.inMilliseconds < 300) {
        await Future.delayed(Duration(milliseconds: 300 - stopwatch.elapsed.inMilliseconds));
    }
}

// @riverpod
// Future<UniScheduleServices> uniScheduleServices(UniScheduleServicesRef ref) async {
//     UniScheduleServices services;

//     try {
//         final uri = Uri.https(
//             defaultServerIp,
//             '$defaultSchedulePathPrefix/configuration.json',
//         );

//         final manifestDataJson = await http.get(uri);
//         configuration = UniScheduleConfiguration.fromJson(await jsonDecode(manifestDataJson.body));
//     } catch (e) {
//         configuration = UniScheduleConfiguration.createEmpty();
//     }

//     return services;
// }

// Used for notifing about updating selected building
@riverpod
Future<void> building(BuildingRef ref) async {
    return;
}

// Used for notifing about updating selected building
@riverpod
Future<void> theme(ThemeRef ref) async {
    return;
}
