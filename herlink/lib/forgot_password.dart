import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:herlink/services/api_services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController(); // Mock token logic
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _emailSent = false;

  Future<void> _sendResetLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter email")));
      return;
    }

    setState(() => _isLoading = true);
    try {
        final res = await ApiService.forgotPassword(email);
        final data = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        if (res.statusCode == 200) {
            setState(() => _emailSent = true);
        }
    } catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error sending link")));
    } finally {
        setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final pass = _passwordController.text.trim();

    if (otp.isEmpty || pass.isEmpty) return;

    setState(() => _isLoading = true);
    try {
        // In real app, OTP/token is verified. Mocking it here.
        final res = await ApiService.resetPassword(email, pass, otp);
        if (res.statusCode == 200) {
            if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset! Please login.")));
                Navigator.pop(context);
            }
        } else {
             final data = jsonDecode(res.body);
             if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Failed")));
        }
    } catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error resetting password")));
    } finally {
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password"), elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Enter your email to receive a password reset link (or mock token).",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              enabled: !_emailSent,
            ),
            const SizedBox(height: 16),
            if (_emailSent) ...[
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(labelText: "Token (Mock)", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                 TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, minWidth: double.infinity, padding: const EdgeInsets.all(16)),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Set New Password"),
                )
            ] else 
                ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, minWidth: double.infinity, padding: const EdgeInsets.all(16)),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Send Reset Link"),
                ),
          ],
        ),
      ),
    );
  }
}
