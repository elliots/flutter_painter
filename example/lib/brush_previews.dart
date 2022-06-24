import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

class BrushPreviews extends StatefulWidget {
  const BrushPreviews({Key? key, required this.painterController}) : super(key: key);

  final PainterController painterController;

  @override
  State<BrushPreviews> createState() => _BrushPreviewsState();
}

class _BrushPreviewsState extends State<BrushPreviews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brush Previews"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
          ),
          for (PaintBrushStyle brush in PaintBrushStyle.values)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.6,
                      style: widget.painterController.settings.freeStyle.paintBrushStyle == brush
                          ? BorderStyle.solid
                          : BorderStyle.none,
                    )),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    widget.painterController.settings = widget.painterController.settings.copyWith(
                        freeStyle: widget.painterController.settings.freeStyle.copyWith(paintBrushStyle: brush));
                    setState(() {

                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                    child: BrushPreview(
                      paintBrushStyle: brush,
                      brushColor: widget.painterController.settings.freeStyle.color,
                      brushSize: widget.painterController.settings.freeStyle.strokeWidth,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
