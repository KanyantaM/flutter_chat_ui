import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import 'package:markdown/markdown.dart' as md;

class FlyerChatTextMessage extends StatelessWidget {
  static const BorderRadiusGeometry _sentinelBorderRadius = BorderRadius.zero;
  static const Color _sentinelColor = Colors.transparent;
  static const TextStyle _sentinelTextStyle = TextStyle();

  final TextMessage message;
  final int index;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double? onlyEmojiFontSize;
  final Color? sentBackgroundColor;
  final Color? receivedBackgroundColor;
  final TextStyle? sentTextStyle;
  final TextStyle? receivedTextStyle;

  const FlyerChatTextMessage({
    super.key,
    required this.message,
    required this.index,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    this.borderRadius = _sentinelBorderRadius,
    this.onlyEmojiFontSize = 48,
    this.sentBackgroundColor = _sentinelColor,
    this.receivedBackgroundColor = _sentinelColor,
    this.sentTextStyle = _sentinelTextStyle,
    this.receivedTextStyle = _sentinelTextStyle,
  });

  bool get _isOnlyEmoji => message.isOnlyEmoji == true;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ChatTheme>();
    final isSentByMe = context.watch<String>() == message.authorId;
    final backgroundColor = _resolveBackgroundColor(isSentByMe, theme);
    final paragraphStyle = _resolveParagraphStyle(isSentByMe, theme);

    return Container(
      padding: padding,
      decoration: _isOnlyEmoji
          ? null
          : BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius == _sentinelBorderRadius
                  ? theme.shape
                  : borderRadius,
            ),
      child: MarkdownBody(
        data: message.text,
        styleSheet: MarkdownStyleSheet(
          p: _isOnlyEmoji
              ? paragraphStyle?.copyWith(fontSize: onlyEmojiFontSize)
              : paragraphStyle,
        ),
        builders: {
          'code': CodeElementBuilder(),
          'math': MathElementBuilder(),
        },
      ),
    );
  }

  Color? _resolveBackgroundColor(bool isSentByMe, ChatTheme theme) {
    if (isSentByMe) {
      return sentBackgroundColor == _sentinelColor
          ? theme.colors.primary
          : sentBackgroundColor;
    }
    return receivedBackgroundColor == _sentinelColor
        ? theme.colors.surfaceContainer
        : receivedBackgroundColor;
  }

  TextStyle? _resolveParagraphStyle(bool isSentByMe, ChatTheme theme) {
    if (isSentByMe) {
      return sentTextStyle == _sentinelTextStyle
          ? theme.typography.bodyMedium.copyWith(color: theme.colors.onPrimary)
          : sentTextStyle;
    }
    return receivedTextStyle == _sentinelTextStyle
        ? theme.typography.bodyMedium.copyWith(color: theme.colors.onSurface)
        : receivedTextStyle;
  }
}

/// Custom builder for rendering code blocks with syntax highlighting.
class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: HighlightView(
        element.textContent, // Extracts code content correctly
        language: 'dart', // Set dynamically based on detected language
        theme: githubTheme,
        padding: const EdgeInsets.all(8.0),
        textStyle:
            const TextStyle(fontFamily: 'monospace', color: Colors.white),
      ),
    );
  }
}

/// Custom builder for rendering LaTeX equations.
class MathElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Math.tex(
      element.textContent, // Extracts LaTeX content correctly
      textStyle: const TextStyle(fontSize: 16.0),
    );
  }
}
