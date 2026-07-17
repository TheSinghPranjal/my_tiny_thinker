import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/games/color_school_bags/models/color_school_bags_models.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/school_backpack_widget.dart';
import 'package:my_tiny_thinker/games/color_school_bags/presentation/widgets/school_book_widget.dart';

class SortBagsBoard extends StatelessWidget {
  const SortBagsBoard({
    super.key,
    required this.books,
    required this.backpacks,
    required this.onDrop,
    required this.onHoverBag,
    this.hoverBagId,
    this.largerTouch = true,
  });

  final List<SortBook> books;
  final List<SortBackpack> backpacks;
  final void Function({required String bookId, required String bagId}) onDrop;
  final void Function(String? bagId) onHoverBag;
  final String? hoverBagId;
  final bool largerTouch;

  @override
  Widget build(BuildContext context) {
    final bookSize = largerTouch ? 128.0 : 110.0;
    final bagSize = largerTouch ? 132.0 : 112.0;
    final visibleBooks = books.where((b) => !b.matched).toList();

    return Column(
      children: [
        // Books row
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final book in books)
                  Expanded(
                    child: Center(
                      child: book.matched
                          ? SizedBox(width: bookSize, height: bookSize)
                          : _DraggableBook(
                              book: book,
                              size: bookSize,
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            visibleBooks.isEmpty
                ? 'Great sorting!'
                : 'Drag the book to the matching bag!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1565C0),
            ),
          ),
        ),
        // Backpacks row
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final bag in backpacks)
                  Expanded(
                    child: Center(
                      child: DragTarget<String>(
                        onWillAcceptWithDetails: (details) {
                          if (bag.filled) return false;
                          onHoverBag(bag.id);
                          return true;
                        },
                        onLeave: (_) => onHoverBag(null),
                        onAcceptWithDetails: (details) {
                          onHoverBag(null);
                          onDrop(bookId: details.data, bagId: bag.id);
                        },
                        builder: (context, candidate, rejected) {
                          final hovering =
                              candidate.isNotEmpty || hoverBagId == bag.id;
                          // Highlight correct bag when hovering matching book
                          final bookId =
                              candidate.isNotEmpty ? candidate.first : null;
                          final matchingBook = bookId == null
                              ? null
                              : books.where((b) => b.id == bookId).firstOrNull;
                          final correctHover = matchingBook != null &&
                              matchingBook.colorKind == bag.colorKind;

                          return SchoolBackpackWidget(
                            backpack: bag.copyWith(
                              glow: bag.glow || correctHover,
                            ),
                            size: bagSize,
                            hovering: hovering,
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DraggableBook extends StatelessWidget {
  const _DraggableBook({
    required this.book,
    required this.size,
  });

  final SortBook book;
  final double size;

  @override
  Widget build(BuildContext context) {
    final child = SchoolBookWidget(book: book, size: size);

    return Draggable<String>(
      data: book.id,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.12,
          child: SchoolBookWidget(
            book: book,
            size: size,
            glow: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.2, child: child),
      child: child,
    );
  }
}
