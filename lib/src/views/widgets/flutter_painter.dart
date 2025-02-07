import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:floodfill_image/floodfill_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/jagged_brush_drawable.dart';
import 'package:flutter_painter/src/controllers/drawables/path/dot_brushes/pencil_drawable.dart';
import '../../controllers/drawables/path/ink_freehand_drawable.dart';
import '../../controllers/events/selected_object_drawable_removed_event.dart';
import '../../controllers/helpers/renderer_check/renderer_check.dart';
import '../../controllers/drawables/drawable.dart';
import '../../controllers/notifications/notifications.dart';
import '../../controllers/drawables/sized1ddrawable.dart';
import '../../controllers/drawables/shape/shape_drawable.dart';
import '../../controllers/drawables/sized2ddrawable.dart';
import '../../controllers/drawables/object_drawable.dart';
import '../../controllers/events/events.dart';
import '../../controllers/drawables/text_drawable.dart';
import '../../controllers/drawables/path/path_drawables.dart';
import '../../controllers/settings/settings.dart';
import '../painters/painter.dart';
import '../../controllers/painter_controller.dart';
import '../../controllers/helpers/border_box_shadow.dart';
import '../../extensions/painter_controller_helper_extension.dart';
import 'edit_text_widget/edit_text_widget.dart';
import 'painter_controller_widget.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

part 'free_style_widget.dart';

part 'text_widget.dart';

part 'object_widget.dart';

part 'bucket_fill_widget.dart';

part 'shape_widget.dart';

typedef DrawableCreatedCallback = Function(Drawable drawable);

typedef DrawableDeletedCallback = Function(Drawable drawable);

/// Defines the builder used with [FlutterPainter.builder] constructor.
typedef FlutterPainterBuilderCallback = Widget Function(BuildContext context, Widget painter);

/// Widget that allows user to draw on it
class FlutterPainter extends StatelessWidget {
  /// The controller for this painter.
  final PainterController controller;

  /// Callback when a [Drawable] is created internally in [FlutterPainter].
  final DrawableCreatedCallback? onDrawableCreated;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableDeletedCallback? onDrawableDeleted;

  /// Callback when the selected [ObjectDrawable] changes.
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;

  /// Callback when the [PainterSettings] of [PainterController] are updated internally.
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;

  /// The builder used to build this widget.
  ///
  /// Using the default constructor, it will default to returning the [_FlutterPainterWidget].
  ///
  /// Using the [FlutterPainter.builder] constructor, the user can define their own builder and build their own
  /// UI around [_FlutterPainterWidget], which gets re-built automatically when necessary.
  final FlutterPainterBuilderCallback _builder;

  /// Creates a [FlutterPainter] with the given [controller] and optional callbacks.
  const FlutterPainter(
      {Key? key,
      required this.controller,
      this.onDrawableCreated,
      this.onDrawableDeleted,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : _builder = _defaultBuilder,
        super(key: key);

  /// Creates a [FlutterPainter] with the given [controller], [builder] and optional callbacks.
  ///
  /// Using this constructor, the [builder] will be called any time the [controller] updates.
  /// It is useful if you want to build UI that automatically rebuilds on updates from [controller].
  const FlutterPainter.builder(
      {Key? key,
      required this.controller,
      required FlutterPainterBuilderCallback builder,
      this.onDrawableCreated,
      this.onDrawableDeleted,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : _builder = builder,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PainterControllerWidget(
      controller: controller,
      child: ValueListenableBuilder<PainterControllerValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return _builder(
                context,
                _FlutterPainterWidget(
                  key: controller.painterKey,
                  controller: controller,
                  onDrawableCreated: onDrawableCreated,
                  onDrawableDeleted: onDrawableDeleted,
                  onPainterSettingsChanged: onPainterSettingsChanged,
                  onSelectedObjectDrawableChanged: onSelectedObjectDrawableChanged,
                ));
          }),
    );
  }

  /// The default builder that is used when the default [FlutterPainter] constructor is used.
  static Widget _defaultBuilder(BuildContext context, Widget painter) {
    return painter;
  }
}

/// The actual widget that displays and allows control for all drawables.
class _FlutterPainterWidget extends StatelessWidget {
  /// The controller for this painter.
  final PainterController controller;

