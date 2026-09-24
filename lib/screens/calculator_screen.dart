import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widget/top_snackbar.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _equation = '';
  String _result = '0';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetInput = false;

  void _onNumberPressed(String number) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetInput || _result == '0' || _result == 'Error') {
        _result = number;
        _shouldResetInput = false;
      } else {
        if (_result.length < 15) {
          _result += number;
        }
      }
    });
  }

  void _onDecimalPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetInput || _result == 'Error') {
        _result = '0.';
        _shouldResetInput = false;
      } else if (!_result.contains('.')) {
        _result += '.';
      }
    });
  }


  void _onOperatorPressed(String op) {
    HapticFeedback.mediumImpact();
    setState(() {
      final currentNum = double.tryParse(_result);
      if (currentNum == null) return;

      if (_firstOperand != null && _operator != null && !_shouldResetInput) {
        _evaluate(chainNext: true);
      } else {
        _firstOperand = currentNum;
      }

      _operator = op;
      _equation = '${_formatNumber(_firstOperand!)} $op';
      _shouldResetInput = true;
    });
  }

  void _evaluate({bool chainNext = false}) {
    if (_firstOperand == null || _operator == null) return;

    final secondOperand = double.tryParse(_result);
    if (secondOperand == null) return;

    double calculatedResult = 0;
    bool hasError = false;

    switch (_operator) {
      case '+':
        calculatedResult = _firstOperand! + secondOperand;
        break;
      case '-':
        calculatedResult = _firstOperand! - secondOperand;
        break;
      case '×':
        calculatedResult = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand == 0) {
          hasError = true;
        } else {
          calculatedResult = _firstOperand! / secondOperand;
        }
        break;
    }

    if (hasError) {
      _result = 'Error';
      _equation = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetInput = true;
      TopSnackbar.show(
        context,
        message: 'Cannot divide by zero',
        icon: Icons.error_outline_rounded,
        backgroundColor: Colors.redAccent.shade700,
      );
    } else {
      final formatted = _formatNumber(calculatedResult);
      if (!chainNext) {
        _equation =
            '${_formatNumber(_firstOperand!)} $_operator ${_formatNumber(secondOperand)} =';
        _firstOperand = null;
        _operator = null;
      } else {
        _firstOperand = calculatedResult;
      }
      _result = formatted;
      _shouldResetInput = true;
    }
  }

  void _onEqualsPressed() {
    HapticFeedback.mediumImpact();
    setState(() {
      _evaluate();
    });
  }

  void _onClearAllPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      _result = '0';
      _equation = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetInput = false;
    });
  }

  void _onBackspacePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_shouldResetInput || _result == 'Error') {
        _result = '0';
        _shouldResetInput = false;
        return;
      }
      if (_result.length > 1) {
        _result = _result.substring(0, _result.length - 1);
        if (_result == '-') {
          _result = '0';
        }
      } else {
        _result = '0';
      }
    });
  }

  void _onPercentagePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      final current = double.tryParse(_result);
      if (current != null) {
        final val = current / 100;
        _result = _formatNumber(val);
      }
    });
  }

  void _onToggleSignPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      final current = double.tryParse(_result);
      if (current != null && current != 0) {
        final val = -current;
        _result = _formatNumber(val);
      }
    });
  }

  String _formatNumber(double num) {
    if (num.isInfinite || num.isNaN) return 'Error';
    // If it's an integer value, display without decimals
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    // Limit decimal precision and strip trailing zeroes
    String s = num.toStringAsFixed(6);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    TopSnackbar.show(
      context,
      message: 'Copied $_result to clipboard',
      icon: Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy Result',
            onPressed: _copyResult,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Equation / Previous operation
                    if (_equation.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _equation,
                          style: TextStyle(
                            fontSize: 20,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Result display
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _result,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),

            // Keypad
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Row 1: AC, Backspace, %, ÷
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            label: 'AC',
                            textColor: Colors.redAccent,
                            onTap: _onClearAllPressed,
                          ),
                          _buildButton(
                            icon: Icons.backspace_outlined,
                            textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            onTap: _onBackspacePressed,
                          ),
                          _buildButton(
                            label: '%',
                            textColor: primaryColor,
                            onTap: _onPercentagePressed,
                          ),
                          _buildButton(
                            label: '÷',
                            textColor: primaryColor,
                            isOperator: true,
                            onTap: () => _onOperatorPressed('÷'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row 2: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(label: '7', onTap: () => _onNumberPressed('7')),
                          _buildButton(label: '8', onTap: () => _onNumberPressed('8')),
                          _buildButton(label: '9', onTap: () => _onNumberPressed('9')),
                          _buildButton(
                            label: '×',
                            textColor: primaryColor,
                            isOperator: true,
                            onTap: () => _onOperatorPressed('×'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row 3: 4, 5, 6, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(label: '4', onTap: () => _onNumberPressed('4')),
                          _buildButton(label: '5', onTap: () => _onNumberPressed('5')),
                          _buildButton(label: '6', onTap: () => _onNumberPressed('6')),
                          _buildButton(
                            label: '-',
                            textColor: primaryColor,
                            isOperator: true,
                            onTap: () => _onOperatorPressed('-'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(label: '1', onTap: () => _onNumberPressed('1')),
                          _buildButton(label: '2', onTap: () => _onNumberPressed('2')),
                          _buildButton(label: '3', onTap: () => _onNumberPressed('3')),
                          _buildButton(
                            label: '+',
                            textColor: primaryColor,
                            isOperator: true,
                            onTap: () => _onOperatorPressed('+'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Row 5: +/-, 0, ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton(
                            label: '+/-',
                            textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                            onTap: _onToggleSignPressed,
                          ),
                          _buildButton(label: '0', onTap: () => _onNumberPressed('0')),
                          _buildButton(label: '.', onTap: _onDecimalPressed),
                          _buildButton(
                            label: '=',
                            isEquals: true,
                            onTap: _onEqualsPressed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    String? label,
    IconData? icon,
    Color? textColor,
    bool isOperator = false,
    bool isEquals = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    Color bgColor;
    Color fgColor;

    if (isEquals) {
      bgColor = primaryColor;
      fgColor = Colors.white;
    } else if (isOperator) {
      bgColor = isDark
          ? primaryColor.withValues(alpha: 0.22)
          : primaryColor.withValues(alpha: 0.12);
      fgColor = textColor ?? primaryColor;
    } else {
      bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
      fgColor = textColor ?? (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          elevation: isDark ? 0 : (isEquals ? 3 : 1),
          shadowColor: isEquals
              ? primaryColor.withValues(alpha: 0.4)
              : Colors.black.withValues(alpha: 0.05),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: primaryColor.withValues(alpha: 0.2),
            highlightColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: isEquals
                    ? null
                    : Border.all(
                        color: isDark
                            ? const Color(0x33334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: fgColor, size: 24)
                    : Text(
                        label ?? '',
                        style: TextStyle(
                          fontSize: isEquals || isOperator ? 24 : 22,
                          fontWeight: isEquals || isOperator
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
