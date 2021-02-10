// @dart=2.12
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;


mixin SliverBoxAdapterHelperMixin on RenderSliver {
  Size get size {
    assert(hasSize, 'RenderSliver was not laid out: ${toString()}');
    final SliverGeometry? geometry = this.geometry;

    switch (constraints.axis) {
      case Axis.horizontal:
        return Size(geometry!.scrollExtent, constraints.crossAxisExtent);
      case Axis.vertical:
        return Size(constraints.crossAxisExtent, geometry!.scrollExtent);
    }
  }

  Offset get scrollOffset => computeDirectionalOffset(
        mainAxisPosition: -constraints.scrollOffset,
        crossAxisPosition: 0,
      );

  bool get hasSize => geometry != null;

  Offset computeDirectionalOffset(
      {required double mainAxisPosition, required double crossAxisPosition}) {
    switch (constraints.axis) {
      case Axis.horizontal:
        return Offset(mainAxisPosition, crossAxisPosition);
      case Axis.vertical:
        return Offset(crossAxisPosition, mainAxisPosition);
    }
  }
}

abstract class _RenderCustomClip<T> extends RenderProxySliver
    with SliverBoxAdapterHelperMixin {
  _RenderCustomClip({
    RenderSliver? child,
    CustomClipper<T>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  })  : assert(clipBehavior != null),
        _clipper = clipper,
        _clipBehavior = clipBehavior,
        super(child);

  /// If non-null, determines which clip to use on the child.
  CustomClipper<T>? get clipper => _clipper;
  CustomClipper<T>? _clipper;
  set clipper(CustomClipper<T>? newClipper) {
    if (_clipper == newClipper) return;
    final CustomClipper<T>? oldClipper = _clipper;
    _clipper = newClipper;
    assert(newClipper != null || oldClipper != null);
    if (newClipper == null ||
        oldClipper == null ||
        newClipper.runtimeType != oldClipper.runtimeType ||
        newClipper.shouldReclip(oldClipper)) {
      _markNeedsClip();
    }
    if (attached) {
      oldClipper?.removeListener(_markNeedsClip);
      newClipper?.addListener(_markNeedsClip);
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _clipper?.addListener(_markNeedsClip);
  }

  @override
  void detach() {
    _clipper?.removeListener(_markNeedsClip);
    super.detach();
  }

  void _markNeedsClip() {
    _clip = null;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  T get _defaultClip;
  T? _clip;

  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(Clip value) {
    if (value != _clipBehavior) {
      _clipBehavior = value;
      markNeedsPaint();
    }
  }

  Clip _clipBehavior;

  Size? oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (oldSize != size) _clip = null;
    oldSize = hasSize ? size : null;
  }

  void _updateClip() {
    _clip ??= _clipper?.getClip(size) ?? _defaultClip;
  }

  @override
  Rect describeApproximatePaintClip(RenderObject child) {
    return _clipper?.getApproximateClipRect(size) ?? Offset.zero & size;
  }

  Paint? _debugPaint;
  TextPainter? _debugText;
  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      _debugPaint ??= Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(10.0, 10.0),
          <Color>[
            const Color(0x00000000),
            const Color(0xFFFF00FF),
            const Color(0xFFFF00FF),
            const Color(0x00000000)
          ],
          <double>[0.25, 0.25, 0.75, 0.75],
          TileMode.repeated,
        )
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      _debugText ??= TextPainter(
        text: const TextSpan(
          text: '✂',
          style: TextStyle(
            color: Color(0xFFFF00FF),
            fontSize: 14.0,
          ),
        ),
        textDirection: TextDirection.rtl, // doesn't matter, it's one character
      )..layout();
      return true;
    }());
  }
}

/// Clips its child using a rectangle.
///
/// By default, [RenderSliverClipRect] prevents its child from painting outside its
/// bounds, but the size and location of the clip rect can be customized using a
/// custom [clipper].
class RenderSliverClipRect extends _RenderCustomClip<Rect> {
  /// Creates a rectangular clip.
  ///
  /// If [clipper] is null, the clip will match the layout size and position of
  /// the child.
  ///
  /// The [clipBehavior] must not be null or [Clip.none].
  RenderSliverClipRect({
    RenderSliver? child,
    CustomClipper<Rect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  })  : assert(clipBehavior != null),
        assert(clipBehavior != Clip.none),
        super(child: child, clipper: clipper, clipBehavior: clipBehavior);

  @override
  Rect get _defaultClip => Offset.zero & size;

