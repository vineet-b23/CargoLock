import 'dart:ui';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import '../customer/customer_home.dart';
import '../supplier/supplier_home.dart';
import '../driver/driver_home.dart';
import '../admin/admin_home.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  int _userTypeIndex = 0;
  final List<String> _userRoles = ['Customer', 'Supplier', 'Driver', 'Admin'];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Future<void> _handleLogin() async {
    try {
      final String response = await rootBundle.loadString('assets/data/user.json');
      final data = await json.decode(response);
      final List users = data['users'];
      final user = users.firstWhere(
        (u) => u['username'] == _usernameController.text && 
               u['password'] == _passwordController.text,
        orElse: () => null,
      );

      if (user != null) {
        Widget dest;
        switch (user['role']) {
          case 0: dest = const SupplierHome(); break;
          case 1: dest = const DriverHome(); break;
          case 2: dest = const CustomerHome(); break;
          case 3: dest = const AdminTerminal(); break; 
          default: dest = const DriverHome();
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) => dest));
      } else {
        _showError("Invalid Username or Password");
      }
    } catch (e) {
      _showError("Error loading user data. Check assets/data/user.json");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00050A), 
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _buildGlow(Colors.blue.withOpacity(0.2))),
          Positioned(bottom: -100, left: -50, child: _buildGlow(Colors.cyan.withOpacity(0.15))),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("CargoLock", 
                          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 8)),
                        const SizedBox(height: 40),
                        const Text("Login with", 
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w300)),
                        const SizedBox(height: 25),
                        _buildRoleToggle(),
                        const SizedBox(height: 35),
                        _buildGlassField("Username", Icons.person_outline, controller: _usernameController),
                        const SizedBox(height: 15),
                        _buildGlassField("Password", Icons.lock_outline, isObscure: true, controller: _passwordController),
                        const SizedBox(height: 40),
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 400, 
      height: 400, 
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: color, 
        boxShadow: [BoxShadow(color: color, blurRadius: 150, spreadRadius: 50)]
      )
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black38, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.white12)
      ),
      child: Row(
        children: List.generate(_userRoles.length, (index) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _userTypeIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _userTypeIndex == index ? Colors.white.withOpacity(0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _userTypeIndex == index ? Colors.white12 : Colors.transparent),
              ),
              child: Center(
                child: Text(
                  _userRoles[index], 
                  style: TextStyle(
                    color: _userTypeIndex == index ? Colors.white : Colors.white38, 
                    fontSize: 9, 
                    fontWeight: FontWeight.bold
                  )
                )
              ),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildGlassField(String hint, IconData icon, {bool isObscure = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white24, size: 18),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide(color: Colors.white.withOpacity(0.05))
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: Colors.blueAccent)
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        onPressed: _handleLogin,
        child: const Text("Login", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      ),
    );
  }
}