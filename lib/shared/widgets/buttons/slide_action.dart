import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class SlideAction extends StatefulWidget {
  final Future<void> Function() onSubmit;
  final String text;
  final String submittingText;
  final String completedText;
  final Color innerColor;
  final Color outerColor;
  final bool isCompleted;

  const SlideAction({
    super.key,
    required this.onSubmit,
    this.text = 'Slide to Action',
    this.submittingText = 'Processing...',
    this.completedText = 'Completed',
    this.innerColor = Colors.white,
    this.outerColor = AppColors.primaryLight,
    this.isCompleted = false,
  });

  @override
  State<SlideAction> createState() => _SlideActionState();
}

class _SlideActionState extends State<SlideAction> {
  double _position = 0;
  bool _isSubmitting = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isSubmitting || widget.isCompleted) return;
    setState(() {
      _position += details.delta.dx;
      if (_position < 0) _position = 0;
      if (_position > maxWidth - 60) _position = maxWidth - 60;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) async {
    if (_isSubmitting || widget.isCompleted) return;
    
    if (_position > maxWidth - 70) {
      // Completed slide
      setState(() {
        _position = maxWidth - 60;
        _isSubmitting = true;
      });
      await widget.onSubmit();
      setState(() {
        _isSubmitting = false;
      });
    } else {
      // Snap back
      setState(() {
        _position = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final currentPosition = widget.isCompleted ? maxWidth - 60 : _position;

        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: widget.isCompleted 
                ? Colors.green.withValues(alpha: 0.2)
                : widget.outerColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.isCompleted ? Colors.green : widget.outerColor.withValues(alpha: 0.3),
            ),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  _isSubmitting
                      ? widget.submittingText
                      : (widget.isCompleted ? widget.completedText : widget.text),
                  style: TextStyle(
                    color: widget.isCompleted ? Colors.green.shade700 : widget.outerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _isSubmitting || widget.isCompleted ? const Duration(milliseconds: 300) : Duration.zero,
                left: currentPosition,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, maxWidth),
                  onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, maxWidth),
                  child: Container(
                    width: 52,
                    decoration: BoxDecoration(
                      color: widget.isCompleted ? Colors.green : widget.outerColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isCompleted ? Colors.green : widget.outerColor).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              widget.isCompleted ? LucideIcons.check : LucideIcons.chevronRight,
                              color: widget.innerColor,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
