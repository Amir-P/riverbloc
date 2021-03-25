part of '../riverbloc.dart';

/// The [BlocStateProvider] watch a [Cubit] or [Bloc] and subscribe to its
/// `state` and rebuilds every time that it is emitted.
class BlocStateProvider<S extends Object>
    extends AlwaysAliveProviderBase<BlocBase<S>, S> {
  BlocStateProvider._(this._provider)
      : super(
          (ref) => ref.watch(_provider),
          _provider.name != null ? '${_provider.name}.state' : null,
        );

  final BlocProvider<BlocBase<S>> _provider;

  @override
  Override overrideWithValue(S value) {
    return ProviderOverride(
      ValueProvider<BlocBase<S>, S>((ref) => ref.watch(_provider), value),
      this,
    );
  }

  @override
  _BlocStateProviderState<S> createState() => _BlocStateProviderState();
}

class _BlocStateProviderState<S> extends ProviderStateBase<BlocBase<S>, S> {
  StreamSubscription<S>? _subscription;

  @override
  void valueChanged({BlocBase<S>? previous}) {
    if (createdValue != previous) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  void _subscribe() {
    exposedValue = createdValue.state;
    _subscription = createdValue.stream.listen(_listener);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _listener(S value) {
    exposedValue = value;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}
