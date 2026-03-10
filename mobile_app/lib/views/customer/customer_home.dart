import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  bool _termsAccepted = false;

  final String _paymentUrl = "https://cargo-lock-jc9a.vercel.app/customer.com"; 

  
  Future<void> _handlePaymentRedirect() async {
    if (!_termsAccepted) {
      _showSnack("Please accept the Terms & Conditions first", Colors.orangeAccent);
      return;
    }

    final Uri url = Uri.parse(_paymentUrl);
    
    try {
      if (await canLaunchUrl(url)) {
        _showSnack("Redirecting to Sepolia Gateway...", Colors.blueAccent);
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, 
        );
      } else {
        _showSnack("Could not launch payment gateway", Colors.redAccent);
      }
    } catch (e) {
      debugPrint("Redirection Error: $e");
      _showSnack("Connection failed. Check your internet.", Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("CUSTOMER TERMINAL", 
          style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomLeft,
            radius: 1.5,
            colors: [Color(0xFF001A33), Color(0xFF00050A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummary(),
                const SizedBox(height: 30),
                const Text("TERMS & CONDITIONS", 
                  style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildTermsSection(),
                const SizedBox(height: 30),
                _buildAcceptCheckbox(),
                const SizedBox(height: 40),
                _glassButton(
                  "PROCEED TO PAY VIA SEPOLIA ETH", 
                  Colors.cyanAccent, 
                  _handlePaymentRedirect,
                  isPrimary: true
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _summaryRow("ORDER ID", "CRGO-786-INF"),
          const Divider(color: Colors.white10, height: 30),
          _summaryRow("AMOUNT", "0.025 ETH"),
          const Divider(color: Colors.white10, height: 30),
          _summaryRow("NETWORK", "SEPOLIA TESTNET"),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTermsSection() {
    final List<String> terms = [
      "Payment is non-reversible once written to the Smart Contract.",
      "Funds will remain in escrow until AI verification is complete.",
      "Driver reputation is updated only after transaction finality.",
      "SepoliaETH has no real-world value and is for testing only."
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: terms.map((term) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: Colors.cyanAccent),
              const SizedBox(width: 12),
              Expanded(child: Text(term, style: const TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAcceptCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _termsAccepted = !_termsAccepted),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _termsAccepted ? Colors.cyanAccent : Colors.white24),
              color: _termsAccepted ? Colors.cyanAccent.withOpacity(0.2) : Colors.transparent,
            ),
            child: _termsAccepted ? const Icon(Icons.check, size: 14, color: Colors.cyanAccent) : null,
          ),
          const SizedBox(width: 12),
          const Text("I agree to the CargoLock payment protocols.", 
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _glassButton(String label, Color col, VoidCallback tap, {bool isPrimary = false}) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.cyanAccent : Colors.transparent,
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), 
            side: BorderSide(color: isPrimary ? Colors.cyanAccent : Colors.white10)
          ),
          elevation: isPrimary ? 20 : 0,
          shadowColor: Colors.cyanAccent.withOpacity(0.3),
        ),
        onPressed: tap, 
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13)),
      ),
    );
  }

  void _showSnack(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: col, 
      behavior: SnackBarBehavior.floating,
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))));
  }
}