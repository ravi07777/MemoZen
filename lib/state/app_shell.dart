import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = 0;
    if (location.startsWith('/topics')) currentIndex = 1;
    if (location.startsWith('/calendar')) currentIndex = 3;
    if (location.startsWith('/settings')) currentIndex = 4;

    return Scaffold(
      body: child,
      floatingActionButton: SizedBox(
        width: 58,
        height: 58,
        child: FloatingActionButton(
          onPressed: () => context.push('/add-topic'),
          elevation: 4,
          child: const Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: theme.cardTheme.color,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(context, Icons.home_outlined, Icons.home, 'Home', 0, currentIndex, '/home'),
            _navItem(context, Icons.menu_book_outlined, Icons.menu_book, 'Topics', 1, currentIndex, '/topics'),
            const SizedBox(width: 48),
            _navItem(context, Icons.calendar_month_outlined, Icons.calendar_month, 'Calendar', 3, currentIndex, '/calendar'),
            _navItem(context, Icons.person_outline, Icons.person, 'Account', 4, currentIndex, '/settings'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData iconOutlined, IconData iconFilled, String label, int index, int currentIndex, String route) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => context.go(route),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? iconFilled : iconOutlined,
              size: 24,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
