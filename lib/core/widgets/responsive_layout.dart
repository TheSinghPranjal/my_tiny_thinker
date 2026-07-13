import 'package:flutter/material.dart';
import 'package:my_tiny_thinker/core/constants/app_spacing.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.maxWidth = 1200,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget child;
        if (constraints.maxWidth >= Breakpoints.desktop && desktop != null) {
          child = desktop!;
        } else if (constraints.maxWidth >= Breakpoints.tablet &&
            tablet != null) {
          child = tablet!;
        } else {
          child = mobile;
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.phoneColumns = 2,
    this.tabletColumns = 3,
    this.spacing = AppSpacing.md,
    this.childAspectRatio = 0.85,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int phoneColumns;
  final int tabletColumns;
  final double spacing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= Breakpoints.tablet
            ? tabletColumns
            : phoneColumns;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({
    super.key,
    required this.child,
    this.phone = AppSpacing.lg,
    this.tablet = AppSpacing.xxl,
  });

  final Widget child;
  final double phone;
  final double tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding =
            constraints.maxWidth >= Breakpoints.tablet ? tablet : phone;
        return Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        );
      },
    );
  }
}
