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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reset Password"), 
        elevation: 0, 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset, color: Colors.purple, size: 60),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Forgot password?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _emailSent 
                  ? "We've sent a 6-digit code to your email. Please enter it below along with your new password."
                  : "Enter your email address and we'll send you instructions on how to reset your password.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email Address", 
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabled: !_emailSent,
                ),
              ),
              const SizedBox(height: 20),
              
              if (_emailSent) ...[
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: "Reset Token", 
                      prefixIcon: const Icon(Icons.security),
                      hintText: "Enter the code you received",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                   TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "New Password", 
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, 
                        foregroundColor: Colors.white, 
                        minimumSize: const Size(double.infinity, 56), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Reset Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
              ] else ...[
                  ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetLink,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple, 
                          foregroundColor: Colors.white, 
                          minimumSize: const Size(double.infinity, 56), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Send Reset Instructions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
              ],
              
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to Login", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
