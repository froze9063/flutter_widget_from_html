part of '../core_ops.dart';

const kCssBackground = 'background';
const kCssBackgroundColor = 'background-color';

class StyleBgColor {
  final WidgetFactory wf;

  StyleBgColor(this.wf);

  BuildOp get buildOp => BuildOp(
        onTreeFlattening: (meta, tree) {
          final bgColor = _parseColor(wf, meta);
          if (bgColor == null) {
            return false;
          }

          meta.tsb.enqueue(_tsb, bgColor);
          return true;
        },
        onWidgets: (meta, widgets) {
          final color = _parseColor(wf, meta);
          if (color == null) {
            return null;
          }

          return listOrNull(
                wf.buildColumnPlaceholder(meta, widgets)?.wrapWith(
                      (_, child) =>
                          wf.buildDecoration(meta, child, color: color),
                    ),
              ) ??
              widgets;
        },
        onWidgetsIsOptional: true,
        priority: StyleBorder.kPriorityBoxModel5k + 1,
      );

  Color? _parseColor(WidgetFactory wf, BuildMetadata meta) {
    Color? color;
    for (final style in meta.styles) {
      switch (style.property) {
        case kCssBackground:
          for (final expression in style.values) {
            color = tryParseColor(expression) ?? color;
          }
          break;
        case kCssBackgroundColor:
          color = tryParseColor(style.value) ?? color;
          break;
      }
    }

    return color;
  }

  static HtmlStyle _tsb(HtmlStyle p, Color c) =>
      p.copyWith(style: p.style.copyWith(background: Paint()..color = c));
}
