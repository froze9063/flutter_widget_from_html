part of '../core_ops.dart';

const kAttributeDetailsOpen = 'open';

const kTagDetails = 'details';
const kTagSummary = 'summary';

class TagDetails {
  final WidgetFactory wf;

  late final BuildOp _summaryOp;
  WidgetPlaceholder? _summary;

  TagDetails(this.wf) {
    _summaryOp = BuildOp(
      debugLabel: kTagSummary,
      onTree: (tree) {
        if (tree.isEmpty) {
          return;
        }

        final marker = WidgetBit.inline(
          tree,
          WidgetPlaceholder(
            builder: (context, child) {
              final style = tree.styleBuilder.build(context);
              return HtmlDetailsMarker(style: style.textStyle);
            },
            debugLabel: tree.element.localName,
          ),
        );
        tree.prepend(marker);
      },
      onBuilt: (tree, placeholder) {
        if (_summary != null) {
          return null;
        }

        _summary = placeholder;
        return WidgetPlaceholder(debugLabel: tree.element.localName);
      },
      priority: BuildOp.kPriorityMax,
    );
  }

  BuildOp get buildOp => BuildOp(
        debugLabel: kTagDetails,
        onChild: (tree, subTree) {
          final e = subTree.element;
          if (e.parent != tree.element) {
            return;
          }
          if (e.localName != kTagSummary) {
            return;
          }

          subTree.register(_summaryOp);
        },
        onBuilt: (tree, placeholder) {
          final attrs = tree.element.attributes;
          final open = attrs.containsKey(kAttributeDetailsOpen);

          return placeholder.wrapWith(
            (context, child) {
              final style = tree.styleBuilder.build(context);

              return HtmlDetails(
                open: open,
                child: wf.buildColumnWidget(
                  context,
                  [
                    HtmlSummary(style: style.textStyle, child: _summary),
                    HtmlDetailsContents(child: child),
                  ],
                  dir: style.getDependency(),
                ),
              );
            },
          );
        },
      );
}
