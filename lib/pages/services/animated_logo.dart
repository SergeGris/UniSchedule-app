import 'package:flutter/material.dart';

import '../../utils.dart';

//TODO RENAME
class AnimatedLogo extends StatefulWidget {
    const AnimatedLogo(this.asset, {
            super.key,
            this.animationDuration = const Duration(seconds: 2),
            this.size = 100.0});

    final String asset;
    final Duration animationDuration;
    final double size;

    @override
    State<StatefulWidget> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with TickerProviderStateMixin {
    late AnimationController _controller;

    @override
    void initState() {
        super.initState();
        _controller = AnimationController(duration: widget.animationDuration, vsync: this);
        _controller.forward();
    }

    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return ScaleTransition(
            scale: Tween(
                begin: 0.5,
                end: 1.0,
            ).animate(
                CurvedAnimation(
                    parent: _controller,
                    curve: Curves.elasticOut,
                ),
            ),
            child: SizedBox(
                height: widget.size,
                width: widget.size,
                child: Image.asset(widget.asset),
            ),
        );
    }
}
