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

/// Games visible per age group (GameId.id strings).
/// Home grid sorts these A–Z by display name.
List<String> enabledGameIdsForAge(AgeGroup group) {
  return switch (group) {
    AgeGroup.littleExplorers => [
        'balloon_parade',
        'bubble_number_pop',
        'bunny_hop_adventure',
        'candy_color_hunt',
        'catch_the_butterfly_garden',
        'catch_the_fish_adventure',
        'cloud_pop_garden',
        'feed_the_frog_adventure',
        'frog_pond_adventure',
        'hungry_duck_pond_adventure',
        'hungry_monkey_banana_adventure',
        'hungry_teddy_cupcake_party',
        'magical_flower_garden',
        'ocean_fish_adventure',
        'peek_a_boo_animal_friends',
      ],
    AgeGroup.tinyLearners => [
        'alphabet_adventure_quiz',
        'alphabet_bridge_adventure',
        'animal_sounds',
        'ascending_bubble_number_pop',
        'color_balloon_pop',
        'color_school_bags',
        'descending_number_pop',
        'moon_rescue_adventure',
        'number_bridge_adventure',
        'number_word_pop',
        'odd_one_out',
        'picture_bridge_adventure',
        'shadow_match_adventure',
        'shape_drop_adventure',
      ],
    AgeGroup.smartExplorers => [
        'classic_card_memory',
        'color_shape_bridge_adventure',
      ],
    AgeGroup.brainMasters => [
        'complete_the_word_adventure',
        'number_memory',
        'recall_picture_adventure',
      ],
    AgeGroup.youngGeniuses => [
        'color_memory',
        'pattern_match',
      ],
  };
}

bool useLargeLayoutForAge(AgeGroup group) =>
    group == AgeGroup.littleExplorers || group == AgeGroup.tinyLearners;
