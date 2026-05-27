import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/admin_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.padding,
    this.borderRadius = 24,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? double.infinity,
        maxHeight: maxHeight ?? double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AdminTheme.cardSurface,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: glowColor?.withValues(alpha: 0.4) ?? Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  glowColor?.withValues(alpha: 0.05) ?? Colors.white.withValues(alpha: 0.03),
                  Colors.white.withValues(alpha: 0.01),
                ],
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const StatusBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
          )
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class AdminButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isPrimary;
  final Color? color;
  final bool isLoading;

  const AdminButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.isPrimary = true,
    this.color,
    this.isLoading = false,
  });

  @override
  State<AdminButton> createState() => _AdminButtonState();
}

class _AdminButtonState extends State<AdminButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? AdminTheme.accentGold;
    
    return MouseRegion(
      cursor: widget.isLoading ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: widget.label.isEmpty ? 12 : 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: widget.isPrimary
                ? LinearGradient(
                    colors: [
                      widget.isLoading ? primaryColor.withValues(alpha: 0.5) : primaryColor,
                      widget.isLoading ? primaryColor.withValues(alpha: 0.4) : primaryColor.withValues(alpha: 0.8)
                    ],
                  )
                : null,
            border: widget.isPrimary ? null : Border.all(color: widget.isLoading ? AdminTheme.borderGold.withValues(alpha: 0.3) : AdminTheme.borderGold),
            boxShadow: (widget.isPrimary && !widget.isLoading)
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isPrimary ? Colors.black : AdminTheme.accentGold,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.isPrimary ? Colors.black : AdminTheme.accentGold, size: 18),
                        if (widget.label.isNotEmpty) const SizedBox(width: 10),
                      ],
                      if (widget.label.isNotEmpty)
                        Flexible(
                          child: Text(
                            widget.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: widget.isPrimary ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    ).animate(target: _isHovered && !widget.isLoading ? 1 : 0).scale(
      duration: 200.ms,
      begin: const Offset(1, 1),
      end: const Offset(1.02, 1.02),
      curve: Curves.easeOut,
    );
  }
}
