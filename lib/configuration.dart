
import 'utils.dart';

const int scheduleFormatVersion = 3;
const String defaultServerIp = 'raw.githubusercontent.com';
const String defaultSchedulePathPrefix = '/SergeGris/sergegris.github.io/main';
late UniScheduleConfiguration globalUniScheduleConfiguration;

class NamedLink {
    NamedLink({required this.label, required this.link});

    String label;
    String link;
}

class UniScheduleConfiguration {
    UniScheduleConfiguration.fromJson(Map<String, dynamic> json) {
        _loaded = true;

        if (json['schedule.format.version'] != null) {
            _manifestUpdated = scheduleFormatVersion < json['schedule.format.version'];
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
            _latestApplicationVersion = Version.fromString(json['latest.application.version']);
        }
        if (json['update.variants'] != null) {
            _updateVariants = json['update.variants'].map(
                (e) => NamedLink(label: e[0].toString(), link: e[1].toString())
            ).cast<NamedLink>().toList();
        }
        if (json['feedback.link'] != null) {
            _feedbackLink = json['feedback.link'];
        }
        if (json['student.disk.link'] != null) {
            _studentDiskLink = json['student.disk.link'];
        }
    }

    UniScheduleConfiguration.createEmpty();

    static bool            _manifestUpdated          = false;
    static String          _serverIp                 = defaultServerIp;
    static String          _schedulePathPrefix       = defaultSchedulePathPrefix;
    static String?         _channelLink              = null;
    static String          _supportGoals             = 'Поддержать развитие проекта';
    static List<NamedLink> _supportVariants          = [];
    static Version?        _latestApplicationVersion = null;
    static List<NamedLink> _updateVariants           = [];
    static bool            _loaded                   = false;
    static String?         _feedbackLink             = null;
    static String?         _studentDiskLink          = null;

    bool            get manifestUpdated          => _manifestUpdated;
    String          get serverIp                 => _serverIp;
    String          get schedulePathPrefix       => _schedulePathPrefix;
    String?         get channelLink              => _channelLink;
    String          get supportGoals             => _supportGoals;
    List<NamedLink> get supportVariants          => _supportVariants;
    Version?        get latestApplicationVersion => _latestApplicationVersion;
    List<NamedLink> get updateVariants           => _updateVariants;
    bool            get loaded                   => _loaded;
    String?         get feedbackLink             => _feedbackLink;
    String?         get studentDiskLink          => _studentDiskLink;
}
