import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/logic/learn_to_sort_food_logic.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/models/learn_to_sort_food_models.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/presentation/widgets/food_bubble_widget.dart';
import 'package:my_tiny_thinker/games/learn_to_sort_food/presentation/widgets/food_sort_board.dart';

void main() {
  group('bubble spawning', () {
    test('fills the sky with both categories represented', () {
      for (var i = 0; i < 50; i++) {
        final foods = LearnToSortFoodLogic.spawnFoods(
          settings: const FoodSortSettings(),
          round: 1,
          count: 3,
        );
        expect(foods, hasLength(3));
        expect(foods.any((f) => f.category == FoodCategory.healthy), isTrue);
        expect(foods.any((f) => f.category == FoodCategory.junk), isTrue);
      }
    });

    test('spawns inside the play area with a non-zero drift', () {
      final foods = LearnToSortFoodLogic.spawnFoods(
        settings: const FoodSortSettings(),
        round: 1,
        count: 5,
      );
      for (final food in foods) {
        expect(food.x, inInclusiveRange(0.0, 1.0));
        expect(food.y, inInclusiveRange(0.0, 1.0));
        expect(food.vx * food.vx + food.vy * food.vy, greaterThan(0));
      }
    });

    test('requires the missing category so a basket is never stranded', () {
      const onlyJunk = [
        FloatingFood(id: 'a', kind: FoodKind.burger),
        FloatingFood(id: 'b', kind: FoodKind.pizza),
      ];
      expect(
        LearnToSortFoodLogic.requiredCategoryFor(onlyJunk),
        FoodCategory.healthy,
      );
      expect(
        LearnToSortFoodLogic.requiredCategoryFor(const [
          FloatingFood(id: 'a', kind: FoodKind.apple),
          FloatingFood(id: 'b', kind: FoodKind.burger),
        ]),
        isNull,
      );
    });
  });

  group('drift', () {
    test('keeps bubbles on screen by reflecting them off the edges', () {
      var food = const FloatingFood(
        id: 'a',
        kind: FoodKind.apple,
        x: 0.98,
        y: 0.02,
        vx: 0.5,
        vy: -0.5,
      );

      for (var i = 0; i < 400; i++) {
        food = LearnToSortFoodLogic.drift(food, 1 / 60);
        expect(food.x, inInclusiveRange(0.0, 1.0));
        expect(food.y, inInclusiveRange(0.0, 1.0));
      }
    });

    test('reverses direction at a boundary', () {
      const food = FloatingFood(
        id: 'a',
        kind: FoodKind.apple,
        x: 1.0,
        y: 0.5,
        vx: 0.2,
        vy: 0,
      );
      expect(LearnToSortFoodLogic.drift(food, 0.5).vx, lessThan(0));
    });
  });

  group('difficulty', () {
    test('shows more bubbles as difficulty ramps up', () {
      expect(
        LearnToSortFoodLogic.bubbleCountForDifficulty(
          FoodSortDifficulty.beginner,
        ),
        lessThan(
          LearnToSortFoodLogic.bubbleCountForDifficulty(
            FoodSortDifficulty.medium,
          ),
        ),
      );
    });

    test('never exceeds the maximum difficulty a parent allows', () {
      const settings = FoodSortSettings(
        maxDifficulty: FoodSortDifficulty.easy,
      );
      for (final round in [1, 5, 20, 100]) {
        expect(
          LearnToSortFoodLogic
              .effectiveDifficulty(settings, round)
              .index,
          lessThanOrEqualTo(FoodSortDifficulty.easy.index),
        );
      }
    });

    test('beginner pool draws from all enabled foods, not a fixed quartet', () {
      for (var i = 0; i < 30; i++) {
        final pool = LearnToSortFoodLogic.activePool(
          const FoodSortSettings(maxDifficulty: FoodSortDifficulty.beginner),
          1,
        );
        expect(pool, hasLength(4));
        expect(
          pool.where((k) => FoodCatalog.def(k).category == FoodCategory.healthy),
          hasLength(2),
        );
        expect(
          pool.where((k) => FoodCatalog.def(k).category == FoodCategory.junk),
          hasLength(2),
        );
      }
    });

    test('advanced difficulty uses the full enabled food catalog', () {
      final pool = LearnToSortFoodLogic.activePool(
        const FoodSortSettings(maxDifficulty: FoodSortDifficulty.advanced),
        20,
      );
      expect(
        pool.length,
        FoodCatalog.defaultHealthy.length + FoodCatalog.defaultJunk.length,
      );
    });

    test('defaults to a one-minute session like other games', () {
      const settings = FoodSortSettings();
      expect(settings.sessionSeconds, 60);
      expect(settings.unlimitedTime, isFalse);
      expect(settings.maxDifficulty, FoodSortDifficulty.advanced);
    });
  });

  group('baskets', () {
    test('exposes one basket per category', () {
      final baskets = LearnToSortFoodLogic.defaultBaskets();
      expect(baskets.map((b) => b.category), [
        FoodCategory.healthy,
        FoodCategory.junk,
      ]);
      expect(baskets.first.label, 'Healthy Food');
      expect(baskets.last.label, 'Junk Food');
    });
  });

  group('board', () {
    const foods = [
      FloatingFood(id: 'apple', kind: FoodKind.apple, x: 0.1, y: 0.2),
      FloatingFood(id: 'burger', kind: FoodKind.burger, x: 0.8, y: 0.2),
    ];

    Future<List<({String foodId, String basketId})>> pumpBoard(
      WidgetTester tester,
    ) async {
      final drops = <({String foodId, String basketId})>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodSortBoard(
              foods: foods,
              baskets: LearnToSortFoodLogic.defaultBaskets(),
              onDrop: ({required foodId, required basketId}) =>
                  drops.add((foodId: foodId, basketId: basketId)),
              onHoverBasket: (_) {},
            ),
          ),
        ),
      );
      return drops;
    }

    // The baskets carry category icons that can repeat a food emoji, so food
    // emoji are matched inside their bubble.
    Finder inBubble(String emoji) => find.descendant(
          of: find.byType(FoodBubbleWidget),
          matching: find.text(emoji),
        );

    testWidgets('renders every floating food and both baskets', (tester) async {
      await pumpBoard(tester);

      expect(inBubble('🍎'), findsOneWidget);
      expect(inBubble('🍔'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Burger'), findsOneWidget);
      expect(find.text('Healthy Food'), findsOneWidget);
      expect(find.text('Junk Food'), findsOneWidget);
    });

    testWidgets('dragging a food onto a basket reports the drop',
        (tester) async {
      final drops = await pumpBoard(tester);

      final apple = tester.getCenter(find.text('🍎'));
      final healthyBasket = tester.getCenter(find.text('Healthy Food'));
      await tester.dragFrom(apple, healthyBasket - apple);
      await tester.pumpAndSettle();

      expect(drops, hasLength(1));
      expect(drops.single.foodId, 'apple');
      expect(drops.single.basketId, 'basket_healthy');
    });

    testWidgets('a wrong basket still accepts the drop for gentle feedback',
        (tester) async {
      final drops = await pumpBoard(tester);

      final apple = tester.getCenter(find.text('🍎'));
      final junkBasket = tester.getCenter(find.text('Junk Food'));
      await tester.dragFrom(apple, junkBasket - apple);
      await tester.pumpAndSettle();

      expect(drops.single.basketId, 'basket_junk');
    });

    testWidgets('hides food names when the parent turns them off',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FoodSortBoard(
              foods: foods,
              baskets: LearnToSortFoodLogic.defaultBaskets(),
              showFoodNames: false,
              onDrop: ({required foodId, required basketId}) {},
              onHoverBasket: (_) {},
            ),
          ),
        ),
      );

      expect(inBubble('🍎'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });
  });
}
