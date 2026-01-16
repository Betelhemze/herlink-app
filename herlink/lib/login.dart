import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:herlink/home.dart';
import 'package:herlink/signup.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:herlink/forgot_password.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(email, password);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token and user id
        await AuthStorage.saveToken(data['token']);
        await AuthStorage.saveUserId(data['user']['id'].toString());
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Login failed")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
    );
  }

  Future<void> _handleGoogleLogin() async {
      setState(() => _isLoading = true);
      try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          GoogleSignInAccount? googleUser;
          
          try {
             googleUser = await googleSignIn.signIn();
          } catch (error) {
             debugPrint("Google Sign In Error (Expected if not configured): $error");
             // Fallback for demo if not configured: Simulate a google user
             // Remove this in production!
             if (true) { // Demo mode
                 final res = await ApiService.googleLogin(
                     email: "demo_google_user@gmail.com",
                     name: "Demo Google User",
                     avatar: "https://lh3.googleusercontent.com/a/default-user"
                 );
                 _processLoginResponse(res);
                 return;
             }
          }

          if (googleUser != null) {
              final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
              // Send token to backend
              final response = await ApiService.googleLogin(
                  token: googleAuth.idToken,
                  email: googleUser.email, 
                  name: googleUser.displayName,
                  avatar: googleUser.photoUrl
              );
              _processLoginResponse(response);
          } else {
               setState(() => _isLoading = false);
          }

      } catch (e) {
          debugPrint("Login General Error: $e");
          setState(() => _isLoading = false);
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Login Failed: $e")));
      }
  }

  void _processLoginResponse(http.Response response) async {
       if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true) {
                await AuthStorage.saveToken(data['token']);
                await AuthStorage.saveUserId(data['user']['id'].toString());
                if(mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                }
            } else {
                 if(mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? "Login failed")));
                    setState(() => _isLoading = false);
                 }
            }
       } else {
             if(mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backend Error")));
                 setState(() => _isLoading = false);
             }
       }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo
              Center(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Welcome Back",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to continue to HerLink",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              
              const SizedBox(height: 24),
              Row(children: const [
                  Expanded(child: Divider()),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("OR", style: TextStyle(color: Colors.grey))),
                  Expanded(child: Divider()),
              ]),
              const SizedBox(height: 24),

              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleLogin,
                icon: Image.network("https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/768px-Google_%22G%22_logo.svg.png", height: 24, width: 24),
                label: const Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.black87
                ),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Forgot password link
              GestureDetector(
                onTap: _forgotPassword,
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
