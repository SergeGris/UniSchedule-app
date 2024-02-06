
const int scheduleFormatVersion = 3;

class GlobalUniScheduleManifest {
    GlobalUniScheduleManifest(UniScheduleManifest uniScheduleManifest) {
        globalUniScheduleManifest = UniScheduleManifest(manifestUpdated: uniScheduleManifest.manifestUpdated,
                                                        serverIp: uniScheduleManifest.serverIp,
                                                        schedulePathPrefix: uniScheduleManifest.schedulePathPrefix,
                                                        channelLink: uniScheduleManifest.channelLink,
                                                        supportVariants: uniScheduleManifest.supportVariants,
                                                        supportGoals: uniScheduleManifest.supportGoals,
                                                        latestApplicationVersion: uniScheduleManifest.latestApplicationVersion,
                                                        updateVariants: uniScheduleManifest.updateVariants);
    }

    UniScheduleManifest get uniScheduleManifest {
        return globalUniScheduleManifest;
    }

    static UniScheduleManifest globalUniScheduleManifest = UniScheduleManifest.createEmpty();
}

late GlobalUniScheduleManifest globalUniScheduleManifest;

class NamedLink {
    NamedLink({required this.label, required this.link});

    String label;
    String link;
}

class UniScheduleManifest {
    UniScheduleManifest({required this.manifestUpdated,
                         required this.serverIp,
                         required this.schedulePathPrefix,
                         required this.channelLink,
                         required this.supportVariants,
                         required this.supportGoals,
                         required this.latestApplicationVersion,
                         required this.updateVariants})
        : loaded = true;
    UniScheduleManifest.createEmpty();

    late bool manifestUpdated;
    late String serverIp;
    late String schedulePathPrefix;
    late String? channelLink;
    late String supportGoals;
    late List<NamedLink> supportVariants;
    late List<int>? latestApplicationVersion;
    late List<NamedLink> updateVariants;
    bool loaded = false;
}
