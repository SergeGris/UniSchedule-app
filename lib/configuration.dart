
import 'utils.dart';

class NamedLink {
    NamedLink({required this.label, required this.link});

    final String label;
    final String link;
}

class SupporterEntry {
    SupporterEntry({required this.name, required this.amount});

    final String name;
    final int amount;
}

class UniScheduleConfiguration {
    static const int scheduleFormatVersion = 3;
    static const String defaultServerIp = 'raw.githubusercontent.com';
    static const String defaultSchedulePathPrefix = '/SergeGris/sergegris.github.io/main';

    UniScheduleConfiguration._();
    UniScheduleConfiguration.createEmpty();

    UniScheduleConfiguration.fromJson(Map<String, dynamic> json) {
        loaded = true;

        if (json['schedule.format.version'] != null) {
            manifestUpdated = scheduleFormatVersion < json['schedule.format.version'];
        }

        if (json['server.ip'] != null) {
            serverIp = json['server.ip'];
        }


        if (json['schedule.path.prefix'] != null) {
            schedulePathPrefix = json['schedule.path.prefix'];
        }

        if (json['channel.link'] != null) {
            channelLink = json['channel.link'];
        }

        if (json['support.variants'] != null) {
            supportVariants = json['support.variants'].map(
                (e) => NamedLink(label: e[0].toString(), link: e[1].toString())
            )
            .cast<NamedLink>()
            .toList();
        }

        if (json['support.goals'] != null) {
            supportGoals = json['support.goals'];
        }

        if (json['latest.application.version'] != null) {
            latestApplicationVersion = Version.fromString(json['latest.application.version']);
        }

        if (json['update.variants'] != null) {
            updateVariants = json['update.variants'].map(
                (e) => NamedLink(label: e[0].toString(), link: e[1].toString())
            )
            .cast<NamedLink>()
            .toList();
        }

        if (json['feedback.link'] != null) {
            feedbackLink = json['feedback.link'];
        }

        if (json['student.disk.link'] != null) {
            studentDiskLink = json['student.disk.link'];
        }

        if (json['author.email.address'] != null) {
            authorEmailAddress = json['author.email.address'];
        }

        if (json['supported.by'] != null) {
            supportedBy = json['supported.by'].map(
                (e) => SupporterEntry(name: e[0].toString(), amount: e[1].toInt())
            )
            .cast<SupporterEntry>()
            .toList();
        }
    }

    static bool                 manifestUpdated          = false;
    static String               serverIp                 = defaultServerIp;
    static String               schedulePathPrefix       = defaultSchedulePathPrefix;
    static String?              channelLink              = null;
    static String               supportGoals             = 'Поддержать развитие проекта';
    static List<NamedLink>      supportVariants          = [];
    static Version?             latestApplicationVersion = null;
    static List<NamedLink>      updateVariants           = [];
    static bool                 loaded                   = false;
    static String?              feedbackLink             = null;
    static String?              studentDiskLink          = null;
    static String?              authorEmailAddress       = null;
    static List<SupporterEntry> supportedBy              = [];
}
