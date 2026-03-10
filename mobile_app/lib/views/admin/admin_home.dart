import 'dart:ui';
import 'package:flutter/material.dart';

class AdminTerminal extends StatefulWidget {
  const AdminTerminal({super.key});

  @override
  State<AdminTerminal> createState() => _AdminTerminalState();
}

class _AdminTerminalState extends State<AdminTerminal> {
  final List<Map<String, dynamic>> _pendingOrders = [
    {
      "id": "CRGO-786-INF",
      "destination": "Chennai-Port",
      "amount": "0.025 ETH",
      "deadline": "2026-03-10T14:30:00",
    }
  ];

  final List<Map<String, dynamic>> _drivers = [
    {"name": "Vineet", "address": "0xCc...a528", "reputation": 92.5, "grade": "A"},
    {"name": "Driver_02", "address": "0xBb...1234", "reputation": 78.0, "grade": "B"},
  ];

  void _assignOrder(String orderId, String driverName) {
    _showSnack("Order $orderId assigned to $driverName", Colors.greenAccent);
    setState(() => _pendingOrders.removeWhere((o) => o['id'] == orderId));
  }

  void _cancelOrder(String orderId) {
    _showSnack("Order $orderId cancelled by Admin", Colors.redAccent);
    setState(() => _pendingOrders.removeWhere((o) => o['id'] == orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("ADMIN COMMAND", 
          style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF000000)],
          ),
        ),
        child: _pendingOrders.isEmpty 
          ? const Center(child: Text("NO PENDING ASSIGNMENTS", style: TextStyle(color: Colors.white24)))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(25, 120, 25, 20),
              itemCount: _pendingOrders.length,
              itemBuilder: (context, index) => _buildOrderActionCard(_pendingOrders[index]),
            ),
      ),
    );
  }

  Widget _buildOrderActionCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order['id'], style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
              Text(order['amount'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text("TO: ${order['destination']}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const Divider(color: Colors.white10, height: 30),
          const Text("SELECT REPUTABLE DRIVER", 
            style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._drivers.map((d) => _buildDriverSelectionTile(order['id'], d)),
          const SizedBox(height: 20),
          _glassButton("CANCEL DISPATCH", Colors.redAccent.withOpacity(0.3), () => _cancelOrder(order['id'])),
        ],
      ),
    );
  }

  Widget _buildDriverSelectionTile(String orderId, Map<String, dynamic> driver) {
    return InkWell(
      onTap: () => _assignOrder(orderId, driver['name']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driver['name'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                Text(driver['address'], style: const TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
            Text("${driver['reputation']} [${driver['grade']}]", 
              style: TextStyle(color: driver['grade'] == "S" || driver['grade'] == "A" ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _glassButton(String label, Color col, VoidCallback tap) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: col),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: tap, 
        child: Text(label, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSnack(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: col, content: Text(msg)));
  }
}