  /// Callback when a [Drawable] is created internally in [FlutterPainter].
  final DrawableCreatedCallback? onDrawableCreated;

  /// Callback when a [Drawable] is deleted internally in [FlutterPainter].
  final DrawableDeletedCallback? onDrawableDeleted;

  /// Callback when the selected [ObjectDrawable] changes.
  final ValueChanged<ObjectDrawable?>? onSelectedObjectDrawableChanged;

  /// Callback when the [PainterSettings] of [PainterController] are updated internally.
  final ValueChanged<PainterSettings>? onPainterSettingsChanged;

  final Object? _currentScaleEntry = null;

  final GlobalKey trashKey = GlobalKey();

  /// Creates a [_FlutterPainterWidget] with the given [controller] and optional callbacks.
  _FlutterPainterWidget(
      {Key? key,
      required this.controller,
      this.onDrawableCreated,
      this.onDrawableDeleted,
      this.onSelectedObjectDrawableChanged,
      this.onPainterSettingsChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator(
        onGenerateRoute: (settings) => PageRouteBuilder(
            settings: settings,
            opaque: false,
            pageBuilder: (context, animation, secondaryAnimation) {
              // final controller = PainterController.of(context);
              Widget child = _FreeStyleWidget(
                  // controller: controller,
                  child: _TextWidget(
                // controller: controller,
                child: _ShapeWidget(
                  // controller: controller,
                  child: _ObjectWidget(
                    trashKey: trashKey,
                    // controller: controller,
                    interactionEnabled: !(controller.settings.painterMode == PainterMode.zoom || controller.painterMode.isAFreestyleMode),
                    // does not change properly
                    child: Builder(builder: (context) {
                      print("Building painter with drawables of count: ${(controller.value.paintLevelDrawables.length + controller.value.topLevelDrawables.length)}");
                      return CustomPaint(
                        willChange: true,
                        painter: Painter(
                          drawables: (controller.value.paintLevelDrawables.isNotEmpty || controller.value.topLevelDrawables.isNotEmpty)
                              ? (controller.value.paintLevelDrawables + controller.value.topLevelDrawables)
                              : [
                                  PencilDrawable(
                                    path: [const Offset(0, 0), const Offset(0, 0)],
                                    strokeWidth: 1,
                                  ),
                                ], // pencil drawable fixes a bug where the last drawable wouldn't disappear
                          background: controller.value.background,
                        ),
                      );
                    }),
                  ),
                ),
              ));
              return NotificationListener<FlutterPainterNotification>(
                onNotification: onNotification,
                child: Stack(
                  children: [
                    InteractiveViewer(
                      key: controller.transformationWidgetKey,
                      transformationController: controller.transformationController,
                      minScale: controller.settings.scale.minScale,
                      maxScale: controller.settings.scale.maxScale,
                      panEnabled: controller.painterMode == PainterMode.zoom,
                      scaleEnabled: controller.painterMode == PainterMode.zoom || controller.painterMode.isAFreestyleMode,
                      child: controller.painterMode == PainterMode.zoom
                          ? IgnorePointer(
                              child: child,
                            )
                          : child,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: controller.selectedObjectDrawable != null ? 1 : 0,
                          child: Material(
                            key: trashKey,
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.black54,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Builder(builder: (context) {
                                return const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                );
                              }),
                            ),
                          )),
                    ),
                  ],
                ),
              );
            }));
  }

  /// Handles all notifications that might be dispatched from children.
  bool onNotification(FlutterPainterNotification notification) {
    if (notification is DrawableCreatedNotification) {
      onDrawableCreated?.call(notification.drawable);
    } else if (notification is DrawableDeletedNotification) {
      onDrawableDeleted?.call(notification.drawable);
    } else if (notification is SelectedObjectDrawableUpdatedNotification) {
      onSelectedObjectDrawableChanged?.call(notification.drawable);
    } else if (notification is SettingsUpdatedNotification) {
      onPainterSettingsChanged?.call(notification.settings);
    }
    return true;
  }
}
