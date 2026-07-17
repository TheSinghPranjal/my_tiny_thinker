import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/core/models/age_group.dart';
import 'package:my_tiny_thinker/core/services/storage_service.dart';

const _onboardingKey = 'onboarding_state';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref.watch(storageServiceProvider));
});

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._storage) : super(const OnboardingState()) {
    _load();
  }

  final StorageService _storage;

  void _load() {
    final json = _storage.getJson(_onboardingKey);
    if (json != null) {
      state = OnboardingState.fromJson(json);
    }
  }

  Future<void> _save() async {
    await _storage.saveJson(_onboardingKey, state.toJson());
  }

  Future<void> selectAgeGroup(AgeGroup group) async {
    state = state.copyWith(ageGroup: group);
    await _save();
  }

  Future<void> selectAvatar(String avatarId) async {
    state = state.copyWith(avatarId: avatarId);
    await _save();
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isComplete: true);
    await _save();
  }

  Future<void> overrideAgeGroup(AgeGroup group) async {
    state = state.copyWith(ageGroup: group);
    await _save();
  }
}

/// Games visible per age group (GameId.id strings)
List<String> enabledGameIdsForAge(AgeGroup group) {
  return switch (group) {
    AgeGroup.littleExplorers => [
        'candy_color_hunt',
        'bunny_hop_adventure',
        'hungry_teddy_cupcake_party',
        'hungry_duck_pond_adventure',
        'catch_the_butterfly_garden',
        'hungry_monkey_banana_adventure',
        'peek_a_boo_animal_friends',
        'frog_pond_adventure',
        'feed_the_frog_adventure',
        'cloud_pop_garden',
        'magical_flower_garden',
        'bubble_number_pop',
        'ocean_fish_adventure',
      ],
    AgeGroup.tinyLearners => [
        'color_school_bags',
        'shape_drop_adventure',
        'shadow_match_adventure',
        'alphabet_adventure_quiz',
        'bubble_number_pop',
        'color_memory',
        'memory_game',
      ],
    AgeGroup.smartExplorers => [
        'bubble_number_pop',
        'memory_game',
        'odd_one_out',
        'pattern_match',
        'color_memory',
      ],
    AgeGroup.brainMasters => [
        'bubble_number_pop',
        'memory_game',
        'odd_one_out',
        'pattern_match',
        'color_memory',
      ],
    AgeGroup.youngGeniuses => [
        'bubble_number_pop',
        'memory_game',
        'odd_one_out',
        'pattern_match',
        'color_memory',
      ],
  };
}

bool useLargeLayoutForAge(AgeGroup group) =>
    group == AgeGroup.littleExplorers || group == AgeGroup.tinyLearners;
