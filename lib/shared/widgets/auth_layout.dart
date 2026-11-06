import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A single scroll surface keeps the image and form accessible above keyboards
/// and in short landscape windows, without decoding a full-size photo.
class AuthLayout extends StatelessWidget {
  const AuthLayout(
      {super.key, required this.child, required this.isRegistration});
  final Widget child;
  final bool isRegistration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 1050 &&
                  constraints.maxHeight >= 620) {
                return _desktopLayout(context, constraints);
              }
              return _mobileLayout(context, constraints);
            },
          ),
        ),
      ),
    );
  }

  Widget _mobileLayout(BuildContext context, BoxConstraints constraints) {
    final height = constraints.maxHeight;
    final heroHeight = isRegistration
        ? (height * .46).clamp(250.0, 390.0)
        : (height * .38).clamp(220.0, 320.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/focused_scientist_microscope_portrait.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          cacheWidth: 900,
          semanticLabel: 'Focused scientist working at a microscope',
          errorBuilder: (context, error, stack) => const ColoredBox(
            color: Color(0xFF123B66),
            child: Center(
              child:
                  Icon(Icons.biotech_rounded, size: 72, color: Colors.white70),
            ),
          ),
        ),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66101F30),
                  Color(0x22101F30),
                  Color(0x99101F30)
                ],
                stops: [0, .42, 1],
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Go-How Research',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 12)],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Smarter research. Better evidence.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .92),
                  fontSize: 14,
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 10)
                  ],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: Column(
              children: [
                SizedBox(height: heroHeight),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: height - heroHeight),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .94),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: Colors.white70),
                  ),
                  padding: isRegistration
                      ? const EdgeInsets.fromLTRB(22, 24, 22, 28)
                      : const EdgeInsets.fromLTRB(22, 18, 22, 16),
                  child: AutofillGroup(child: child),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context, BoxConstraints constraints) {
    final height = (constraints.maxHeight - 40).clamp(580.0, 900.0);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1480, maxHeight: height),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE3EBF3)),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x160F2742),
                    blurRadius: 36,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(flex: 6, child: _desktopWelcomePanel()),
                  SizedBox(
                    width: 520,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(48, 36, 48, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            Expanded(child: _tab(context, 'Sign in', false)),
                            const SizedBox(width: 10),
                            Expanded(child: _tab(context, 'Sign up', true)),
                          ]),
                          const SizedBox(height: 24),
                          Expanded(
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              child: AutofillGroup(child: child),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _desktopWelcomePanel() => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/focused_scientist_microscope.png',
            fit: BoxFit.cover,
            cacheWidth: 1800,
            semanticLabel: 'Focused scientist working at a microscope',
            errorBuilder: (context, error, stack) => const ColoredBox(
              color: Color(0xFF123B66),
              child: Center(
                  child: Icon(Icons.biotech_rounded,
                      size: 100, color: Colors.white70)),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x18304D6D), Color(0xD910233A)],
              ),
            ),
          ),
          Positioned(
            left: 56,
            right: 56,
            bottom: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.hub_rounded,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Go-How Research',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Smarter research. Better evidence.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Plan studies, collect responses and turn your data into clear, useful findings.',
                  style:
                      TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      );

  Widget _tab(BuildContext context, String label, bool registration) {
    final selected = isRegistration == registration;
    return TextButton(
      onPressed: selected
          ? null
          : () => context.go(registration ? '/register' : '/login'),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor:
            selected ? const Color(0xFFE7F0FB) : const Color(0xFFF6F8FB),
        disabledForegroundColor: const Color(0xFF1565C0),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
