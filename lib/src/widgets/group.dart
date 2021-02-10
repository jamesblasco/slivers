
//@dart=2.12

import 'package:flutter/widgets.dart';
import '../rendering/group.dart';

/// A sliver lays out multiple sliver children along the main axis of the viewport.
///
/// See also:
///
/// * [Column], [Row], boxes to place multiple box children in a linear array.
/// * [SliverList], a sliver to place multiple box children in a linear array along the main axis.
/// * [CustomScrollView], a box to place multiple sliver children in a linear array.
/// * [SliverBox], to place a single box child where a sliver is expected.
class SliverGroup extends MultiChildRenderObjectWidget {
  /// Creates a sliver that lays out it children along the main axis of the viewport
  SliverGroup({
    Key? key,
    required List<Widget> slivers,
  }) : super(key: key, children: slivers);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSliverGroup();
  }
}