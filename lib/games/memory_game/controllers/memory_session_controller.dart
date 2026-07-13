import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_tiny_thinker/games/memory_game/models/memory_models.dart';
import 'package:my_tiny_thinker/core/providers/settings_provider.dart';
import 'package:my_tiny_thinker/games/memory_game/logic/memory_game_logic.dart';
import 'package:my_tiny_thinker/games/memory_game/repository/memory_repository.dart';

final memoryHubStatsProvider =
    StateNotifierProvider<MemoryHubStatsNotifier, MemoryHubStatistics>((ref) {
  return MemoryHubStatsNotifier(ref.watch(memoryRepositoryProvider));
});

class MemoryHubStatsNotifier extends StateNotifier<MemoryHubStatistics> {
  MemoryHubStatsNotifier(this._repo) : super(_repo.loadStatistics());

  final MemoryRepository _repo;

  void refresh() => state = _repo.loadStatistics();

  Future<bool> unlockGame(MemoryMiniGameType type, int coins) async {
    final ok = await _repo.unlockGame(type, coins);
    if (ok) refresh();
    return ok;
  }
}

final memorySessionProvider =
    StateNotifierProvider<MemorySessionController, MemorySessionState>((ref) {
  return MemorySessionController(ref);
});

class MemorySessionController extends StateNotifier<MemorySessionState> {
  MemorySessionController(this._ref) : super(const MemorySessionState());

  final Ref _ref;
  Timer? _timer;
  Timer? _countdownTimer;
  Timer? _showTimer;
  int _previousBest = 0;
  final _random = math.Random();

  void initSession(MemoryGameConfig config) {
    _previousBest = _ref
        .read(memoryHubStatsProvider)
        .statsFor(config.gameType)
        .bestScore;

    state = MemorySessionState(
      config: config,
      phase: MemoryPhase.countdown,
      countdown: 3,
      gameData: _createGameData(config),
    );
    _startCountdown();
  }

  Map<String, dynamic> _createGameData(MemoryGameConfig config) {
    final d = config.difficulty;
    final round = 1;
    return switch (config.gameType) {
      MemoryMiniGameType.classicCard => _initClassicCard(config, d),
      MemoryMiniGameType.sequence => _initSequence(d, round),
      MemoryMiniGameType.position => _initPosition(d),
      MemoryMiniGameType.pictureRecall => _initPictureRecall(d),
      MemoryMiniGameType.sound => _initSound(d, round),
      MemoryMiniGameType.flash => _initFlash(d),
      MemoryMiniGameType.number => _initNumber(d, round),
      MemoryMiniGameType.color => _initColor(d, round),
      MemoryMiniGameType.emojiMemory => _initEmoji(d),
      MemoryMiniGameType.objectTray => _initObjectTray(d),
    };
  }

  Map<String, dynamic> _initClassicCard(MemoryGameConfig config, MemoryDifficulty d) {
    final (cols, rows) = MemoryDifficultyConfig.cardGrid(d);
    final pairCount = (cols * rows) ~/ 2;
    final items = MemoryContent.themeItems(config.cardTheme, pairCount);
    final cards = <Map<String, dynamic>>[];
    var id = 0;
    for (final item in items) {
      cards.add({'id': id++, 'value': item, 'pairId': item, 'flipped': false, 'matched': false});
      cards.add({'id': id++, 'value': item, 'pairId': item, 'flipped': false, 'matched': false});
    }
    cards.shuffle(_random);
    return {
      'cols': cols,
      'rows': rows,
      'cards': cards,
      'firstPick': null,
      'canFlip': true,
    };
  }

  Map<String, dynamic> _initSequence(MemoryDifficulty d, int round) {
    final len = MemoryDifficultyConfig.sequenceLength(d, round);
    final seq = MemoryContent.randomSequence(len, MemoryContent.sequenceColors.length);
    return {
      'sequence': seq,
      'playerInput': <int>[],
      'showIndex': 0,
      'mode': 'show',
    };
  }

