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

part 'provider.g.dart';

@riverpod
Future<Schedule> schedule(ScheduleRef ref) async {
    final prefs = ref.listen(settingsProvider, (previous, next) {}).read().value!;

    final String universityId = prefs.getString('universityId')!;
    final String facultyId    = prefs.getString('facultyId')!;
    final String yearId       = prefs.getString('yearId')!;
    final String groupId      = prefs.getString('groupId')!;
    final String path = '${globalUniScheduleManifest.uniScheduleManifest.schedulePathPrefix}'
                         + '/$scheduleFormatVersion/$universityId/$facultyId/$yearId/$groupId.json';
    final Uri scheduleJsonRawUri  = Uri.https(globalUniScheduleManifest.uniScheduleManifest.serverIp, '$path');
    final Uri scheduleJsonGzipUri = Uri.https(globalUniScheduleManifest.uniScheduleManifest.serverIp, '$path.gz');

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
            throw Exception('Не удалось загрузить расписание');
        }
    }

    // * Decoding no longer needed when using GitHub Pages
    // // Because there are cyrillic characters in the json we have to decode it.
    // // final utf8 = const Utf8Decoder().convert(response.body.codeUnits);
    // // final decompressed = ZstdDecoder().convert(response.body.codeUnits);
    // // final decoded = const Utf8Decoder().convert(response.body.codeUnits);
    prefs.setString('fallbackSchedule', schedule);

    final json;

    try {
        json = jsonDecode(schedule) as Map<String, dynamic>;
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
    bool _manifestUpdated         = false;
    String _serverIp              = 'raw.githubusercontent.com';
    String _schedulePathPrefix    = '/SergeGris/sergegris.github.io/main';
    String? _channelLink          = null;
    String _supportGoals          = 'Поддержать развитие проекта';
    List<NamedLink> _supportVariants = [];
    List<int>? _latestApplicationVersion = null;
    List<NamedLink> _updateVariants = [];

    try {
        Uri uri = Uri.https(
            'raw.githubusercontent.com',
            '/SergeGris/sergegris.github.io/main/manifest.json'
        );
        var manifestDataJson = await downloadFileByUri(uri);
        var json = jsonDecode(manifestDataJson);

        if (json['schedule.format.version'] != null) {
            _manifestUpdated = (scheduleFormatVersion < json['schedule.format.version']);
        }
        if (json['server.ip'] != null) {
            _serverIp = json['server.ip'];
        }
        if (json['schedule.path.prefix'] != null) {
            _schedulePathPrefix = json['schedule.path.prefix'];
        }
        if (json['channel.link'] != null) {
            _channelLink = json['channel.link'];
        }
        if (json['support.variants'] != null) {
            _supportVariants = json['support.variants'].map(
                (e) => NamedLink(label: e[0].toString(), link: e[1].toString())
            ).cast<NamedLink>().toList();
        }
        if (json['support.goals'] != null) {
            _supportGoals = json['support.goals'];
        }
        if (json['latest.application.version'] != null) {
            _latestApplicationVersion = json['latest.application.version'].split('.').map((v) => int.parse(v)).cast<int>().toList();
        }
        if (json['update.variants'] != null) {
            _updateVariants = json['update.variants'].map(
                (e) => NamedLink(label: e[0].toString(), link: e[1].toString())
            ).cast<NamedLink>().toList();
        }
    } catch (e) {
        print("can not download $e");
    }

    final instance = UniScheduleManifest(manifestUpdated: _manifestUpdated,
                                         serverIp: _serverIp,
                                         schedulePathPrefix: _schedulePathPrefix,
                                         channelLink: _channelLink,
                                         supportVariants: _supportVariants,
                                         supportGoals: _supportGoals,
                                         latestApplicationVersion: _latestApplicationVersion,
                                         updateVariants: _updateVariants);
    return instance;
}
