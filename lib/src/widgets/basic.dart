// @dart=2.12
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../rendering/proxy_box.dart';

class SliverClipRect extends SingleChildRenderObjectWidget {
  /// Creates a rectangular clip.
  ///
  /// If [clipper] is null, the clip will match the layout size and position of
  /// the child.
  ///
  /// The [clipBehavior] argument must not be null or [Clip.none].
  const SliverClipRect(
      {Key? key,
      this.clipper,
      this.clipBehavior = Clip.hardEdge,
      Widget? child})
      : assert(clipBehavior != null),
        super(key: key, child: child);

  /// If non-null, determines which clip to use.
  final CustomClipper<Rect>? clipper;

  /// {@macro flutter.rendering.ClipRectLayer.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  @override
  RenderSliverClipRect createRenderObject(BuildContext context) {
    assert(clipBehavior != Clip.none);
    return RenderSliverClipRect(clipper: clipper, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverClipRect renderObject) {
    assert(clipBehavior != Clip.none);
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior;
  }

  @override
  void didUnmountRenderObject(RenderSliverClipRect renderObject) {
    renderObject.clipper = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CustomClipper<Rect>>('clipper', clipper,
        defaultValue: null));
  }
}

class SliverClipRRect extends SingleChildRenderObjectWidget {
  /// Creates a rounded-rectangular clip.
  ///
  /// The [borderRadius] defaults to [BorderRadius.zero], i.e. a rectangle with
  /// right-angled corners.
  ///
  /// If [clipper] is non-null, then [borderRadius] is ignored.
  ///
  /// The [clipBehavior] argument must not be null or [Clip.none].
  const SliverClipRRect({
    Key? key,
    this.borderRadius = BorderRadius.zero,
    this.clipper,
    this.clipBehavior = Clip.antiAlias,
    Widget? child,
  })  : assert(borderRadius != null || clipper != null),
        assert(clipBehavior != null),
        super(key: key, child: child);

  /// The border radius of the rounded corners.
  ///
  /// Values are clamped so that horizontal and vertical radii sums do not
  /// exceed width/height.
  ///
  /// This value is ignored if [clipper] is non-null.
  final BorderRadius? borderRadius;

  /// If non-null, determines which clip to use.
  final CustomClipper<RRect>? clipper;

  /// {@macro flutter.rendering.ClipRectLayer.clipBehavior}
  ///
  /// Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  @override
  RenderSliverClipRRect createRenderObject(BuildContext context) {
    assert(clipBehavior != Clip.none);
    return RenderSliverClipRRect(
        borderRadius: borderRadius!,
        clipper: clipper,
        clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverClipRRect renderObject) {
    assert(clipBehavior != Clip.none);
    renderObject
      ..borderRadius = borderRadius!
      ..clipBehavior = clipBehavior
      ..clipper = clipper;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BorderRadius>(
        'borderRadius', borderRadius,
        showName: false, defaultValue: null));
    properties.add(DiagnosticsProperty<CustomClipper<RRect>>('clipper', clipper,
        defaultValue: null));
  }
}

class SliverClipPath extends SingleChildRenderObjectWidget {
  /// Creates a path clip.
  ///
  /// If [clipper] is null, the clip will be a rectangle that matches the layout
  /// size and location of the child. However, rather than use this default,
  /// consider using a [ClipRect], which can achieve the same effect more
  /// efficiently.
  ///
  /// The [clipBehavior] argument must not be null or [Clip.none].
  const SliverClipPath({
    Key? key,
    this.clipper,
    this.clipBehavior = Clip.antiAlias,
    Widget? sliver,
  })  : assert(clipBehavior != null),
        super(key: key, child: sliver);

  /// Creates a shape clip.
  ///
  /// Uses a [ShapeBorderClipper] to configure the [ClipPath] to clip to the
  /// given [ShapeBorder].
  static Widget shape({
    Key? key,
    required ShapeBorder shape,
    Clip clipBehavior = Clip.antiAlias,
    Widget? sliver,
  }) {
    assert(clipBehavior != null);
    assert(clipBehavior != Clip.none);
    assert(shape != null);
    return Builder(
      key: key,
      builder: (BuildContext context) {
        return ClipPath(
          clipper: ShapeBorderClipper(
            shape: shape,
            textDirection: Directionality.maybeOf(context),
          ),
          clipBehavior: clipBehavior,
          child: sliver,
        );
      },
    );
  }

