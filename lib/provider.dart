import 'dart:convert';
import 'dart:async';
import 'dart:io';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './models/schedule.dart';
import './manifest.dart';
import './utils.dart';
import './globalkeys.dart';

part 'provider.g.dart';

@riverpod
Future<Schedule> schedule(ScheduleRef ref) async {
    final prefs = ref.listen(settingsProvider, (previous, next) {}).read().value!;

    final String universityId = prefs.getString('universityId')!;
    final String facultyId    = prefs.getString('facultyId')!;
    final String yearId       = prefs.getString('yearId')!;
    final String groupId      = prefs.getString('groupId')!;
    final String path = '${globalUniScheduleManifest.schedulePathPrefix}'
                         + '/$scheduleFormatVersion/$universityId/$facultyId/$yearId/$groupId.json';
    final Uri scheduleJsonRawUri  = Uri.https(globalUniScheduleManifest.serverIp, '$path');
    final Uri scheduleJsonGzipUri = Uri.https(globalUniScheduleManifest.serverIp, '$path.gz');

    print(scheduleJsonRawUri);

    //TODO RENAME
    Future<http.Response> getAndTrack(ScheduleRef ref, Uri uri) async
    {
        var response;

        try {
            response = await http.get(uri);
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
        } catch (e) {
            throw Exception('Ошибка подключения к серверу: проверьте доступ к интернету');
        }

        return response;
    }

    var schedule;

    try {
        var response = await getAndTrack(ref, scheduleJsonGzipUri);
        schedule = utf8.decode(GZipCodec().decode(response.bodyBytes));
    } catch (e) {
        try {
            var response = await getAndTrack(ref, scheduleJsonRawUri);
            schedule = response.body;
        } catch (e) {
            GlobalKeys.showWarningBanner('Не удалось обновить расписание');
            throw Exception('Не удалось загрузить расписание');
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
        json = jsonDecode(schedule) as Map<String, dynamic>;
        prefs.setString('fallbackSchedule', schedule);
    } catch (e) {
        print(e);
        throw Exception('Не удалось обработать расписание');
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
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs;
}

@riverpod
Future<DateTime> datetime(DatetimeRef ref) async {
    Timer.periodic(
        Duration(
            minutes: 1,
            seconds: DateTime.now().second,
        ),
        (timer) {
            ref.invalidateSelf();
        }
    );

    return DateTime.now();
}

@riverpod
Future<UniScheduleManifest> uniScheduleManifest(UniScheduleManifestRef ref) async {

    var instance;

    try {
        Uri uri = Uri.https(
            'raw.githubusercontent.com',
            '/SergeGris/sergegris.github.io/main/manifest.json'
        );
        var manifestDataJson = await downloadFileByUri(uri);
        var json = jsonDecode(manifestDataJson);
        instance = UniScheduleManifest.fromJson(json);
    } catch (e) {
        print("can not download $e");
        instance = UniScheduleManifest.createEmpty();
    }


    return instance;
}
