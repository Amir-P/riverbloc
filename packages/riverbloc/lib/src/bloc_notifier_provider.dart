part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class BlocProviderRef<B extends BlocBase<Object?>> implements Ref<B> {
  /// The [Bloc] currently exposed by this provider.
  ///
  /// Cannot be accessed while creating the provider.
  B get bloc;
}

class _BlocProviderElement<B extends BlocBase<Object?>>
    extends ProviderElementBase<B> implements BlocProviderRef<B> {
  _BlocProviderElement(_NotifierProvider<B> super.provider);

  @override
  B get bloc => requireState;
}

// ignore: subtype_of_sealed_class
class _NotifierProvider<B extends BlocBase<Object?>>
    extends AlwaysAliveProviderBase<B> {
  _NotifierProvider(
    this._create, {
    required String? name,
    required this.dependencies,
    super.from,
    super.argument,
  }) : super(
          name: modifierName(name, 'notifier'),
        );

  final Create<B, BlocProviderRef<B>> _create;

  @override
  final List<ProviderOrFamily>? dependencies;

  @override
  B create(covariant BlocProviderRef<B> ref) {
    final bloc = _create(ref);
    ref.onDispose(bloc.close);
    return bloc;
  }

  @override
  bool updateShouldNotify(B previousState, B newState) => true;

  @override
  _BlocProviderElement<B> createElement() => _BlocProviderElement(this);
}

// ignore: subtype_of_sealed_class
/// Add [overrideWithValue] to [AutoDisposeBlocProvider]
mixin BlocProviderOverrideMixin<B extends BlocBase<S>, S> on ProviderBase<S> {
  ///
  ProviderBase<B> get bloc;

  @override
  late final List<ProviderOrFamily>? dependencies = [bloc];

  @override
  ProviderBase<B> get originProvider => bloc;

  /// {@macro riverpod.overrridewithvalue}
  Override overrideWithValue(B value) {
    return ProviderOverride(
      origin: bloc,
      override: ValueProvider<B>(value),
    );
  }

  /// The bloc notifies when the state changes.
  @override
  bool updateShouldNotify(S previousState, S newState) {
    return newState != previousState;
  }
}
