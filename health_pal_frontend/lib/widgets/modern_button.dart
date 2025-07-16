import 'package:flutter/material.dart';
import 'package:health_pal_frontend/theme/app_theme.dart';

enum ModernButtonType { primary, secondary, outline, text }

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => _animationController.forward()
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) => _animationController.reverse()
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => _animationController.reverse()
          : null,
      onTap: widget.onPressed != null && !widget.isLoading
          ? widget.onPressed
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isFullWidth ? double.infinity : null,
              padding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: _getGradient(),
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                border: _getBorder(),
                boxShadow: _getShadow(),
              ),
              child: Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _getTextColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!widget.isLoading)
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  LinearGradient? _getGradient() {
    switch (widget.type) {
      case ModernButtonType.primary:
        return widget.onPressed != null && !widget.isLoading
            ? AppTheme.primaryGradient
            : null;
      default:
        return null;
    }
  }

  Color? _getBackgroundColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return AppTheme.textLight.withOpacity(0.3);
    }

    switch (widget.type) {
      case ModernButtonType.primary:
        return null; // Uses gradient
      case ModernButtonType.secondary:
        return AppTheme.backgroundGrey;
      case ModernButtonType.outline:
        return Colors.transparent;
      case ModernButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return AppTheme.textLight;
    }

    switch (widget.type) {
      case ModernButtonType.primary:
        return Colors.white;
      case ModernButtonType.secondary:
        return AppTheme.textDark;
      case ModernButtonType.outline:
        return AppTheme.primaryGreen;
      case ModernButtonType.text:
        return AppTheme.primaryGreen;
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case ModernButtonType.outline:
        return Border.all(
          color: widget.onPressed != null && !widget.isLoading
              ? AppTheme.primaryGreen
              : AppTheme.textLight.withOpacity(0.3),
          width: 2,
        );
      default:
        return null;
    }
  }

  List<BoxShadow>? _getShadow() {
    if (widget.onPressed == null || widget.isLoading) {
      return null;
    }

    switch (widget.type) {
      case ModernButtonType.primary:
        return AppTheme.buttonShadow;
      case ModernButtonType.secondary:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return null;
    }
  }
}