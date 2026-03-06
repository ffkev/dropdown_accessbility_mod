import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'form_field_controller.dart';
import 'package:flutter/material.dart';

class FlutterFlowDropDown<T> extends StatefulWidget {
  const FlutterFlowDropDown({
    super.key,
    this.controller,
    this.multiSelectController,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.onMultiSelectChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.labelText,
    this.labelTextStyle,
    this.optionsHasValueKeys = false,
    this.focusNode,
    this.focusColor,
  }) : assert(
          isMultiSelect
              ? (controller == null &&
                  onChanged == null &&
                  multiSelectController != null &&
                  onMultiSelectChanged != null)
              : (controller != null &&
                  onChanged != null &&
                  multiSelectController == null &&
                  onMultiSelectChanged == null),
        );

  final FormFieldController<T?>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final String? hintText;
  final String? searchHintText;
  final List<T> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Function(List<T>?)? onMultiSelectChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final TextStyle textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? labelText;
  final TextStyle? labelTextStyle;
  final bool optionsHasValueKeys;
  final FocusNode? focusNode;
  final Color? focusColor;

  @override
  State<FlutterFlowDropDown<T>> createState() => _FlutterFlowDropDownState<T>();
}

class _FlutterFlowDropDownState<T> extends State<FlutterFlowDropDown<T>> {
  bool get isMultiSelect => widget.isMultiSelect;
  FormFieldController<T?> get controller => widget.controller!;
  FormFieldController<List<T>?> get multiSelectController =>
      widget.multiSelectController!;

  T? get currentValue {
    final value = isMultiSelect
        ? multiSelectController.value?.firstOrNull
        : controller.value;
    return widget.options.contains(value) ? value : null;
  }

  Set<T> get currentValues {
    if (!isMultiSelect || multiSelectController.value == null) {
      return {};
    }
    return widget.options
        .toSet()
        .intersection(multiSelectController.value!.toSet());
  }

  Map<T, String> get optionLabels => Map.fromEntries(
        widget.options.asMap().entries.map(
              (option) => MapEntry(
                option.value,
                widget.optionLabels == null ||
                        widget.optionLabels!.length < option.key + 1
                    ? option.value.toString()
                    : widget.optionLabels![option.key],
              ),
            ),
      );

  EdgeInsetsGeometry get horizontalMargin => widget.margin.clamp(
        EdgeInsetsDirectional.zero,
        const EdgeInsetsDirectional.symmetric(horizontal: double.infinity),
      );

  late void Function() _listener;
  final TextEditingController _textEditingController = TextEditingController();
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  bool _isMenuOpen = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  Color get _defaultFocusColor =>
      widget.focusColor ?? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    if (isMultiSelect) {
      _listener =
          () => widget.onMultiSelectChanged!(multiSelectController.value);
      multiSelectController.addListener(_listener);
    } else {
      _listener = () => widget.onChanged!(controller.value);
      controller.addListener(_listener);
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  bool _focusMenuOverlayItem() {
    int targetIndex = 0;
    if (!isMultiSelect) {
      final current = controller.value;
      if (current != null) {
        final idx = widget.options.indexOf(current);
        if (idx >= 0) targetIndex = idx;
      }
    }

    final myScope = _focusNode.enclosingScope;
    if (myScope == null) return false;

    // Find the popup route's scope by recursively searching from the
    // view scope (parent of our route scope) for any FocusScopeNode
    // that isn't our main route scope.
    final viewScope = myScope.enclosingScope;
    if (viewScope == null) return false;

    final popupScope = _findPopupScope(viewScope, myScope);
    if (popupScope == null) return false;

    final focusableNodes = popupScope.traversalDescendants
        .where((n) => n.canRequestFocus)
        .toList();
    if (focusableNodes.isNotEmpty) {
      final idx = targetIndex.clamp(0, focusableNodes.length - 1);
      focusableNodes[idx].requestFocus();
      return true;
    }
    return false;
  }

  /// Recursively search [parent]'s children for a [FocusScopeNode]
  /// that is not [exclude].
  FocusScopeNode? _findPopupScope(FocusNode parent, FocusScopeNode exclude) {
    for (final child in parent.children) {
      if (child is FocusScopeNode && child != exclude) {
        return child;
      }
      final result = _findPopupScope(child, exclude);
      if (result != null) return result;
    }
    return null;
  }

  void _handleArrowKey(int direction) {
    if (widget.disabled) return;
    final options = widget.options;
    if (options.isEmpty) return;

    if (isMultiSelect) return; // arrow cycling doesn't apply to multi-select

    final current = controller.value;
    final currentIndex = current != null ? options.indexOf(current) : -1;
    final nextIndex = (currentIndex + direction).clamp(0, options.length - 1);
    if (nextIndex != currentIndex) {
      controller.value = options[nextIndex];
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    if (isMultiSelect) {
      multiSelectController.removeListener(_listener);
    } else {
      controller.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _buildDropdownWidget();
    return Focus(
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          _handleArrowKey(1);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _handleArrowKey(-1);
          return KeyEventResult.handled;
        }
        if (_isMenuOpen && event.logicalKey == LogicalKeyboardKey.tab) {
          if (_focusMenuOverlayItem()) {
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: _isFocused
                ? Theme.of(context).colorScheme.primary
                : widget.borderColor,
            width: _isFocused
                ? (widget.borderWidth < 2.0 ? 2.0 : widget.borderWidth)
                : widget.borderWidth,
          ),
          color: _isFocused ? _defaultFocusColor : widget.fillColor,
        ),
        child: Padding(
          padding: _useDropdown2() ? EdgeInsets.zero : widget.margin,
          child: widget.hidesUnderline
              ? DropdownButtonHideUnderline(child: dropdownWidget)
              : dropdownWidget,
        ),
      ),
    ));
  }

