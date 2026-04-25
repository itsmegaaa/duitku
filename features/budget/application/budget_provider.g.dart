// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(budgetsWithSpending)
final budgetsWithSpendingProvider = BudgetsWithSpendingProvider._();

final class BudgetsWithSpendingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BudgetWithSpending>>,
          List<BudgetWithSpending>,
          FutureOr<List<BudgetWithSpending>>
        >
    with
        $FutureModifier<List<BudgetWithSpending>>,
        $FutureProvider<List<BudgetWithSpending>> {
  BudgetsWithSpendingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetsWithSpendingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetsWithSpendingHash();

  @$internal
  @override
  $FutureProviderElement<List<BudgetWithSpending>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BudgetWithSpending>> create(Ref ref) {
    return budgetsWithSpending(ref);
  }
}

String _$budgetsWithSpendingHash() =>
    r'4da214f3c5af110179e31a96774350e0eb506b9e';
