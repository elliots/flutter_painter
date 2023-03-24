import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BouncingClickListener extends StatefulWidget {
  final Widget child;
  final void Function()? onTap;

  const BouncingClickListener({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  _BouncingClickListenerState createState() => _BouncingClickListenerState();
}

class _BouncingClickListenerState extends State<BouncingClickListener> with SingleTickerProviderStateMixin {
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.8).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  TickerFuture? tickerFuture;
  int pointerDown = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) async {
        pointerDown++;
        tickerFuture = _controller.forward();
        tickerFuture?.whenComplete(() {
          tickerFuture = null;
          if (pointerDown == 0) {
            _controller.reverse();
          }
        });
      },
      onTapUp: (_) {
        pointerDown--;
        widget.onTap?.call();
        if (tickerFuture == null) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        pointerDown--;
        if (tickerFuture == null) {
          _controller.reverse();
        }
      },
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
