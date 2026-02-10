import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double borderRadius;
  final double? width;
  final double height;
  final bool isLoading;
  final bool disabled;
  final Widget? icon;
  final double elevation;
  final TextStyle? textStyle;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.green,
    this.textColor = Colors.white,
    this.borderColor,
    this.borderRadius = 8.0,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
    this.disabled = false,
    this.icon,
    this.elevation = 0,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: disabled || isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? Colors.grey[400] : backgroundColor,
          foregroundColor: textColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: textColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: textStyle ??
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Outlined Button
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double borderRadius;
  final double? width;
  final double height;
  final bool isLoading;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.green,
    this.borderRadius = 8.0,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: color,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
      ),
    );
  }
}

// Text Button
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;

  const CustomTextButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.green,
    this.fontSize,
    this.fontWeight,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize ?? 14,
          fontWeight: fontWeight,
          decoration: decoration,
        ),
      ),
    );
  }
}

// Icon Button
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final double borderRadius;
  final EdgeInsets padding;
  final String? tooltip;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color = Colors.green,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 24,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(8),
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
        padding: padding,
        constraints: const BoxConstraints(),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Floating Action Button
class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final String? tooltip;
  final double size;

  const CustomFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.green,
    this.iconColor = Colors.white,
    this.tooltip,
    this.size = 56,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final button = FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: iconColor,
      child: Icon(
        icon,
        size: 24,
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Button Group
class ButtonGroup extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ButtonGroup({
    Key? key,
    required this.children,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildrenWithSpacing(),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildrenWithSpacing(),
      );
    }
  }

  List<Widget> _buildChildrenWithSpacing() {
    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        if (direction == Axis.horizontal) {
          spacedChildren.add(SizedBox(width: spacing));
        } else {
          spacedChildren.add(SizedBox(height: spacing));
        }
      }
    }
    return spacedChildren;
  }
}

// Loading Button
class LoadingButton extends StatefulWidget {
  final String text;
  final Future Function() onPressed;
  final Color color;
  final Color textColor;
  final double borderRadius;
  final double? width;
  final double height;

  const LoadingButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = Colors.green,
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.width,
    this.height = 48.0,
  }) : super(key: key);

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: widget.text,
      onPressed: _handlePress,
      backgroundColor: widget.color,
      textColor: widget.textColor,
      borderRadius: widget.borderRadius,
      width: widget.width,
      height: widget.height,
      isLoading: _isLoading,
      disabled: _isLoading,
    );
  }
}