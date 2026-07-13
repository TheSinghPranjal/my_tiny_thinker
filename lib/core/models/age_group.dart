import 'package:equatable/equatable.dart';

enum AgeGroup {
  littleExplorers('little_explorers', '1–2 Years', '🌱', 'Little Explorers'),
  tinyLearners('tiny_learners', '2–4 Years', '🌈', 'Tiny Learners'),
  smartExplorers('smart_explorers', '5–7 Years', '🚀', 'Smart Explorers'),
  brainMasters('brain_masters', '8–10 Years', '🧠', 'Brain Masters'),
  youngGeniuses('young_geniuses', '11–14 Years', '🎓', 'Young Geniuses');

  const AgeGroup(this.id, this.ageRange, this.emoji, this.title);
  final String id;
  final String ageRange;
  final String emoji;
  final String title;

  String get description => switch (this) {
        AgeGroup.littleExplorers => 'Touch, colors & curiosity',
        AgeGroup.tinyLearners => 'Simple matching & fun',
        AgeGroup.smartExplorers => 'Thinking & memory skills',
        AgeGroup.brainMasters => 'Logic, speed & challenges',
        AgeGroup.youngGeniuses => 'Advanced brain training',
      };

  int get minAge => switch (this) {
        AgeGroup.littleExplorers => 1,
        AgeGroup.tinyLearners => 2,
        AgeGroup.smartExplorers => 5,
        AgeGroup.brainMasters => 8,
        AgeGroup.youngGeniuses => 11,
      };
}

class OnboardingState extends Equatable {
  const OnboardingState({
    this.isComplete = false,
    this.ageGroup = AgeGroup.smartExplorers,
    this.avatarId = 'panda',
  });

  final bool isComplete;
  final AgeGroup ageGroup;
  final String avatarId;

  OnboardingState copyWith({
    bool? isComplete,
    AgeGroup? ageGroup,
    String? avatarId,
  }) =>
      OnboardingState(
        isComplete: isComplete ?? this.isComplete,
        ageGroup: ageGroup ?? this.ageGroup,
        avatarId: avatarId ?? this.avatarId,
      );

  Map<String, dynamic> toJson() => {
        'isComplete': isComplete,
        'ageGroup': ageGroup.id,
        'avatarId': avatarId,
      };

  factory OnboardingState.fromJson(Map<String, dynamic> json) {
    final groupId = json['ageGroup'] as String? ?? AgeGroup.smartExplorers.id;
    return OnboardingState(
      isComplete: json['isComplete'] as bool? ?? false,
      ageGroup: AgeGroup.values.firstWhere(
        (g) => g.id == groupId,
        orElse: () => AgeGroup.smartExplorers,
      ),
      avatarId: json['avatarId'] as String? ?? 'panda',
    );
  }

  @override
  List<Object?> get props => [isComplete, ageGroup, avatarId];
}

const kAvatars = [
  ('panda', '🐼', 'Panda'),
  ('fox', '🦊', 'Fox'),
  ('lion', '🦁', 'Lion'),
  ('penguin', '🐧', 'Penguin'),
  ('monkey', '🐵', 'Monkey'),
  ('bear', '🐻', 'Bear'),
  ('rabbit', '🐰', 'Rabbit'),
  ('unicorn', '🦄', 'Unicorn'),
  ('robot', '🤖', 'Robot'),
  ('cat', '🐱', 'Cat'),
];