  @override
  bool hitTest(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final position = computeDirectionalOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
    if (_clipper != null) {
      _updateClip();
      assert(_clip != null);
      if (!_clip!.contains(position)) return false;
    }
    return super.hitTest(result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      _updateClip();
      layer = context.pushClipRect(
        needsCompositing,
        offset,
        _clip!,
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: layer as ClipRectLayer?,
      );
    } else {
      layer = null;
    }
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      if (child != null) {
        super.debugPaintSize(context, offset);
        context.canvas.drawRect(_clip!.shift(offset), _debugPaint!);
        _debugText!.paint(
            context.canvas,
            offset +
                Offset(_clip!.width / 8.0,
                    -_debugText!.text!.style!.fontSize! * 1.1));
      }
      return true;
    }());
  }
}

/// Clips its child using a rounded rectangle.
///
/// By default, [RenderClipRRect] uses its own bounds as the base rectangle for
/// the clip, but the size and location of the clip can be customized using a
/// custom [clipper].
class RenderSliverClipRRect extends _RenderCustomClip<RRect> {
  /// Creates a rounded-rectangular clip.
  ///
  /// The [borderRadius] defaults to [BorderRadius.zero], i.e. a rectangle with
  /// right-angled corners.
  ///
  /// If [clipper] is non-null, then [borderRadius] is ignored.
  ///
  /// The [clipBehavior] argument must not be null or [Clip.none].
  RenderSliverClipRRect({
    RenderSliver? child,
    BorderRadius borderRadius = BorderRadius.zero,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  })  : assert(clipBehavior != null),
        assert(clipBehavior != Clip.none),
        _borderRadius = borderRadius,
        super(child: child, clipper: clipper, clipBehavior: clipBehavior) {
    // `_borderRadius` has a non-nullable return type, but might be null when
    // running with weak checking, so we need to null check it anyway (and
    // ignore the warning that the null-handling logic is dead code).
    assert(_borderRadius != null || clipper != null); // ignore: dead_code
  }

  /// The border radius of the rounded corners.
  ///
  /// Values are clamped so that horizontal and vertical radii sums do not
  /// exceed width/height.
  ///
  /// This value is ignored if [clipper] is non-null.
  BorderRadius get borderRadius => _borderRadius;
  BorderRadius _borderRadius;
  set borderRadius(BorderRadius value) {
    assert(value != null);
    if (_borderRadius == value) return;
    _borderRadius = value;
    _markNeedsClip();
  }

  @override
  RRect get _defaultClip => _borderRadius.toRRect(Offset.zero & size);

  @override
  bool hitTest(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final position = computeDirectionalOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
    if (_clipper != null) {
      _updateClip();
      assert(_clip != null);
      if (!_clip!.contains(position + scrollOffset)) return false;
    }

    return super.hitTest(
      result,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      _updateClip();
      layer = context.pushClipRRect(
        needsCompositing,
        offset,
        _clip!.outerRect.shift(scrollOffset),
        _clip!.shift(scrollOffset),
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: layer as ClipRRectLayer?,
      );
    } else {
      layer = null;
    }
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      if (child != null) {
        super.debugPaintSize(context, offset);
        context.canvas.drawRRect(_clip!.shift(offset), _debugPaint!);
        _debugText!.paint(
            context.canvas,
            offset +
                Offset(_clip!.tlRadiusX,
                    -_debugText!.text!.style!.fontSize! * 1.1));
      }
      return true;
    }());
  }
}

/// Clips its child using a path.
///
/// Takes a delegate whose primary method returns a path that should
/// be used to prevent the child from painting outside the path.
///
/// Clipping to a path is expensive. Certain shapes have more
/// optimized render objects:
///
///  * To clip to a rectangle, consider [RenderClipRect].
///  * To clip to an oval or circle, consider [RenderClipOval].
///  * To clip to a rounded rectangle, consider [RenderClipRRect].
class RenderSliverClipPath extends _RenderCustomClip<Path>
    with SliverBoxAdapterHelperMixin {
  /// Creates a path clip.
  ///
  /// If [clipper] is null, the clip will be a rectangle that matches the layout
  /// size and location of the child. However, rather than use this default,
  /// consider using a [RenderClipRect], which can achieve the same effect more
  /// efficiently.
  ///
  /// The [clipBehavior] argument must not be null or [Clip.none].
  RenderSliverClipPath({
    RenderSliver? child,
    CustomClipper<Path>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  })  : assert(clipBehavior != null),
        assert(clipBehavior != Clip.none),
        super(child: child, clipper: clipper, clipBehavior: clipBehavior);

  @override
  Path get _defaultClip => Path()..addRect(Offset.zero & size);

  @override
  bool hitTest(SliverHitTestResult result,
      {required double mainAxisPosition, required double crossAxisPosition}) {
    final position = computeDirectionalOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
    if (_clipper != null) {
      _updateClip();
      assert(_clip != null);
      if (!_clip!.contains(position)) return false;
    }
    return super.hitTest(result,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      _updateClip();
      layer = context.pushClipPath(
        needsCompositing,
        offset,
        scrollOffset & size,
        _clip!,
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: layer as ClipPathLayer?,
      );
    } else {
      layer = null;
    }
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    assert(() {
      if (child != null) {
        super.debugPaintSize(context, offset);
        context.canvas.drawPath(_clip!.shift(offset), _debugPaint!);
        _debugText!.paint(context.canvas, offset);
      }
      return true;
    }());
  }
}



