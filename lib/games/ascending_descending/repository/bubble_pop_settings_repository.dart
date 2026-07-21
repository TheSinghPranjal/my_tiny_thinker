import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';
import 'package:my_tiny_thinker/games/ascending_descending/models/bubble_pop_settings.dart';

const _bubbleNumberPopSettingsKey = 'bubble_number_pop_settings';
const _ascendingBubblePopSettingsKey = 'ascending_bubble_number_pop_settings';
const _descendingNumberPopSettingsKey = 'descending_number_pop_settings';
const _numberWordPopSettingsKey = 'number_word_pop_settings';

final bubbleNumberPopSettingsProvider = StateNotifierProvider<
    BubbleNumberPopSettingsNotifier, BubbleNumberPopSettings>((ref) {
  return BubbleNumberPopSettingsNotifier(ref.watch(storageServiceProvider));
});

final ascendingBubblePopSettingsProvider = StateNotifierProvider<
    OrderedBubblePopSettingsNotifier, OrderedBubblePopSettings>((ref) {
  return OrderedBubblePopSettingsNotifier(
    ref.watch(storageServiceProvider),
    _ascendingBubblePopSettingsKey,
  );
});

final descendingNumberPopSettingsProvider = StateNotifierProvider<
    OrderedBubblePopSettingsNotifier, OrderedBubblePopSettings>((ref) {
  return OrderedBubblePopSettingsNotifier(
    ref.watch(storageServiceProvider),
    _descendingNumberPopSettingsKey,
  );
});

final numberWordPopSettingsProvider = StateNotifierProvider<
    NumberWordPopSettingsNotifier, NumberWordPopSettings>((ref) {
  return NumberWordPopSettingsNotifier(ref.watch(storageServiceProvider));
});

class BubbleNumberPopSettingsNotifier
    extends StateNotifier<BubbleNumberPopSettings> {
  BubbleNumberPopSettingsNotifier(this._storage)
      : super(const BubbleNumberPopSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_bubbleNumberPopSettingsKey);
    if (json != null) state = BubbleNumberPopSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_bubbleNumberPopSettingsKey, state.toJson());
  }

  Future<void> patch(
    BubbleNumberPopSettings Function(BubbleNumberPopSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}

class OrderedBubblePopSettingsNotifier
    extends StateNotifier<OrderedBubblePopSettings> {
  OrderedBubblePopSettingsNotifier(this._storage, this._key)
      : super(const OrderedBubblePopSettings()) {
    _load();
  }

  final StorageService _storage;
  final String _key;

  void _load() {
    final json = _storage.getJson(_key);
    if (json != null) state = OrderedBubblePopSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_key, state.toJson());
  }

  Future<void> patch(
    OrderedBubblePopSettings Function(OrderedBubblePopSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}

class NumberWordPopSettingsNotifier
    extends StateNotifier<NumberWordPopSettings> {
  NumberWordPopSettingsNotifier(this._storage)
      : super(const NumberWordPopSettings()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_numberWordPopSettingsKey);
    if (json != null) state = NumberWordPopSettings.fromJson(json);
  }

  Future<void> _save() async {
    await _storage.saveJson(_numberWordPopSettingsKey, state.toJson());
  }

  Future<void> patch(
    NumberWordPopSettings Function(NumberWordPopSettings) fn,
  ) async {
    state = fn(state);
    await _save();
  }
}
