import 'package:flutter/material.dart';

void main() {
  runApp(const ProximAdmin());
}

class ProximAdmin extends StatelessWidget {
  const ProximAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxim Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Proxim Admin')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Analytics dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('Wire to backend metrics endpoints when ready.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