class RenderDecoratedSliver extends RenderProxySliver
    with SliverBoxAdapterHelperMixin {
  /// Creates a decorated box.
  ///
  /// The [decoration], [position], and [configuration] arguments must not be
  /// null. By default the decoration paints behind the child.
  ///
  /// The [ImageConfiguration] will be passed to the decoration (with the size
  /// filled in) to let it resolve images.
  RenderDecoratedSliver({
    required Decoration decoration,
    DecorationPosition position = DecorationPosition.background,
    ImageConfiguration configuration = ImageConfiguration.empty,
    RenderSliver? child,
  })  : assert(decoration != null),
        assert(position != null),
        assert(configuration != null),
        _decoration = decoration,
        _position = position,
        _configuration = configuration,
        super(child);

  BoxPainter? _painter;

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  Decoration get decoration => _decoration;
  Decoration _decoration;
  set decoration(Decoration value) {
    assert(value != null);
    if (value == _decoration) return;
    _painter?.dispose();
    _painter = null;
    _decoration = value;
    markNeedsPaint();
  }

  /// Whether to paint the box decoration behind or in front of the child.
  DecorationPosition get position => _position;
  DecorationPosition _position;
  set position(DecorationPosition value) {
    assert(value != null);
    if (value == _position) return;
    _position = value;
    markNeedsPaint();
  }

  /// The settings to pass to the decoration when painting, so that it can
  /// resolve images appropriately. See [ImageProvider.resolve] and
  /// [BoxPainter.paint].
  ///
  /// The [ImageConfiguration.textDirection] field is also used by
  /// direction-sensitive [Decoration]s for painting and hit-testing.
  ImageConfiguration get configuration => _configuration;
  ImageConfiguration _configuration;
  set configuration(ImageConfiguration value) {
    assert(value != null);
    if (value == _configuration) return;
    _configuration = value;
    markNeedsPaint();
  }

  @override
  void detach() {
    _painter?.dispose();
    _painter = null;
    super.detach();
    // Since we're disposing of our painter, we won't receive change
    // notifications. We mark ourselves as needing paint so that we will
    // resubscribe to change notifications. If we didn't do this, then, for
    // example, animated GIFs would stop animating when a DecoratedBox gets
    // moved around the tree due to GlobalKey reparenting.
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(
      {required double mainAxisPosition, required double crossAxisPosition}) {
   
    final position = computeDirectionalOffset(
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition);
    return _decoration.hitTest(size, position,
        textDirection: configuration.textDirection);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(size != null);
    _painter ??= _decoration.createBoxPainter(markNeedsPaint);
    final ImageConfiguration filledConfiguration =
        configuration.copyWith(size: size);
    final paintOffset = offset +
        computeDirectionalOffset(
            mainAxisPosition: -constraints.scrollOffset,
            crossAxisPosition: 0.0);
    if (position == DecorationPosition.background) {
      int? debugSaveCount;
      assert(() {
        debugSaveCount = context.canvas.getSaveCount();
        return true;
      }());
      _painter!.paint(context.canvas, paintOffset, filledConfiguration);
      assert(() {
        if (debugSaveCount != context.canvas.getSaveCount()) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                '${_decoration.runtimeType} painter had mismatching save and restore calls.'),
            ErrorDescription(
                'Before painting the decoration, the canvas save count was $debugSaveCount. '
                'After painting it, the canvas save count was ${context.canvas.getSaveCount()}. '
                'Every call to save() or saveLayer() must be matched by a call to restore().'),
            DiagnosticsProperty<Decoration>('The decoration was', decoration,
                style: DiagnosticsTreeStyle.errorProperty),
            DiagnosticsProperty<BoxPainter>('The painter was', _painter,
                style: DiagnosticsTreeStyle.errorProperty),
          ]);
        }
        return true;
      }());
      if (decoration.isComplex) context.setIsComplexHint();
    }
    super.paint(context, offset);
    if (position == DecorationPosition.foreground) {
      _painter!.paint(context.canvas, paintOffset, filledConfiguration);
      if (decoration.isComplex) context.setIsComplexHint();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(_decoration.toDiagnosticsNode(name: 'decoration'));
    properties.add(DiagnosticsProperty<ImageConfiguration>(
        'configuration', configuration));
  }
}
