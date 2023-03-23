part of 'flutter_painter.dart';

/// Flutter widget to detect user input and request drawing [FreeStyleDrawable]s.
class _TextWidget extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Creates a [_TextWidget] with the given [controller] and [child] widget.
  const _TextWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _TextWidgetState createState() => _TextWidgetState();
}

class _TextWidgetState extends State<_TextWidget> {
  /// The currently selected text drawable that is being edited.
  TextDrawable? selectedDrawable;

  /// Subscription to the events coming from the controller.
  ///
  /// This is used to listen to new text events to create new text drawables.
  StreamSubscription<PainterEvent>? controllerEventSubscription;

  @override
  void initState() {
    super.initState();

    // Listen to the stream of events from the paint controller
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      controllerEventSubscription = PainterController.of(context).events.listen((event) {
        // When an [AddTextPainterEvent] event is received, create a new text drawable
        if (event is AddTextPainterEvent) createDrawable();
      });
    });
  }

  @override
  void dispose() {
    // Cancel subscription to events from painter controller
    controllerEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ObjectDrawableReselectedNotification>(
      onNotification: onObjectDrawableNotification,
      child: widget.child,
    );
  }

  /// Getter for [TextSettings] from `widget.controller.value` to make code more readable.
  TextSettings get settings => PainterController.of(context).value.settings.text;

  /// Handles any [ObjectDrawableReselectedNotification] that might be dispatched in the widget tree.
  ///
  /// This handles notifications of type [ObjectDrawableReselectedNotification] to edit
  /// an existing [TextDrawable].
  bool onObjectDrawableNotification(ObjectDrawableReselectedNotification notification) {
    print("Handling text selected notification");
    final drawable = notification.drawable;

    if (drawable is TextDrawable) {
      final oldDrawable = PainterController.of(context).topLevelDrawables.firstWhere((element) {
        if (element is TextDrawable) {
          if (element.key == drawable.key) {
            return true;
          }
        }
        return false;
      }, orElse: () => drawable) as TextDrawable;
      PainterController.of(context).removeDrawable(oldDrawable, false, newAction: true);
      openTextEditor(oldDrawable);
      // Mark notification as handled
      return true;
    }
    // Mark notification as not handled
    return false;
  }

  /// Creates a new [TextDrawable], adds it to the controller and opens the editing widget.
  void createDrawable() {
    if (selectedDrawable != null) return;

    // Calculate the center of the painter
    final renderBox = PainterController.of(context).painterKey.currentContext?.findRenderObject() as RenderBox?;
    final center = renderBox == null
        ? Offset.zero
        : Offset(
            renderBox.size.width / 2,
            renderBox.size.height / 2,
          );

    // Create a new hidden empty entry in the center of the painter
    final drawable = TextDrawable(
      key: UniqueKey(),
      text: '',
      position: center,
      style: settings.textStyle,
      hidden: true,
    );

    if (mounted) {
      setState(() {
        selectedDrawable = drawable;
      });
    }

    openTextEditor(drawable, true).then((value) {
      if (mounted) {
        setState(() {
          selectedDrawable = null;
        });
      }
    });
  }

  /// Opens an editor to edit the text of [drawable].
  Future<void> openTextEditor(TextDrawable drawable, [bool isNew = false]) async {
    await Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) => EditTextPage(
              controller: PainterController.of(this.context),
              drawable: drawable,
              isNew: isNew,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
              opacity: animation,
              child: child,
            )));
  }
}
