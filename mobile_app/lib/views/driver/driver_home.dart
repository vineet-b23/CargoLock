import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:exif/exif.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  String? _status, _timing, _delayedChoice, _selectedReason;
  File? _imageFile;
  final _picker = ImagePicker();
  final DateTime assignedDeliveryTime = DateTime.now().subtract(const Duration(minutes: 30)); 
  double _reputationScore = 88.0; 
  String _driverGrade = "A";
  final List<String> _complaintReasons = ["Accident", "Tyre Flat", "Medical Emergency", "Internet Outage"];

  @override
  void initState() {
    super.initState();
    _calculateGrade();
  }

  void _calculateGrade() {
    if (_reputationScore >= 95) _driverGrade = "S";
    else if (_reputationScore >= 85) _driverGrade = "A";
    else if (_reputationScore >= 70) _driverGrade = "B";
    else _driverGrade = "C";
  }
  
  Future<DateTime> _getImageCaptureTime(File file) async {
    final bytes = await file.readAsBytes();
    final data = await readExifFromBytes(bytes);

    if (data.containsKey('Image DateTime')) {
      String dateStr = data['Image DateTime']!.toString().replaceAll(':', '-');
      String formattedDate = dateStr.replaceFirst('-', ':', 19).replaceFirst('-', ':', 16); 
      return DateTime.parse(formattedDate);
    }
    return await file.lastModified();
  }
  Future<void> _sendToBackend() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)));
    try {
      DateTime captureTime = DateTime.now();
      if (_imageFile != null) {
        captureTime = await _getImageCaptureTime(_imageFile!);
      }
      bool isCapturedBeforeDeadline = captureTime.isBefore(assignedDeliveryTime);
      String finalReason = _selectedReason ?? "N/A";
      if (_selectedReason == "Internet Outage" && !isCapturedBeforeDeadline) {
        finalReason = "Late Capture (System Flagged Delay)";
      }
      var uri = Uri.parse('http://172.16.44.245:3000/upload');
      var request = http.MultipartRequest('POST', uri);
      request.fields['driver_id'] = "DRV_786";
      request.fields['status'] = _status ?? "unknown";
      request.fields['reason'] = finalReason;
      request.fields['capture_time'] = captureTime.toIso8601String();
      request.fields['deadline'] = assignedDeliveryTime.toIso8601String();

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('evidence_image', _imageFile!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final Map<String, dynamic> aiData = jsonDecode(response.body);
        _showAIResultsPopup(aiData);
      } else {
        _showSnack("Error: ${response.statusCode}", Colors.redAccent);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnack("Connection Failed: Check Server IP", Colors.redAccent);
    }
  }

  Future<void> _pickImage(ImageSource src) async {
    try {
      final picked = await _picker.pickImage(
        source: src, 
        imageQuality: 50, 
      );
      
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      _showSnack("Error picking image: $e", Colors.redAccent);
    }
    if (mounted) Navigator.pop(context);
  }

  void _showAIResultsPopup(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Colors.white12)),
          title: const Text("AI VERIFICATION", style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _resultRow("CATEGORY", data['result'] ?? "Unknown"),
              const SizedBox(height: 12),
              _resultRow("CONFIDENCE", "${data['confidence']}%"),
              const SizedBox(height: 12),
              const Text("SUMMARY", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(data['summary'] ?? "No summary provided", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const Divider(color: Colors.white10, height: 30),
              Flexible(
                child: Text(
                  "IPFS Proof: ${data['ipfs_url']}",
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() { _status = null; _imageFile = null; _timing = null; _delayedChoice = null; }); 
              },
              child: const Text("CLOSE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            value.toUpperCase(),
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("DRIVER CONSOLE", style: TextStyle(fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
        actions: [_buildRatingBadge()],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment.topRight, radius: 1.5, colors: [Color(0xFF001A33), Color(0xFF00050A)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 120, 25, 25),
          child: Column(
            children: [
              if (_status != null) _buildResetButton(),
              const SizedBox(height: 20),
              if (_status == null) _buildInitialSelection(),
              if (_status == 'delivered' && _timing == null) _buildTimingSelection(),
              if (_timing == 'ontime' || _delayedChoice == 'accept') _buildFinalSubmitOnly(),
              if (_timing == 'delayed' && _delayedChoice == null) _buildDelayedActionSelection(),
              if (_status == 'not_delivered' || _delayedChoice == 'complaint') _buildEvidenceForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalSubmitOnly() {
    return Column(
      children: [
        const Text("System will auto-verify condition via photo.", style: TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 20),
        _glassButton(_imageFile == null ? "📷 SNAP DELIVERY PHOTO" : "🔄 RETAKE PHOTO", Colors.blueAccent, () => _showMediaPicker(context)),
        if (_imageFile != null) ...[
          const SizedBox(height: 20),
          _buildImagePreview(),
          _glassButton("VERIFY & FINISH", Colors.white, _sendToBackend, isPrimary: true),
        ]
      ],
    );
  }

  Widget _buildEvidenceForm() {
    return Column(children: [
      ..._complaintReasons.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15), border: Border.all(color: _selectedReason == r ? Colors.blueAccent : Colors.white10)),
        child: RadioListTile(
          title: Text(r, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          value: r, groupValue: _selectedReason, activeColor: Colors.blueAccent,
          onChanged: (v) => setState(() => _selectedReason = v as String),
        ),
      )),
      const SizedBox(height: 20),
      if (_imageFile != null) _buildImagePreview(),
      _glassButton(_imageFile == null ? "📷 ATTACH EVIDENCE" : "🔄 CHANGE IMAGE", Colors.white12, () => _showMediaPicker(context)),
      const SizedBox(height: 30),
      _glassButton("SUBMIT TO ADMIN", Colors.white, _sendToBackend, isPrimary: true),
    ]);
  }

  Widget _glassButton(String label, Color col, VoidCallback tap, {bool isPrimary = false}) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : col.withOpacity(0.1),
          foregroundColor: isPrimary ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isPrimary ? Colors.white : col.withOpacity(0.3))),
          elevation: 0,
        ),
        onPressed: tap, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _buildInitialSelection() {
    return Column(children: [
      _glassButton("DELIVERED", Colors.blueAccent, () => setState(() => _status = 'delivered')),
      const SizedBox(height: 15),
      _glassButton("NOT DELIVERED", Colors.redAccent.withOpacity(0.5), () => setState(() => _status = 'not_delivered')),
    ]);
  }

  Widget _buildTimingSelection() { return Column(children: [ _glassButton("ON TIME", Colors.blueAccent, () => setState(() => _timing = 'ontime')), const SizedBox(height: 15), _glassButton("DELAYED", Colors.orangeAccent, () => setState(() => _timing = 'delayed')) ]); }
  Widget _buildDelayedActionSelection() { return Column(children: [ _glassButton("ACCEPT DEDUCTION", Colors.white10, () => setState(() => _delayedChoice = 'accept')), const SizedBox(height: 15), _glassButton("RAISE COMPLAINT", Colors.redAccent, () => setState(() => _delayedChoice = 'complaint')) ]); }

  Widget _buildRatingBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Center(child: Text("Reputation: $_reputationScore [$_driverGrade]", style: const TextStyle(fontSize: 10, color: Colors.cyanAccent, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () => setState(() { _status = _timing = _delayedChoice = null; _imageFile = null; _selectedReason = null; }),
      child: const Row(children: [Icon(Icons.refresh, size: 14, color: Colors.blueAccent), Text(" RESET FLOW", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold))]),
    );
  }
  
  Widget _buildImagePreview() {
    return Container(
      height: 180, width: double.infinity, margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white12), image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)),
    );
  }

  void _showMediaPicker(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF000A14),
      builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt, color: Colors.blueAccent), title: const Text("Camera"), onTap: () => _pickImage(ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library, color: Colors.blueAccent), title: const Text("Gallery"), onTap: () => _pickImage(ImageSource.gallery)),
      ]),
    );
  }

  void _showSnack(String msg, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: col, content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold))));
  }
}