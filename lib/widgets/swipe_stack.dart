import 'package:flutter/material.dart';

class SwipeStack extends StatefulWidget {
  final List<Widget> children;
  final Function(int)? onSwipeLeft;
  final Function(int)? onSwipeRight;
  final Function()? onStackFinished;

  const SwipeStack({
    super.key,
    required this.children,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onStackFinished,
  });

  @override
  State<SwipeStack> createState() => _SwipeStackState();
}

class _SwipeStackState extends State<SwipeStack> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Alignment _dragAlignment = Alignment.center;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _controller.addListener(() {
      setState(() {
        _dragAlignment = Alignment.lerp(
          _dragAlignment,
          _dragAlignment.x > 0 ? const Alignment(5, 0) : const Alignment(-5, 0),
          _controller.value,
        )!;
      });
      if (_controller.status == AnimationStatus.completed) {
        _onSwipeComplete();
      }
    });
  }

  void _onSwipeComplete() {
    if (_dragAlignment.x > 0) {
      widget.onSwipeRight?.call(_currentIndex);
    } else {
      widget.onSwipeLeft?.call(_currentIndex);
    }

    setState(() {
      _currentIndex++;
      _dragAlignment = Alignment.center;
    });
    _controller.reset();

    if (_currentIndex >= widget.children.length) {
      widget.onStackFinished?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.children.length) {
      return const Center(child: Text("No more profiles!", style: TextStyle(color: Colors.white)));
    }

    return Stack(
      children: [
        // Next Card (Preview)
        if (_currentIndex + 1 < widget.children.length)
          Transform.scale(
            scale: 0.9 + (0.1 * (_dragAlignment.x.abs() / 2).clamp(0, 1)),
            child: widget.children[_currentIndex + 1],
          ),
        
        // Current Card
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragAlignment += Alignment(
                details.delta.dx / (MediaQuery.of(context).size.width / 2),
                0, // Only horizontal drag for cards
              );
            });
          },
          onHorizontalDragEnd: (details) {
            if (_dragAlignment.x.abs() > 2) {
              _controller.forward();
            } else {
              setState(() {
                _dragAlignment = Alignment.center;
              });
            }
          },
          child: Align(
            alignment: _dragAlignment,
            child: Transform.rotate(
              angle: _dragAlignment.x * 0.1,
              child: widget.children[_currentIndex],
            ),
          ),
        ),
      ],
    );
  }
}
