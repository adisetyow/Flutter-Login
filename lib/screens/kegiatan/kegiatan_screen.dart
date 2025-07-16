import 'package:flutter/material.dart';

class KegiatanScreen extends StatelessWidget {
  const KegiatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(' Kegiatan')),
      body: const Center(child: Text('Halaman kegiatan')),
    );
  }
}
