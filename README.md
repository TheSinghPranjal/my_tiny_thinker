# TinyThink

A colorful educational Flutter app for children aged 3–10, built to strengthen memory, concentration, pattern recognition, number recognition, logical thinking, observation, speed, and reflexes.

## Features (Part 1 & 2)

### Foundation
- Complete design system (colors, typography, gradients, spacing)
- Reusable UI components (buttons, cards, dialogs, badges, progress bars)
- Animated magical home screen with game selection grid
- Bottom navigation shell (Home, Games, Rewards, Profile, Parents)
- Riverpod state management with persistent storage
- Audio & haptic service foundations
- Parent Zone with math lock + long-press bypass
- Rewards, XP, daily streak, achievements models
- GoRouter navigation with transitions
- Localization-ready architecture (English)
- Responsive layout for phones & tablets

### Bubble Number Pop (Game 1)
- Ascending & descending number sorting
- Configurable range (-99,999 to +99,999)
- Bubble counts: 5–50
- Difficulty levels: Easy → Expert
- Timer modes: Relaxed, Timed, Endless
- Floating bubble physics with edge bounce & repulsion
- Combo scoring, hints after inactivity, pause menu
- Victory screen with coins, stars, XP rewards

### Memory Game Hub (Part 3)
- Animated toy room hub with 10 mini-games
- Classic Card Memory, Sequence, Position, Picture Recall, Sound, Flash, Number, Color, Emoji, Object Tray
- 5 difficulty tiers (Easy → Master) with adaptive learning
- Combo scoring, coins/stars/XP rewards, unlockable games
- Per-game statistics and parent dashboard integration

## Getting Started

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Project Structure

```
lib/
├── core/           # Theme, widgets, services, routing, models
├── home/           # Landing & games list
├── settings/
├── profile/
├── rewards/
├── parent_zone/
└── games/
    ├── ascending_descending/   # Bubble Number Pop
    └── memory_game/            # Memory Game Hub (10 mini-games)
```

## Audio Assets

Place optional sound files in `assets/audio/`:
- `bubble_pop.mp3`, `correct.mp3`, `wrong.mp3`, `button_tap.mp3`
- `coin.mp3`, `combo.mp3`, `victory.mp3`, `ambient_music.mp3`

The app runs gracefully without audio files (errors are caught in debug).

## Tests

```bash
flutter test
```
