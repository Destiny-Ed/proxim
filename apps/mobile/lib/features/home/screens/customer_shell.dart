import 'package:flutter/material.dart';
import '../../providers/screens/browse_providers_screen.dart';
import '../../jobs/screens/jobs_list_screen.dart';
import '../../wallet/screens/wallet_screen.dart';
import '../../profile/screens/profile_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  final _pages = const [
    BrowseProvidersScreen(),
    JobsListScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE3E2DE))),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Browse'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
