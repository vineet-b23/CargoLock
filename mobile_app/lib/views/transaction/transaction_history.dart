import 'package:flutter/material.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("BLOCKCHAIN LOGS", style: TextStyle(fontSize: 14, letterSpacing: 2)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("BLOCK #0x${8234 + index}", 
                      style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'monospace', fontSize: 12)),
                    const Icon(Icons.link, color: Colors.white24, size: 16),
                  ],
                ),
                const SizedBox(height: 5),
                const Text("TX_HASH: f47ac10b-58cc-4372-a567-0e02b2c3d479",
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'monospace')),
                const SizedBox(height: 5),
                const Text("STATUS: [ESCROW_LOCKED]", 
                  style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
  }
}