  Map<String, dynamic> _initPosition(MemoryDifficulty d) {
    final grid = MemoryDifficultyConfig.positionGridSize(d);
    final count = MemoryDifficultyConfig.positionCount(d);
    final positions = MemoryContent.randomGridPositions(grid, count);
    return {
      'gridSize': grid,
      'positions': positions,
      'tapped': <int>[],
      'displayMs': MemoryDifficultyConfig.positionDisplayMs(d),
    };
  }

  Map<String, dynamic> _initPictureRecall(MemoryDifficulty d) {
    final scene = MemoryContent.generatePictureScene();
    final q = MemoryContent.pictureQuestion(scene);
    return {
      'scene': scene,
      'question': q.$1,
      'answer': q.$2,
      'options': q.$3,
      'displayMs': MemoryDifficultyConfig.pictureDisplayMs(d),
    };
  }

  Map<String, dynamic> _initSound(MemoryDifficulty d, int round) {
    final len = MemoryDifficultyConfig.soundSequenceLength(d, round);
    final seq = MemoryContent.randomSequence(len, MemoryContent.sounds.length);
    return {
      'sequence': seq,
      'playerInput': <int>[],
      'showIndex': 0,
      'mode': 'show',
    };
  }

  Map<String, dynamic> _initFlash(MemoryDifficulty d) {
    final count = MemoryDifficultyConfig.flashItemCount(d);
    final items = MemoryContent.themeItems(MemoryCardTheme.animals, count + 1);
    final shown = items.take(count).toList();
    final missing = items[count];
    return {
      'shown': shown,
      'missing': missing,
      'options': (List<String>.from(shown)..add(missing))..shuffle(_random),
      'displayMs': 3000,
    };
  }

  Map<String, dynamic> _initNumber(MemoryDifficulty d, int round) {
    final digits = MemoryDifficultyConfig.numberDigits(d, round);
    final number = MemoryContent.randomNumber(digits);
    return {'number': number, 'digits': digits, 'input': ''};
  }

  Map<String, dynamic> _initColor(MemoryDifficulty d, int round) {
    final len = MemoryDifficultyConfig.colorSequenceLength(d, round);
    final seq = MemoryContent.randomSequence(len, MemoryContent.sequenceColors.length);
    return {
      'sequence': seq,
      'playerInput': <int>[],
      'showIndex': 0,
      'mode': 'show',
    };
  }

  Map<String, dynamic> _initEmoji(MemoryDifficulty d) {
    final count = MemoryDifficultyConfig.emojiCount(d);
    final emojis = List<String>.from(MemoryContent.emojis.take(count));
    final mode = _random.nextBool() ? 'missing' : 'order';
    if (mode == 'missing') {
      final missing = emojis.removeAt(_random.nextInt(emojis.length));
      return {
        'mode': 'missing',
        'shown': List<String>.from(emojis),
        'missing': missing,
        'options': ([...emojis, missing]..shuffle(_random)),
        'displayMs': 3000,
      };
    }
    final pool = List<String>.from(emojis);
    final len = pool.length;
    final seq = MemoryContent.randomSequence(len, pool.length);
    return {
      'mode': 'order',
      'emojis': pool,
      'sequence': seq,
      'playerInput': <int>[],
      'showIndex': 0,
    };
  }

