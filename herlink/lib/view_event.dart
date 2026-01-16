import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:herlink/services/api_services.dart';
import 'package:herlink/services/auth_storage.dart';
import 'package:herlink/login.dart';
import 'package:herlink/widgets/telebirr_mock.dart';

class ViewEventPage extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String location;
  final String organizer;
  final String description;
  final String? bannerUrl;
  final String? eventId;

  const ViewEventPage({
    Key? key,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.organizer,
    required this.description,
    this.bannerUrl,
    this.eventId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(title, style: const TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bannerUrl != null && bannerUrl!.isNotEmpty)
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Image.network(bannerUrl!, fit: BoxFit.cover),
              )
            else
              Container(
                height: 220,
                color: Colors.grey[100],
                child: const Center(
                  child: Icon(Icons.event, size: 80, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(date, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organized by $organizer',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        // simple mock payment flow using backend APIs
                        final token = await AuthStorage.getToken();
                        if (token == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please login to register for events',
                              ),
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                          return;
                        }

                        final int amount =
                            100; // default ticket price (birr) — adapt as needed
                        final referenceId =
                            'evt_${eventId ?? 'unknown'}_${DateTime.now().millisecondsSinceEpoch}';

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirm Registration'),
                            content: Text(
                              'Pay $amount birr to register for this event?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Pay'),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        // show progress
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.purple,
                            ),
                          ),
                        );

                        try {
                          final initRes = await ApiService.initiatePayment(
                            amount,
                            referenceId,
                            'event_registration',
                          );
                          Navigator.pop(context); // dismiss progress

                          if (initRes.statusCode == 201) {
                            final data = jsonDecode(initRes.body);
                            final transactionId = data['transaction_id'];

                            // Show simulate dialog to verify (mock provider)
                             final success = await showModalBottomSheet<bool>(
                               context: context,
                               isScrollControlled: true,
                               backgroundColor: Colors.transparent,
                               builder: (ctx) => TelebirrPaymentMock(
                                 amount: amount.toDouble(),
                                 merchantName: organizer,
                                 transactionId: transactionId,
                               ),
                             );

                            // show progress while verifying
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.purple,
                                ),
                              ),
                            );

                            final verifyRes = await ApiService.verifyPayment(
                              transactionId,
                              success == true,
                            );
                            Navigator.pop(context);

                            if (verifyRes.statusCode == 200) {
                              final vData = jsonDecode(verifyRes.body);
                              final status =
                                  vData['transaction']?['status'] ?? 'UNKNOWN';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Payment $status')),
                              );
                            } else {
                              debugPrint(
                                'Payment verification failed: ${verifyRes.statusCode} ${verifyRes.body}',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment verification failed (${verifyRes.statusCode}): ${verifyRes.body}',
                                  ),
                                ),
                              );
                              return;
                            }
                          } else {
                            debugPrint(
                              'Payment initiation failed: ${initRes.statusCode} ${initRes.body}',
                            );
                            if (initRes.statusCode == 401 ||
                                initRes.statusCode == 403) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Authentication required. Please login.',
                                  ),
                                ),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to initiate payment (${initRes.statusCode}): ${initRes.body}',
                                  ),
                                ),
                              );
                            }
                            return;
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment error: $e')),
                          );
                        }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
