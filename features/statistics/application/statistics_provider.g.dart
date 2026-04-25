// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(statisticsSummary)
final statisticsSummaryProvider = StatisticsSummaryFamily._();

final class StatisticsSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<StatisticsSummary>,
          StatisticsSummary,
          FutureOr<StatisticsSummary>
        >
    with
        $FutureModifier<StatisticsSummary>,
        $FutureProvider<StatisticsSummary> {
  StatisticsSummaryProvider._({
    required StatisticsSummaryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'statisticsSummaryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$statisticsSummaryHash();

  @override
  String toString() {
    return r'statisticsSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<StatisticsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<StatisticsSummary> create(Ref ref) {
    final argument = this.argument as String;
    return statisticsSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is StatisticsSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$statisticsSummaryHash() => r'35d05eecee404e8422e2970112cbe289ad84a3a5';

final class StatisticsSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<StatisticsSummary>, String> {
  StatisticsSummaryFamily._()
    : super(
        retry: null,
        name: r'statisticsSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  StatisticsSummaryProvider call(String period) =>
      StatisticsSummaryProvider._(argument: period, from: this);

  @override
  String toString() => r'statisticsSummaryProvider';
}

@ProviderFor(categoryStats)
final categoryStatsProvider = CategoryStatsFamily._();

final class CategoryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategoryStat>>,
          List<CategoryStat>,
          FutureOr<List<CategoryStat>>
        >
    with
        $FutureModifier<List<CategoryStat>>,
        $FutureProvider<List<CategoryStat>> {
  CategoryStatsProvider._({
    required CategoryStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'categoryStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryStatsHash();

  @override
  String toString() {
    return r'categoryStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CategoryStat>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategoryStat>> create(Ref ref) {
    final argument = this.argument as String;
    return categoryStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryStatsHash() => r'22ff81f7bccbff0c048c3aceafad8f55631e01c7';

final class CategoryStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CategoryStat>>, String> {
  CategoryStatsFamily._()
    : super(
        retry: null,
        name: r'categoryStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CategoryStatsProvider call(String period) =>
      CategoryStatsProvider._(argument: period, from: this);

  @override
  String toString() => r'categoryStatsProvider';
}

@ProviderFor(monthlyBars)
final monthlyBarsProvider = MonthlyBarsProvider._();

final class MonthlyBarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MonthlyBar>>,
          List<MonthlyBar>,
          FutureOr<List<MonthlyBar>>
        >
    with $FutureModifier<List<MonthlyBar>>, $FutureProvider<List<MonthlyBar>> {
  MonthlyBarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyBarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyBarsHash();

  @$internal
  @override
  $FutureProviderElement<List<MonthlyBar>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MonthlyBar>> create(Ref ref) {
    return monthlyBars(ref);
  }
}

String _$monthlyBarsHash() => r'f6e79e2fc1ebd07ad2c8ef9f6ada6d01b5a7bee3';
