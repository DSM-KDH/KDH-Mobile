import 'package:flutter/material.dart';
import 'package:kdh_mobile/constants/color.dart';
import 'package:kdh_mobile/constants/text_style.dart';
import 'package:material_symbols_icons/symbols.dart';

class KdhSearchField extends StatefulWidget {
  const KdhSearchField({
    super.key,
    this.hint = '검색',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  State<KdhSearchField> createState() => _KdhSearchFieldState();
}

class _KdhSearchFieldState extends State<KdhSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _isFocused ? KdhColor.red200 : KdhColor.gray200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 48,
      decoration: BoxDecoration(
        color: KdhColor.background,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: KdhTextStyle.body7.copyWith(color: KdhColor.gray800),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: KdhTextStyle.body7.copyWith(color: KdhColor.gray400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear?.call();
                widget.onChanged?.call('');
              },
              child: const Icon(
                Symbols.cancel_rounded,
                color: KdhColor.gray300,
                size: 18,
                fill: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
