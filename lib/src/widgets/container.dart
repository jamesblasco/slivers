// @dart=2.12
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:slivers/src/rendering/proxy_box.dart';

import 'basic.dart';


class SliverContainer extends StatelessWidget {
  /// Creates a widget that combines common painting, positioning, and sizing widgets.
  ///
  /// The `height` and `width` values include the padding.
  ///
  /// The `color` and `decoration` arguments cannot both be supplied, since
  /// it would potentially result in the decoration drawing over the background
  /// color. To supply a decoration with a color, use `decoration:
  /// BoxDecoration(color: color)`.
  SliverContainer({
    Key? key,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.margin,
    this.sliver,
    this.clipBehavior = Clip.none,
  })  : assert(margin == null || margin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(clipBehavior != null),
        assert(decoration != null || clipBehavior == Clip.none),
        assert(
            color == null || decoration == null,
            'Cannot provide both a color and a decoration\n'
            'To provide both, use "decoration: BoxDecoration(color: color)".'),
        super(key: key);

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? sliver;

  /// Empty space to inscribe inside the [decoration]. The [child], if any, is
  /// placed inside this padding.
  ///
  /// This padding is in addition to any padding inherent in the [decoration];
  /// see [Decoration.padding].
  final EdgeInsetsGeometry? padding;

  /// The color to paint behind the [child].
  ///
  /// This property should be preferred when the background is a simple color.
  /// For other cases, such as gradients or images, use the [decoration]
  /// property.
  ///
  /// If the [decoration] is used, this property must be null. A background
  /// color may still be painted by the [decoration] even if this property is
  /// null.
  final Color? color;

  /// The decoration to paint behind the [child].
  ///
  /// Use the [color] property to specify a simple solid color.
  ///
  /// The [child] is not clipped to the decoration. To clip a child to the shape
  /// of a particular [ShapeDecoration], consider using a [ClipPath] widget.
  final Decoration? decoration;

  /// The decoration to paint in front of the [child].
  final Decoration? foregroundDecoration;

  /// Empty space to surround the [decoration] and [child].
  final EdgeInsetsGeometry? margin;

  /// The clip behavior when [Container.decoration] is not null.
  ///
  /// Defaults to [Clip.none]. Must be [Clip.none] if [decoration] is null.
  ///
  /// If a clip is to be applied, the [Decoration.getClipPath] method
  /// for the provided decoration must return a clip path. (This is not
  /// supported by all decorations; the default implementation of that
  /// method throws an [UnsupportedError].)
  final Clip clipBehavior;

  EdgeInsetsGeometry? get _paddingIncludingDecoration {
    if (decoration == null || decoration!.padding == null) return padding;
    final EdgeInsetsGeometry? decorationPadding = decoration!.padding;
    if (padding == null) return decorationPadding;
    return padding!.add(decorationPadding!);
  }

  @override
  Widget build(BuildContext context) {
    Widget? current = sliver;


    final EdgeInsetsGeometry? effectivePadding = _paddingIncludingDecoration;
    if (effectivePadding != null)
      current = SliverPadding(padding: effectivePadding, sliver: current);

    if (color != null) current = ColoredBox(color: color!, child: current);

    if (clipBehavior != Clip.none) {
      assert(decoration != null);
      current = SliverClipPath(
        clipper: _DecorationClipper(
          textDirection: Directionality.maybeOf(context),
          decoration: decoration!,
        ),
        clipBehavior: clipBehavior,
        sliver: current,
      );
    }

    if (decoration != null)
      current = DecoratedSliver(decoration: decoration!, sliver: current);

    if (foregroundDecoration != null) {
      current = DecoratedSliver(
        decoration: foregroundDecoration!,
        position: DecorationPosition.foreground,
        sliver: current,
      );
    }

    if (margin != null) current = SliverPadding(padding: margin!, sliver: current);

  /*   if (transform != null)
      current = Transform(
          transform: transform!, child: current, alignment: transformAlignment); */

    return current!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
   
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding,
        defaultValue: null));
    properties.add(DiagnosticsProperty<Clip>('clipBehavior', clipBehavior,
        defaultValue: Clip.none));
    if (color != null)
      properties.add(DiagnosticsProperty<Color>('bg', color));
    else
      properties.add(DiagnosticsProperty<Decoration>('bg', decoration,
          defaultValue: null));
    properties.add(DiagnosticsProperty<Decoration>('fg', foregroundDecoration,
        defaultValue: null));
    properties.add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin,
        defaultValue: null));
  }
}

/// A clipper that uses [Decoration.getClipPath] to clip.
class _DecorationClipper extends CustomClipper<Path> {
  _DecorationClipper({TextDirection? textDirection, required this.decoration})
      : assert(decoration != null),
        textDirection = textDirection ?? TextDirection.ltr;

  final TextDirection textDirection;
  final Decoration decoration;

  @override
  Path getClip(Size size) {
    return decoration.getClipPath(Offset.zero & size, textDirection);
  }

  @override
  bool shouldReclip(_DecorationClipper oldClipper) {
    return oldClipper.decoration != decoration ||
        oldClipper.textDirection != textDirection;
  }
}


class DecoratedSliver extends SingleChildRenderObjectWidget {
  /// Creates a widget that paints a [Decoration].
  ///
  /// The [decoration] and [position] arguments must not be null. By default the
  /// decoration paints behind the child.
  const DecoratedSliver({
    Key? key,
    required this.decoration,
    this.position = DecorationPosition.background,
    Widget? sliver,
  })  : assert(decoration != null),
        assert(position != null),
        super(key: key, child: sliver);

  /// What decoration to paint.
  ///
  /// Commonly a [BoxDecoration].
  final Decoration decoration;

  /// Whether to paint the box decoration behind or in front of the child.
  final DecorationPosition position;

  @override
  RenderDecoratedSliver createRenderObject(BuildContext context) {
    return RenderDecoratedSliver(
      decoration: decoration,
      position: position,
      configuration: createLocalImageConfiguration(context),
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderDecoratedSliver renderObject) {
    renderObject
      ..decoration = decoration
      ..configuration = createLocalImageConfiguration(context)
      ..position = position;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final String label;
    switch (position) {
      case DecorationPosition.background:
        label = 'bg';
        break;
      case DecorationPosition.foreground:
        label = 'fg';
        break;
    }
    properties.add(EnumProperty<DecorationPosition>('position', position,
        level: DiagnosticLevel.hidden));
    properties.add(DiagnosticsProperty<Decoration>(label, decoration));
  }
}
