import 'package:flutter/material.dart' hide ScrollView;
import 'package:flutter/rendering.dart';

class ScrollView extends CustomScrollView {
  const ScrollView({Key? key, required List<Widget> slivers})
      : super(key: key, slivers: slivers);

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return super
        .buildSlivers(context)
        .map((child) => Sliver(child: child))
        .toList();
  }
}

class Sliver extends SingleChildRenderObjectWidget {
  Sliver({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _RenderProxySliver createRenderObject(BuildContext context) {
    return _RenderProxySliver();
  }

  @override
  SingleChildRenderObjectElement createElement() {
    return _SingleChildRenderObjectElement(this);
  }
}

class _RenderProxySliver extends RenderProxySliver {}

class _SingleChildRenderObjectElement extends SingleChildRenderObjectElement {
  _SingleChildRenderObjectElement(SingleChildRenderObjectWidget widget)
      : super(widget);

  RenderSliverToBoxAdapter? _adapter;

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    final RenderObject proxyChild;
    if (child is RenderBox) {
      _adapter ??= RenderSliverToBoxAdapter();
      _adapter!.child = child;
      proxyChild = _adapter!;
    } else {
      proxyChild = child;
      assert(renderObject.debugValidateChild(child));
    }
    super.insertRenderObjectChild(proxyChild, slot);
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    final RenderObjectWithChildMixin<RenderObject> renderObject =
        this.renderObject as RenderObjectWithChildMixin<RenderObject>;
    assert(slot == null);
    assert(() {
      final RenderObject proxyChild;
      if (child is RenderBox) {
        assert(_adapter != null);
        proxyChild = _adapter!;
      } else {
        proxyChild = child;
      }
      return renderObject.child == proxyChild;
    }());
    renderObject.child = null;
    assert(renderObject == this.renderObject);
  }

  @override
  void unmount() {
    _adapter?.dispose();
    _adapter = null;
    super.unmount();
  }
}
