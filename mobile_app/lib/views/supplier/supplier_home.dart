import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/api_services.dart';
import 'package:intl/intl.dart'; 

class SupplierHome extends StatefulWidget {
  const SupplierHome({super.key});

  @override
  State<SupplierHome> createState() => _SupplierHomeState();
}

class _SupplierHomeState extends State<SupplierHome> {
  final TextEditingController _cargoIdController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _driverAddressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  
  DateTime? _selectedDeadline;
  bool _isDispatching = false;
  String _statusMessage = '';

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent)),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      setState(() {
        _selectedDeadline = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
        if (_selectedDeadline!.isBefore(now)) {
          _selectedDeadline = _selectedDeadline!.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _generateDispatch() async {
    if (_cargoIdController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _driverAddressController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedDeadline == null) {
      setState(() => _statusMessage = 'Please fill all fields and set delivery time');
      return;
    }

    setState(() {
      _isDispatching = true;
      _statusMessage = '';
    });

    try {
  
      final result = await ApiService.createOrder(
        _driverAddressController.text.trim(),
        '${_cargoIdController.text} to ${_destinationController.text}',
        _amountController.text.trim(),
        deliveryTime: _selectedDeadline!.toIso8601String(), 
      );

      setState(() => _isDispatching = false);

      if (result['error'] != null) {
        setState(() => _statusMessage = 'Error: ${result['error']}');
      } else {
        setState(() {
          _statusMessage = 'Order sent to Admin for assignment!';
          _cargoIdController.clear();
          _destinationController.clear();
          _driverAddressController.clear();
          _amountController.clear();
          _selectedDeadline = null;
        });
      }
    } catch (e) {
      setState(() {
        _isDispatching = false;
        _statusMessage = 'Failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("SUPPLIER TERMINAL", style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001220), Color(0xFF000000)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 120, 25, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInventoryCard(),
              const SizedBox(height: 30),
              const Text("NEW DISPATCH", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const SizedBox(height: 15),
              _buildInputField("CARGO ID (e.g. CRGO-882)", Icons.inventory_2_outlined, _cargoIdController),
              const SizedBox(height: 15),
              _buildInputField("DESTINATION NODE", Icons.location_on_outlined, _destinationController),
              const SizedBox(height: 15),
              _buildInputField("DRIVER WALLET ADDRESS (0x...)", Icons.person_outline, _driverAddressController),
              const SizedBox(height: 15),
              _buildInputField("AMOUNT (ETH)", Icons.currency_bitcoin, _amountController),
              const SizedBox(height: 15),
            
              _buildTimePickerField(),
              
              const SizedBox(height: 10),
              if (_statusMessage.isNotEmpty) _buildStatusMessage(),
              const SizedBox(height: 20),
              _buildDispatchButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _selectedDeadline == null ? Colors.white10 : Colors.cyanAccent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: _selectedDeadline == null ? Colors.white24 : Colors.cyanAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              _selectedDeadline == null 
                  ? "SET DELIVERY DEADLINE" 
                  : "DEADLINE: ${DateFormat('hh:mm a').format(_selectedDeadline!)}",
              style: TextStyle(
                color: _selectedDeadline == null ? Colors.white24 : Colors.white,
                fontSize: 14,
                fontWeight: _selectedDeadline == null ? FontWeight.normal : FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    bool isError = _statusMessage.startsWith('Error') || _statusMessage.startsWith('Failed');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? Colors.redAccent.withOpacity(0.1) : Colors.greenAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isError ? Colors.redAccent.withOpacity(0.3) : Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Text(
        _statusMessage,
        style: TextStyle(color: isError ? Colors.redAccent : Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInventoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.cyanAccent.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.1)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("AVAILABLE STOCK", style: TextStyle(color: Colors.white38, fontSize: 10)),
              SizedBox(height: 5),
              Text("1,240 Units", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          Icon(Icons.analytics_outlined, color: Colors.cyanAccent, size: 30),
        ],
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white24, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }

  Widget _buildDispatchButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: _isDispatching ? null : _generateDispatch,
        child: _isDispatching
            ? const CircularProgressIndicator(color: Colors.black)
            : const Text("INITIALIZE DISPATCH", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}