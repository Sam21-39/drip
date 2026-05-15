import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drip_core/drip_core.dart';
import 'package:drip_flutter/src/render/drip_custom.dart';

class _CustomOpacityBinding extends DripCustomBinding<double> {
  final RenderOpacity renderObject;

  _CustomOpacityBinding(super.source, this.renderObject);

  @override
  void applyValue(double value) {
    renderObject.opacity = value.clamp(0.0, 1.0);
  }

  @override
  void Function() get markNeedsMethod => renderObject.markNeedsPaint;
}

class _CustomOpacityWidget extends SingleChildRenderObjectWidget {
  final DripState<double> state;
  const _CustomOpacityWidget({required this.state});

  @override
  RenderOpacity createRenderObject(BuildContext context) {
    final ro = RenderOpacity(opacity: state.value);
    // User must manually manage the lifecycle of the custom binding
    final binding = _CustomOpacityBinding(state, ro);
    binding.initBinding();
    // In a real scenario, the user would store the binding or use a mixin
    return ro;
  }
}

void main() {
  group('DripCustomBinding Tests', () {
    testWidgets('C-1.1: Custom binding updates RenderObject', (tester) async {
      final state = dripState(0.5);

      await tester.pumpWidget(MaterialApp(
        home: _CustomOpacityWidget(state: state),
      ));

      final renderObject =
          tester.renderObject<RenderOpacity>(find.byType(_CustomOpacityWidget));
      expect(renderObject.opacity, 0.5);

      state.write(0.8);
      await tester.pump();

      expect(renderObject.opacity, 0.8);
    });
  });
}
