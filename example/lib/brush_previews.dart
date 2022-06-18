import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter.dart';

class BrushPreviews extends StatefulWidget {
  const BrushPreviews({Key? key}) : super(key: key);

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
          SizedBox(height: 8),
          Text("pen"),
          SizedBox(height: 8),
          BrushPreview(
            mode: PainterMode.pen,
            brushColor: Colors.black, brushSize: 8,
          ),
          SizedBox(height: 8),
          Text("inkFreehand"),
          SizedBox(height: 8),
          BrushPreview(
            mode: PainterMode.inkFreehand,
            brushColor: Colors.black, brushSize: 8,
          ),
          SizedBox(height: 8),
          Text("pencil"),
          SizedBox(height: 8),
          BrushPreview(
            mode: PainterMode.pencil,
            brushColor: Colors.black, brushSize: 8,
          ),
          SizedBox(height: 8),
          Text("pictureBrush1"),
          SizedBox(height: 8),
          BrushPreview(
            mode: PainterMode.pictureBrush1,
            brushColor: Colors.black, brushSize: 8,
          ),
          SizedBox(height: 8),
          Text("genericDotDrawable"),
          SizedBox(height: 8),
          Stack(
            children: [
              BrushPreview(
                mode: PainterMode.dots,
                brushColor: Colors.black, brushSize: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
