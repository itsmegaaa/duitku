// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allProfiles)
final allProfilesProvider = AllProfilesProvider._();

final class AllProfilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileWithBalance>>,
          List<ProfileWithBalance>,
          FutureOr<List<ProfileWithBalance>>
        >
    with
        $FutureModifier<List<ProfileWithBalance>>,
        $FutureProvider<List<ProfileWithBalance>> {
  AllProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allProfilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allProfilesHash();

  @$internal
  @override
  $FutureProviderElement<List<ProfileWithBalance>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileWithBalance>> create(Ref ref) {
    return allProfiles(ref);
  }
}

String _$allProfilesHash() => r'a0e41de26ecdd623960f38a0dc25114a0e6ae6dc';
