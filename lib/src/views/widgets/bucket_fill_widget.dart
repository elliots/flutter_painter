part of 'flutter_painter.dart';

/// Flutter widget to move, scale and rotate [_BucketFillWidget]s.
class _BucketFillWidget extends StatefulWidget {
  const _BucketFillWidget({
    Key? key,
  }) : super(key: key);

  @override
  _BucketFillWidgetState createState() => _BucketFillWidgetState();
}

class _BucketFillWidgetState extends State<_BucketFillWidget> {
  MemoryImage? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timestamp) {
      PainterController.of(context)
          .renderImage(PainterController.of(context).value.background!.getSize())
          .then((value) async {
        image = MemoryImage(Uint8List.view((await value.toByteData(format: ui.ImageByteFormat.png))!.buffer));
        setState(() {});
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (image == null)
      return Container(
        height: PainterController.of(context).value.background!.getSize().height,
        width: PainterController.of(context).value.background!.getSize().width,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    return Container(
      child: FloodFillImage(
        loadingWidget: Container(
          height: PainterController.of(context).value.background!.getSize().height,
          width: PainterController.of(context).value.background!.getSize().width,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        imageProvider: image!,
        fillColor: PainterController.of(context).settings.freeStyle.color,
        avoidColor: [Colors.transparent],
        tolerance: 10,
        onFloodFillEnd: (ui.Image image) {
          PainterController.of(context).addImage(image);
          PainterController.of(context).groupDrawables(newAction: false);
        },
      ),
    );
  }
}
