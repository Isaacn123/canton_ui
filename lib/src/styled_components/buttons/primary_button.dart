import 'package:canton_ui/canton_ui.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';

const EdgeInsets _kButtonPadding = EdgeInsets.all(16.0);
const EdgeInsets _kBackgroundButtonPadding = EdgeInsets.symmetric(
  vertical: 14.0,
  horizontal: 64.0,
);

/// Default button with light animations
class CantonPrimaryButton extends StatefulWidget {
  const CantonPrimaryButton({
    Key? key,
    this.prefixIcon,
    this.suffixIcon,
    this.buttonText,
    this.iconColor,
    this.shape,
    this.textColor,
    this.padding,
    this.border,
    this.color,
    this.iconSize,
    this.iconPadding,
    this.containerHeight,
    this.containerWidth,
    this.disabledColor = CupertinoColors.quaternarySystemFill,
    this.minSize = kMinInteractiveDimensionCupertino,
    this.pressedOpacity = 0.3,
    this.borderRadius,
    this.alignment,
    this.onPressed,
  })  : assert(pressedOpacity == null ||
            (pressedOpacity >= 0.0 && pressedOpacity <= 1.0)),
        super(key: key);

  final Widget? prefixIcon, suffixIcon;
  final String? buttonText;
  final BorderSide? border;
  final EdgeInsetsGeometry? padding;
  final Color? color, textColor, iconColor;
  final Color disabledColor;
  final double? iconSize, iconPadding, containerWidth, containerHeight;
  final VoidCallback? onPressed;
  final double? minSize;
  final double? pressedOpacity;
  final BorderRadius? borderRadius;
  final MainAxisAlignment? alignment;
  final ShapeBorder? shape;
  bool get enabled => onPressed != null;

  @override
  // ignore: library_private_types_in_public_api
  _CantonPrimaryButtonState createState() => _CantonPrimaryButtonState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }
}

class _CantonPrimaryButtonState extends State<CantonPrimaryButton>
    with SingleTickerProviderStateMixin {
  static const Duration kFadeOutDuration = Duration(milliseconds: 10);
  static const Duration kFadeInDuration = Duration(milliseconds: 100);
  final Tween<double> _opacityTween = Tween<double>(begin: 1.0);

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 0.0,
      vsync: this,
    );
    _opacityAnimation = _animationController
        .drive(CurveTween(curve: Curves.decelerate))
        .drive(_opacityTween);
    _setTween();
  }

  @override
  void didUpdateWidget(CantonPrimaryButton old) {
    super.didUpdateWidget(old);
    _setTween();
  }

  void _setTween() {
    _opacityTween.end = widget.pressedOpacity ?? 1.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _buttonHeldDown = false;

  void _handleTapDown(TapDownDetails event) {
    if (!_buttonHeldDown) {
      _buttonHeldDown = true;
      _animate();
    }
  }

  void _handleTapUp(TapUpDetails event) {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _handleTapCancel() {
    if (_buttonHeldDown) {
      _buttonHeldDown = false;
      _animate();
    }
  }

  void _animate() {
    if (_animationController.isAnimating) return;
    final bool wasHeldDown = _buttonHeldDown;
    final TickerFuture ticker = _buttonHeldDown
        ? _animationController.animateTo(1.0, duration: kFadeOutDuration)
        : _animationController.animateTo(0.0, duration: kFadeInDuration);
    ticker.then<void>((void value) {
      if (mounted && wasHeldDown != _buttonHeldDown) _animate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final bool enabled = widget.enabled;

    Widget prefixIconWidget() {
      if (widget.prefixIcon == null) return Container();

      return Container(child: widget.prefixIcon);
    }

    Widget suffixIconWidget() {
      if (widget.suffixIcon == null) return Container();

      return Container(
        padding: const EdgeInsets.only(left: 16.0),
        child: widget.suffixIcon,
      );
    }

    Widget textWidget() {
      if (widget.buttonText == null) return Container();

      return Text(
        widget.buttonText!,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: enabled
                  ? (widget.textColor ??
                      (widget.color!.value ==
                              Theme.of(context).primaryColor.value
                          ? CantonColors.white
                          : Theme.of(context).colorScheme.primary))
                  : Theme.of(context).colorScheme.secondaryContainer,
            ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? _handleTapDown : null,
      onTapUp: enabled ? _handleTapUp : null,
      onTapCancel: enabled ? _handleTapCancel : null,
      onTap: widget.onPressed,
      child: Semantics(
        button: true,
        child: ConstrainedBox(
          constraints: widget.minSize == null
              ? const BoxConstraints()
              : BoxConstraints(
                  minWidth: widget.minSize!,
                  minHeight: widget.minSize!,
                ),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                shape: widget.shape ??
                    RoundedRectangleBorder(
                        borderRadius: widget.borderRadius ??
                            BorderRadius.circular(kDefaultBorderRadius),
                        side: widget.border ?? BorderSide.none),
                color: widget.color != null && !enabled
                    ? Theme.of(context).colorScheme.secondary
                    : widget.color ?? Theme.of(context).primaryColor,
              ),
              child: Container(
                height: widget.containerHeight ?? 55.0,
                width: widget.containerWidth ?? size.width,
                padding: widget.padding ??
                    ((![CantonColors.transparent, null].contains(widget.color))
                        ? _kButtonPadding
                        : _kBackgroundButtonPadding),
                child: (![CantonColors.transparent, null]
                        .contains(widget.color))
                    ? Row(
                        mainAxisAlignment:
                            widget.alignment ?? MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          prefixIconWidget(),
                          textWidget(),
                          suffixIconWidget(),
                        ],
                      )
                    : [widget.prefixIcon, widget.suffixIcon].contains(null)
                        ? Row(
                            mainAxisAlignment: widget.alignment ??
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              prefixIconWidget(),
                              textWidget(),
                              suffixIconWidget(),
                            ],
                          )
                        : textWidget(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