  Map<String, dynamic> _initObjectTray(MemoryDifficulty d) {
    final count = MemoryDifficultyConfig.objectTrayCount(d);
    final objs = List<MapEntry<String, String>>.from(MemoryContent.objects)
      ..shuffle(_random);
    final shown = objs.take(count).toList();
    final allOptions = List<MapEntry<String, String>>.from(MemoryContent.objects)
      ..shuffle(_random);
    return {
      'shown': shown
          .map((e) => {'emoji': e.key, 'label': e.value})
          .toList(),
      'selected': <String>[],
      'options': allOptions
          .take(count + 4)
          .map((e) => {'emoji': e.key, 'label': e.value})
          .toList(),
      'displayMs': 4000,
    };
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.countdown <= 1) {
        t.cancel();
        _beginRound();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _beginRound() {
    final config = state.config!;
    state = state.copyWith(phase: MemoryPhase.showing);
    _startElapsedTimer();

    final displayMs = switch (config.gameType) {
      MemoryMiniGameType.position =>
        state.gameData['displayMs'] as int? ?? 3000,
      MemoryMiniGameType.pictureRecall =>
        state.gameData['displayMs'] as int? ?? 4000,
      MemoryMiniGameType.flash => state.gameData['displayMs'] as int? ?? 3000,
      MemoryMiniGameType.emojiMemory when state.gameData['mode'] == 'missing' =>
        state.gameData['displayMs'] as int? ?? 3000,
      MemoryMiniGameType.objectTray =>
        state.gameData['displayMs'] as int? ?? 4000,
      MemoryMiniGameType.number => 2000,
      _ => 0,
    };

    if (displayMs > 0) {
      _showTimer?.cancel();
      _showTimer = Timer(Duration(milliseconds: displayMs), () {
        if (!mounted) return;
        _transitionToInput();
      });
    } else if (_isSequenceGame(config.gameType)) {
      _playSequenceStep();
    } else {
      _transitionToInput();
    }
  }

  bool _isSequenceGame(MemoryMiniGameType t) {
    if (t == MemoryMiniGameType.emojiMemory) {
      return state.gameData['mode'] == 'order';
    }
    return t == MemoryMiniGameType.sequence ||
        t == MemoryMiniGameType.sound ||
        t == MemoryMiniGameType.color;
  }

  void _playSequenceStep() {
    final data = Map<String, dynamic>.from(state.gameData);
    final seq = data['sequence'] as List<int>;
    var idx = data['showIndex'] as int? ?? 0;

    if (idx >= seq.length) {
      data['mode'] = 'input';
      data['showIndex'] = 0;
      state = state.copyWith(phase: MemoryPhase.input, gameData: data);
      return;
    }

    state = state.copyWith(
      phase: MemoryPhase.showing,
      gameData: {...data, 'showIndex': idx, 'activeIndex': seq[idx]},
    );

    _showTimer?.cancel();
    _showTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final d = Map<String, dynamic>.from(state.gameData);
      d['showIndex'] = (d['showIndex'] as int) + 1;
      d.remove('activeIndex');
      state = state.copyWith(gameData: d);
      _playSequenceStep();
    });
  }

  void _transitionToInput() {
    if (state.config?.gameType == MemoryMiniGameType.classicCard) {
      state = state.copyWith(phase: MemoryPhase.playing);
    } else {
      state = state.copyWith(phase: MemoryPhase.input);
    }
  }

  void _startElapsedTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  // --- Input handlers ---

  void flipCard(int cardId) {
    if (state.phase != MemoryPhase.playing) return;
    final data = Map<String, dynamic>.from(state.gameData);
    if (data['canFlip'] != true) return;

    final cards = List<Map<String, dynamic>>.from(
      (data['cards'] as List).map((c) => Map<String, dynamic>.from(c as Map)),
    );
    final idx = cards.indexWhere((c) => c['id'] == cardId);
    if (idx < 0 || cards[idx]['matched'] == true || cards[idx]['flipped'] == true) {
      return;
    }

    cards[idx]['flipped'] = true;
    final firstPick = data['firstPick'] as int?;

    if (firstPick == null) {
      data['cards'] = cards;
      data['firstPick'] = cardId;
      state = state.copyWith(gameData: data);
      return;
    }

    data['canFlip'] = false;
    final firstIdx = cards.indexWhere((c) => c['id'] == firstPick);
    final match = cards[firstIdx]['pairId'] == cards[idx]['pairId'];

    data['cards'] = cards;
    state = state.copyWith(gameData: data);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final d = Map<String, dynamic>.from(state.gameData);
      final cs = List<Map<String, dynamic>>.from(
        (d['cards'] as List).map((c) => Map<String, dynamic>.from(c as Map)),
      );

      if (match) {
        cs[firstIdx]['matched'] = true;
        cs[idx]['matched'] = true;
        _onCorrect(extraPoints: 5);
        d['firstPick'] = null;
        d['canFlip'] = true;
        d['cards'] = cs;

        if (cs.every((c) => c['matched'] == true)) {
          _onRoundComplete(success: true);
        } else {
          state = state.copyWith(gameData: d);
        }
      } else {
        cs[firstIdx]['flipped'] = false;
        cs[idx]['flipped'] = false;
        _onWrong();
        d['firstPick'] = null;
        d['canFlip'] = true;
        d['cards'] = cs;
        state = state.copyWith(gameData: d);
      }
    });
  }

  void tapSequenceColor(int index) {
    _handleSequenceInput(index);
  }

  void tapSound(int index) => _handleSequenceInput(index);

  void tapColor(int index) => _handleSequenceInput(index);

  void _handleSequenceInput(int index) {
    if (state.phase != MemoryPhase.input) return;
    final data = Map<String, dynamic>.from(state.gameData);
    final seq = data['sequence'] as List<int>;
    final input = List<int>.from(data['playerInput'] as List<int>? ?? []);
    input.add(index);

    if (index != seq[input.length - 1]) {
      data['playerInput'] = input;
      state = state.copyWith(gameData: data);
      _onWrong();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _onRoundComplete(success: false);
      });
      return;
    }

    data['playerInput'] = input;
    state = state.copyWith(gameData: data);

    if (input.length == seq.length) {
      _onCorrect();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _onRoundComplete(success: true);
      });
    }
  }

  void tapGridCell(int cellIndex) {
    if (state.phase != MemoryPhase.input) return;
    final data = Map<String, dynamic>.from(state.gameData);
    final positions = data['positions'] as List<int>;
    final tapped = List<int>.from(data['tapped'] as List<int>? ?? []);

    if (tapped.contains(cellIndex)) return;
    tapped.add(cellIndex);

    if (!positions.contains(cellIndex)) {
      data['tapped'] = tapped;
      state = state.copyWith(gameData: data);
      _onWrong();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _onRoundComplete(success: false);
      });
      return;
    }

    data['tapped'] = tapped;
    state = state.copyWith(gameData: data);

    if (tapped.length == positions.length) {
      _onCorrect(bonus: positions.length * 5);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        _onRoundComplete(success: true);
      });
    }
  }

  void answerQuestion(String answer) {
    if (state.phase != MemoryPhase.input) return;
    final data = state.gameData;
    final correct = data['answer'] as String;
    if (answer == correct) {
      _onCorrect();
      _onRoundComplete(success: true);
    } else {
      _onWrong();
      _onRoundComplete(success: false);
    }
  }

  void selectFlashItem(String item) {
    if (state.phase != MemoryPhase.input) return;
    if (item == state.gameData['missing']) {
      _onCorrect();
      _onRoundComplete(success: true);
    } else {
      _onWrong();
      _onRoundComplete(success: false);
    }
  }

  void submitNumber(String input) {
    if (state.phase != MemoryPhase.input && state.phase != MemoryPhase.playing) return;
    if (input == state.gameData['number']) {
      _onCorrect();
      _onRoundComplete(success: true);
    } else {
      _onWrong();
      _onRoundComplete(success: false);
    }
  }

  void selectEmoji(String emoji) {
    if (state.phase != MemoryPhase.input) return;
    final mode = state.gameData['mode'] as String?;
    if (mode == 'missing') {
      if (emoji == state.gameData['missing']) {
        _onCorrect();
        _onRoundComplete(success: true);
      } else {
        _onWrong();
        _onRoundComplete(success: false);
      }
    }
  }

  void tapEmojiOrder(int index) => _handleSequenceInput(index);

  void toggleObject(String emoji) {
    if (state.phase != MemoryPhase.input) return;
    final data = Map<String, dynamic>.from(state.gameData);
    final selected = List<String>.from(data['selected'] as List<String>? ?? []);
    if (selected.contains(emoji)) {
      selected.remove(emoji);
    } else {
      selected.add(emoji);
    }
    data['selected'] = selected;
    state = state.copyWith(gameData: data);
  }

  void submitObjectTray() {
    if (state.phase != MemoryPhase.input) return;
    final data = state.gameData;
    final shown = (data['shown'] as List)
        .map((e) => (e as Map)['emoji'] as String)
        .toList();
    final selected = List<String>.from(data['selected'] as List? ?? []);

    final shownSet = shown.toSet();
    final correct = selected.length == shownSet.length &&
        selected.every(shownSet.contains);

    if (correct) {
      _onCorrect(bonus: shown.length * 3);
      _onRoundComplete(success: true);
    } else {
      _onWrong();
      _onRoundComplete(success: false);
    }
  }

  void _onCorrect({int extraPoints = 0, int bonus = 0}) {
    final newCombo = state.combo + 1;
    final points = MemoryScoring.pointsForCorrect(
          combo: newCombo,
          elapsedMs: state.elapsedSeconds * 1000,
          thresholdMs: 5000,
        ) +
        extraPoints +
        bonus;

    state = state.copyWith(
      score: state.score + points,
      combo: newCombo,
      longestCombo: math.max(state.longestCombo, newCombo),
      streak: state.streak + 1,
      feedbackMessage: MemoryScoring.comboLabel(newCombo),
      isCorrectFeedback: true,
    );
  }

  void _onWrong() {
    state = state.copyWith(
      combo: 0,
      mistakes: state.mistakes + 1,
      feedbackMessage: 'Oops! Try again!',
      isCorrectFeedback: false,
    );
  }

  void _onRoundComplete({required bool success}) {
    final config = state.config!;
    final roundsToWin = MemoryDifficultyConfig.roundsToWin(config.difficulty);

    if (success && state.round >= roundsToWin) {
      _endSession(victory: true);
      return;
    }

    var newDifficulty = config.difficulty;
    if (config.adaptiveEnabled) {
      newDifficulty = AdaptiveDifficulty.adjust(
        current: config.difficulty,
        lastRoundSuccess: success,
        adaptiveEnabled: true,
      );
    }

    final newRound = success ? state.round + 1 : state.round;
    final newConfig = config.copyWith(difficulty: newDifficulty);

    if (!success && state.mistakes >= 5) {
      _endSession(victory: false);
      return;
    }

    state = state.copyWith(
      config: newConfig,
      round: newRound,
      phase: MemoryPhase.roundComplete,
      gameData: _createGameData(newConfig),
      clearFeedback: true,
    );

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (state.phase == MemoryPhase.victory ||
          state.phase == MemoryPhase.gameOver) {
        return;
      }
      state = state.copyWith(phase: MemoryPhase.showing, countdown: 0);
      _beginRound();
    });
  }

  void _endSession({required bool victory}) {
    _timer?.cancel();
    _showTimer?.cancel();
    state = state.copyWith(
      phase: victory ? MemoryPhase.victory : MemoryPhase.gameOver,
    );
  }

  MemoryGameResult getResult() {
    return MemoryScoring.calculateResult(
      state: state,
      previousBest: _previousBest,
      sessionComplete: state.phase == MemoryPhase.victory,
    );
  }

  Future<void> saveResult() async {
    final result = getResult();
    await _ref.read(memoryRepositoryProvider).recordGameResult(
          result: result,
          session: state,
        );
    await _ref
        .read(profileProvider.notifier)
        .applyReward(MemoryScoring.toGameReward(result));
    _ref.read(memoryHubStatsProvider.notifier).refresh();
  }

  void pause() {
    if (state.phase == MemoryPhase.playing ||
        state.phase == MemoryPhase.input ||
        state.phase == MemoryPhase.showing) {
      _timer?.cancel();
      _showTimer?.cancel();
      state = state.copyWith(phase: MemoryPhase.paused);
    }
  }

  void resume() {
    if (state.phase == MemoryPhase.paused) {
      _startElapsedTimer();
      state = state.copyWith(phase: MemoryPhase.input);
    }
  }

  void reset() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _showTimer?.cancel();
    state = const MemorySessionState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _showTimer?.cancel();
    super.dispose();
  }
}
