// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // برای HapticFeedback

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator - Amir Mohammad Barani Zade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  String display = '0';
  double? firstValue;
  String? operator;
  bool shouldResetDisplay = false;

  // رنگ‌ها (قابل تغییر در بالا)
  final Color primaryNumberColor = const Color(0xFF4F46E5); // رنگ شماره‌ها
  final Color clearColor = const Color(0xFFDC2626); // قرمز پاک‌کن
  final Color equalColor = const Color(0xFF16A34A); // سبز مساوی
  final Color operatorColor = const Color(0xFFFBBF24); // زرد عملگر
  final Color displayBgColor = const Color(0xFF2563EB); // نمایشگر (آبی تیره)

  // انیمیشن ورود صفحه
  late final AnimationController _entranceController;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  // فرمت نمایش عدد: حذف صفرهای اضافی و محدود کردن اعشار تا 8 رقم معقول
  String _formatNumber(double value) {
    if (value.isInfinite || value.isNaN) return 'خطا';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    // نمایش تا 8 رقم اعشار (یا کمتر اگر لازم باشد) و حذف صفرهای آخر
    String s = value.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    return s;
  }

  void _onButtonTap(String key) {
    HapticFeedback.selectionClick(); // بازخورد لمسی سبک
    setState(() {
      if (key == 'C') {
        // پاک کردن کامل
        display = '0';
        firstValue = null;
        operator = null;
        shouldResetDisplay = false;
        return;
      }
      if (key == '⌫') {
        // حذف یک رقم
        if (display == 'خطا') {
          display = '0';
        } else if (display.length > 1) {
          display = display.substring(0, display.length - 1);
        } else {
          display = '0';
        }
        return;
      }
      if (key == '+' || key == '-' || key == '×' || key == '÷') {
        // ذخیره عدد اول و آماده شدن برای عدد دوم
        firstValue = double.tryParse(display) ?? 0.0;
        operator = key;
        shouldResetDisplay = true;
        return;
      }
      if (key == '=') {
        if (operator == null || firstValue == null) return;
        final second = double.tryParse(display) ?? 0.0;
        double res;
        switch (operator) {
          case '+':
            res = firstValue! + second;
            break;
          case '-':
            res = firstValue! - second;
            break;
          case '×':
            res = firstValue! * second;
            break;
          case '÷':
            if (second == 0) {
              display = 'خطا';
              firstValue = null;
              operator = null;
              shouldResetDisplay = true;
              return;
            } else {
              res = firstValue! / second;
            }
            break;
          default:
            return;
        }
        display = _formatNumber(res);
        firstValue = null;
        operator = null;
        shouldResetDisplay = true;
        return;
      }

      // اعداد و نقطه
      final isDot = key == '.';
      if (shouldResetDisplay || display == '0' || display == 'خطا') {
        // شروع مقدار جدید
        if (isDot) {
          display = '0.';
        } else {
          display = key;
        }
        shouldResetDisplay = false;
      } else {
        if (isDot && display.contains('.')) {
          // جلوگیری از چند نقطه
          return;
        }
        // جلوگیری از طول خیلی زیاد: محدود به 20 کاراکتر برای نمایش
        if (display.length >= 20) return;
        display = display + key;
      }
    });
  }

  // لیست دکمه‌ها با ترتیب نمایش
  List<Map<String, dynamic>> get _buttons => [
        {'text': 'C', 'color': clearColor, 'semantic': 'Clear'},
        {'text': '÷', 'color': operatorColor, 'semantic': 'Divide'},
        {'text': '×', 'color': operatorColor, 'semantic': 'Multiply'},
        {'text': '⌫', 'color': clearColor, 'semantic': 'Backspace'},
        {'text': '7', 'color': primaryNumberColor, 'semantic': 'Seven'},
        {'text': '8', 'color': primaryNumberColor, 'semantic': 'Eight'},
        {'text': '9', 'color': primaryNumberColor, 'semantic': 'Nine'},
        {'text': '-', 'color': operatorColor, 'semantic': 'Minus'},
        {'text': '4', 'color': primaryNumberColor, 'semantic': 'Four'},
        {'text': '5', 'color': primaryNumberColor, 'semantic': 'Five'},
        {'text': '6', 'color': primaryNumberColor, 'semantic': 'Six'},
        {'text': '+', 'color': operatorColor, 'semantic': 'Plus'},
        {'text': '1', 'color': primaryNumberColor, 'semantic': 'One'},
        {'text': '2', 'color': primaryNumberColor, 'semantic': 'Two'},
        {'text': '3', 'color': primaryNumberColor, 'semantic': 'Three'},
        {'text': '=', 'color': equalColor, 'semantic': 'Equals'},
        {'text': '0', 'color': primaryNumberColor, 'semantic': 'Zero'},
        {'text': '.', 'color': primaryNumberColor, 'semantic': 'Decimal'},
      ];

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              // فضای کلی صفحه
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              // ارتفاع نمایشگر: با توجه به ارتفاع کل و نسبت دلخواه
              final displayHeight = height * 0.20; // 20% صفحه برای نمایشگر
              final buttonAreaHeight = height - displayHeight - 24; // margin

              const int columns = 4;
              const int rows = 5;
              final itemHeight = buttonAreaHeight / rows;
              final itemWidth = width / columns;
              final childAspectRatio = itemWidth / itemHeight;

              return Column(
                children: [
                  // فاصله بالا
                  const SizedBox(height: 12),
                  // نمایشگر
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      height: displayHeight,
                      decoration: BoxDecoration(
                        color: displayBgColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            // فقط برای افکت ripple در نمایشگر در صورت تمایل
                            onTap: null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              child: Row(
                                children: [
                                  Expanded(child: Container()),
                                  // نمایش متن با اسکرول افقی
                                  Flexible(
                                    child: SingleChildScrollView(
                                      reverse: true,
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        display,
                                        textDirection: TextDirection.rtl,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          height: 1.05,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // فاصله بین نمایشگر و دکمه‌ها
                  const SizedBox(height: 14),

                  // ناحیه دکمه‌ها
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _buttons.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: childAspectRatio.clamp(0.6, 2.0),
                        ),
                        itemBuilder: (context, index) {
                          final btn = _buttons[index];
                          return _CalculatorButton(
                            label: btn['text'] as String,
                            color: btn['color'] as Color,
                            semantic: btn['semantic'] as String,
                            onTap: () => _onButtonTap(btn['text'] as String),
                            onLongPress: () {
                              // نگه داشتن: اگر Backspace باشه پاک‌کن کامل کن، اگر C باشه نیز پاک‌کن کامل
                              if (btn['text'] == '⌫' || btn['text'] == 'C') {
                                HapticFeedback.vibrate();
                                setState(() {
                                  display = '0';
                                  firstValue = null;
                                  operator = null;
                                  shouldResetDisplay = false;
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // نام سازنده کوچک و شیک
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Developed by Amir Mohammad Barani Zade',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.55),
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// ویجت دکمه با توجه به طراحی: ripple, hover, scale animation, semantics
class _CalculatorButton extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String semantic;
  const _CalculatorButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.onLongPress,
    required this.semantic,
    super.key,
  });

  @override
  State<_CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<_CalculatorButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  bool _hovering = false;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _ctrl.addListener(() {
      setState(() => _scale = 1 - _ctrl.value);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _pressDown() {
    _ctrl.forward();
  }

  void _pressUp() {
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // اندازه لمسی حداقل 56
    return Semantics(
      button: true,
      label: widget.semantic,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _hovering = true);
        },
        onExit: (_) {
          setState(() => _hovering = false);
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            HapticFeedback.selectionClick();
            _pressDown();
          },
          onTapUp: (_) {
            _pressUp();
          },
          onTapCancel: () => _pressUp(),
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: Container(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _hovering
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  // InkWell برای افکت ripple در متریال
                  borderRadius: BorderRadius.circular(12),
                  splashFactory: InkRipple.splashFactory,
                  onTap: () {}, // handled در GestureDetector بالا
                  child: Center(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
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