  /// If non-null, determines which clip to use.
  ///
  /// The default clip, which is used if this property is null, is the
  /// bounding box rectangle of the widget. [ClipRect] is a more
  /// efficient way of obtaining that effect.
  final CustomClipper<Path>? clipper;

  /// {@macro flutter.rendering.ClipRectLayer.clipBehavior}
  ///
  /// Defaults to [Clip.antiAlias].
  final Clip clipBehavior;

  @override
  RenderSliverClipPath createRenderObject(BuildContext context) {
    assert(clipBehavior != Clip.none);
    return RenderSliverClipPath(clipper: clipper, clipBehavior: clipBehavior);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverClipPath renderObject) {
    assert(clipBehavior != Clip.none);
    renderObject
      ..clipper = clipper
      ..clipBehavior = clipBehavior;
  }

  @override
  void didUnmountRenderObject(RenderClipPath renderObject) {
    renderObject.clipper = null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CustomClipper<Path>>('clipper', clipper,
        defaultValue: null));
  }
}

/// A RenderProxyBox subclass that allows you to customize the
/// hit-testing behavior.
abstract class RenderProxySliverWithHitTestBehavior extends RenderProxySliver
    with SliverBoxAdapterHelperMixin {
  /// Initializes member variables for subclasses.
  ///
  /// By default, the [behavior] is [HitTestBehavior.deferToChild].
  RenderProxySliverWithHitTestBehavior({
    this.behavior = HitTestBehavior.deferToChild,
    RenderSliver? child,
  }) : super(child);

  /// How to behave during hit testing.
  HitTestBehavior behavior;

  @override
  bool hitTest(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    bool hitTarget = false;
    final position = computeDirectionalOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
    if (size.contains(position)) {
      hitTarget = hitTestChildren(result,
              mainAxisPosition: mainAxisPosition,
              crossAxisPosition: crossAxisPosition) ||
          hitTestSelf(
              mainAxisPosition: mainAxisPosition,
              crossAxisPosition: crossAxisPosition);
      if (hitTarget || behavior == HitTestBehavior.translucent)
        result.add(SliverHitTestEntry(this,
            mainAxisPosition: mainAxisPosition,
            crossAxisPosition: crossAxisPosition));
    }
    return hitTarget;
  }

  @override
  bool hitTestSelf(
      {required double mainAxisPosition, required double crossAxisPosition}) {
    return behavior == HitTestBehavior.opaque;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<HitTestBehavior>('behavior', behavior,
        defaultValue: null));
  }
}

/// A widget that paints its area with a specified [Color] and then draws its
/// child on top of that color.
class ColoredSliver extends SingleChildRenderObjectWidget {
  /// Creates a widget that paints its area with the specified [Color].
  ///
  /// The [color] parameter must not be null.
  const ColoredSliver({required this.color, Widget? child, Key? key})
      : assert(color != null),
        super(key: key, child: child);

  /// The color to paint the background area with.
  final Color color;

  @override
  _RenderSliverColoredBox createRenderObject(BuildContext context) {
    return _RenderSliverColoredBox(color: color);
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderSliverColoredBox renderObject) {
    renderObject.color = color;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Color>('color', color));
  }
}

class _RenderSliverColoredBox extends RenderProxySliverWithHitTestBehavior
    with SliverBoxAdapterHelperMixin {
  _RenderSliverColoredBox({required Color color})
      : _color = color,
        super(behavior: HitTestBehavior.opaque);

  /// The fill color for this render object.
  ///
  /// This parameter must not be null.
  Color get color => _color;
  Color _color;
  set color(Color value) {
    assert(value != null);
    if (value == _color) {
      return;
    }
    _color = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // It's tempting to want to optimize out this `drawRect()` call if the
    // color is transparent (alpha==0), but doing so would be incorrect. See
    // https://github.com/flutter/flutter/pull/72526#issuecomment-749185938 for
    // a good description of why.
    if (size > Size.zero) {
      context.canvas
          .drawRect((offset + scrollOffset) & size, Paint()..color = color);
    }
    if (child != null) {
      context.paintChild(child!, offset);
    }
  }
}