  bool _useDropdown2() =>
      widget.isMultiSelect ||
      widget.isSearchable ||
      !widget.isOverButton ||
      widget.maxHeight != null;

  Widget _buildDropdownWidget() =>
      _useDropdown2() ? _buildDropdown() : _buildLegacyDropdown();

  Widget _buildLegacyDropdown() {
    return DropdownButtonFormField<T>(
      value: currentValue,
      hint: _createHintText(),
      items: _createMenuItems(),
      elevation: widget.elevation.toInt(),
      onChanged: widget.disabled ? null : (value) => controller.value = value,
      icon: widget.icon,
      isExpanded: true,
      dropdownColor: widget.fillColor,
      focusNode: _focusNode,
      focusColor: _defaultFocusColor,
      decoration: InputDecoration(
        labelText: widget.labelText == null || widget.labelText!.isEmpty
            ? null
            : widget.labelText,
        labelStyle: widget.labelTextStyle,
        border: widget.hidesUnderline
            ? InputBorder.none
            : const UnderlineInputBorder(),
      ),
    );
  }

  Text? _createHintText() => widget.hintText != null
      ? Text(widget.hintText!, style: widget.textStyle)
      : null;

  ValueKey _getItemKey(T option) {
    final widgetKey = (widget.key as ValueKey).value;
    return ValueKey('$widgetKey ${widget.options.indexOf(option)}');
  }

  List<DropdownMenuItem<T>> _createMenuItems() => widget.options
      .map(
        (option) => DropdownMenuItem<T>(
            key: widget.optionsHasValueKeys ? _getItemKey(option) : null,
            value: option,
            child: Padding(
              padding: _useDropdown2() ? horizontalMargin : EdgeInsets.zero,
              child: Text(optionLabels[option] ?? '', style: widget.textStyle),
            )),
      )
      .toList();

  List<DropdownMenuItem<T>> _createMultiselectMenuItems() => widget.options
      .map(
        (item) => DropdownMenuItem<T>(
          key: widget.optionsHasValueKeys ? _getItemKey(item) : null,
          value: item,
          // Disable default onTap to avoid closing menu when selecting an item
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected =
                  multiSelectController.value?.contains(item) ?? false;
              void toggleItem() {
                multiSelectController.value ??= [];
                isSelected
                    ? multiSelectController.value!.remove(item)
                    : multiSelectController.value!.add(item);
                multiSelectController.update();
                setState(() {});
                menuSetState(() {});
              }

              return InkWell(
                  onTap: toggleItem,
                  onFocusChange: (_) {},
                  child: KeyboardListener(
                    focusNode: FocusNode(skipTraversal: true),
                    onKeyEvent: (event) {
                      if (event is KeyDownEvent &&
                          (event.logicalKey == LogicalKeyboardKey.enter ||
                              event.logicalKey == LogicalKeyboardKey.space)) {
                        toggleItem();
                      }
                    },
                    child: Container(
                      height: double.infinity,
                      padding: horizontalMargin,
                      child: Row(
                        children: [
                          if (isSelected)
                            const Icon(Icons.check_box_outlined)
                          else
                            const Icon(Icons.check_box_outline_blank),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              optionLabels[item]!,
                              style: widget.textStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            },
          ),
        ),
      )
      .toList();

  Widget _buildDropdown() {
    final focusHighlight = _defaultFocusColor;
    final overlayColor = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.focused)) return focusHighlight;
      if (states.contains(WidgetState.hovered)) {
        return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
      }
      return null;
    });
    final iconStyleData = widget.icon != null
        ? IconStyleData(icon: widget.icon!)
        : const IconStyleData();
    return DropdownButton2<T>(
      value: currentValue,
      hint: _createHintText(),
      items: isMultiSelect ? _createMultiselectMenuItems() : _createMenuItems(),
      focusNode: _focusNode,
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: widget.elevation.toInt(),
        overlayColor: overlayColor,
        padding: widget.margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: widget.elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: widget.fillColor,
        ),
        isOverButton: widget.isOverButton,
        offset: widget.menuOffset ?? Offset.zero,
        maxHeight: widget.maxHeight,
        padding: EdgeInsets.zero,
      ),
      onChanged: widget.disabled
          ? null
          : (isMultiSelect ? (_) {} : (val) => widget.controller!.value = val),
      isExpanded: true,
      selectedItemBuilder: (context) => widget.options
          .map(
            (item) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  isMultiSelect
                      ? currentValues
                          .where((v) => optionLabels.containsKey(v))
                          .map((v) => optionLabels[v])
                          .join(', ')
                      : optionLabels[item]!,
                  style: widget.textStyle,
                  maxLines: 1,
                )),
          )
          .toList(),
      dropdownSearchData: widget.isSearchable
          ? DropdownSearchData<T>(
              searchController: _textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: _textEditingController,
                  cursorColor: widget.searchCursorColor,
                  style: widget.searchTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: widget.searchHintText,
                    hintStyle: widget.searchHintTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (optionLabels[item.value] ?? '')
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            )
          : null,
      // This is to clear the search value when you close the menu
      onMenuStateChange: (isOpen) {
        _isMenuOpen = isOpen;
        if (!isOpen && widget.isSearchable) {
          _textEditingController.clear();
        }
      },
    );
  }
}
