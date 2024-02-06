// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduleselector.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manifestHash() => r'dd4d95a6a4c3652208c608a32629e6cdbbe7c3f6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [manifest].
@ProviderFor(manifest)
const manifestProvider = ManifestFamily();

/// See also [manifest].
class ManifestFamily extends Family<AsyncValue<ManifestData>> {
  /// See also [manifest].
  const ManifestFamily();

  /// See also [manifest].
  ManifestProvider call(
    Menu which,
  ) {
    return ManifestProvider(
      which,
    );
  }

  @override
  ManifestProvider getProviderOverride(
    covariant ManifestProvider provider,
  ) {
    return call(
      provider.which,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'manifestProvider';
}

/// See also [manifest].
class ManifestProvider extends AutoDisposeFutureProvider<ManifestData> {
  /// See also [manifest].
  ManifestProvider(
    Menu which,
  ) : this._internal(
          (ref) => manifest(
            ref as ManifestRef,
            which,
          ),
          from: manifestProvider,
          name: r'manifestProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$manifestHash,
          dependencies: ManifestFamily._dependencies,
          allTransitiveDependencies: ManifestFamily._allTransitiveDependencies,
          which: which,
        );

  ManifestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.which,
  }) : super.internal();

  final Menu which;

  @override
  Override overrideWith(
    FutureOr<ManifestData> Function(ManifestRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ManifestProvider._internal(
        (ref) => create(ref as ManifestRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        which: which,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ManifestData> createElement() {
    return _ManifestProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManifestProvider && other.which == which;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, which.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManifestRef on AutoDisposeFutureProviderRef<ManifestData> {
  /// The parameter `which` of this provider.
  Menu get which;
}

class _ManifestProviderElement
    extends AutoDisposeFutureProviderElement<ManifestData> with ManifestRef {
  _ManifestProviderElement(super.provider);

  @override
  Menu get which => (origin as ManifestProvider).which;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
