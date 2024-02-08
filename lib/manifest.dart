
import 'utils.dart';

// class GlobalUniScheduleManifest {

//     GlobalUniScheduleManifest(UniScheduleManifest uniScheduleManifest) {
//         globalUniScheduleManifest = UniScheduleManifest(manifestUpdated: uniScheduleManifest.manifestUpdated,
//                                                         serverIp: uniScheduleManifest.serverIp,
//                                                         schedulePathPrefix: uniScheduleManifest.schedulePathPrefix,
//                                                         channelLink: uniScheduleManifest.channelLink,
//                                                         supportVariants: uniScheduleManifest.supportVariants,
//                                                         supportGoals: uniScheduleManifest.supportGoals,
//                                                         latestApplicationVersion: uniScheduleManifest.latestApplicationVersion,
//                                                         updateVariants: uniScheduleManifest.updateVariants);
//     }

//     UniScheduleManifest get uniScheduleManifest {
//         return globalUniScheduleManifest;
//     }

//     static UniScheduleManifest globalUniScheduleManifest = UniScheduleManifest.createEmpty();
// }

const int scheduleFormatVersion = 3;
late UniScheduleManifest globalUniScheduleManifest;

class NamedLink {
    NamedLink({required this.label, required this.link});

    String label;
    String link;
}

class UniScheduleManifest {
    UniScheduleManifest.fromJson(Map<String, dynamic> json) {
        _loaded = true;

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
            _latestApplicationVersion = parseVersion(json['latest.application.version']);
        }
        if (json['update.variants'] != null) {
            _updateVariants = json['update.variants'].map(
                (e) => NamedLink(label: e[0].toString(), link: e[1].toString())
            ).cast<NamedLink>().toList();
        }
    }

    UniScheduleManifest.createEmpty();

    static bool            _manifestUpdated          = false;
    static String          _serverIp                 = 'raw.githubusercontent.com';
    static String          _schedulePathPrefix       = '/SergeGris/sergegris.github.io/main';
    static String?         _channelLink              = null;
    static String          _supportGoals             = 'Поддержать развитие проекта';
    static List<NamedLink> _supportVariants          = [];
    static List<int>?      _latestApplicationVersion = null;
    static List<NamedLink> _updateVariants           = [];
    static bool            _loaded                   = false;

    bool            get manifestUpdated          => _manifestUpdated;
    String          get serverIp                 => _serverIp;
    String          get schedulePathPrefix       => _schedulePathPrefix;
    String?         get channelLink              => _channelLink;
    String          get supportGoals             => _supportGoals;
    List<NamedLink> get supportVariants          => _supportVariants;
    List<int>?      get latestApplicationVersion => _latestApplicationVersion;
    List<NamedLink> get updateVariants           => _updateVariants;
    bool            get loaded                   => _loaded;
}
