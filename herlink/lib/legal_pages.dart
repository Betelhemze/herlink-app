import 'package:flutter/material.dart';

class LegalDetailsPage extends StatelessWidget {
  final String title;
  final List<String> details;

  const LegalDetailsPage({super.key, required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...details.map((detail) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                    Expanded(
                      child: Text(
                        detail,
                        style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDetailsPage(
      title: "Privacy Policy",
      details: [
        "We collect personal information such as name, email, and location to provide our services.",
        "Your data is stored securely and is not shared with third parties without your consent.",
        "We use cookies to enhance your user experience and analyze site traffic.",
        "You have the right to access, update, or delete your personal information at any time.",
        "We implement industry-standard security measures to protect your data.",
        "Changes to this policy will be communicated through the app or via email.",
      ],
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDetailsPage(
      title: "Terms of Service",
      details: [
        "By using HerLink, you agree to abide by our community guidelines and code of conduct.",
        "Users are responsible for the content they post and the interactions they have with others.",
        "We reserve the right to suspend or terminate accounts that violate our terms.",
        "HerLink is not liable for any disputes arising between users or third parties.",
        "Content on the platform is for informational and networking purposes only.",
        "These terms are governed by the laws of the jurisdiction in which HerLink operates.",
      ],
    );
  }
}
