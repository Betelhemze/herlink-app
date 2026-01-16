import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class ApiService {
  static Future<http.Response> get(String endpoint, {bool auth = false}) async {
    final headers = await _headers(auth);
    return http.get(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: headers,
    );
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final headers = await _headers(auth);
    return http.post(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final headers = await _headers(auth);
    return http.put(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(
    String endpoint, {
    bool auth = false,
  }) async {
    final headers = await _headers(auth);
    return http.delete(
      Uri.parse("${ApiConfig.baseUrl}$endpoint"),
      headers: headers,
    );
  }

  static Future<Map<String, String>> _headers(bool auth) async {
    final headers = {"Content-Type": "application/json"};

    if (auth) {
      final token = await AuthStorage.getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  // Authentication methods
  static Future<http.Response> login(String email, String password) async {
    return post("/api/auth/login", {"email": email, "password": password});
  }

  static Future<http.Response> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return post("/api/auth/register", {
      "email": email,
      "password": password,
      "full_name": fullName,
    });
  }

  static Future<http.Response> googleLogin({
      String? token,
      String? email,
      String? name,
      String? avatar,
  }) async {
      return post("/api/auth/google", {
          "token": token,
          "mock_email": email,
          "mock_name": name,
          "mock_avatar": avatar
      });
  }

  static Future<http.Response> logout() async {
    final response = await post("/api/auth/logout", {}, auth: true);
    await AuthStorage.logout();
    return response;
  }

  // User Profile methods
  static Future<http.Response> getUserProfile(String id) async {
    return get("/api/users/$id");
  }

  static Future<http.Response> getMyProfile() async {
    return get("/api/users/me", auth: true);
  }

  static Future<http.Response> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    return put("/api/users/profile", profileData, auth: true);
  }

  static Future<http.Response> uploadImage(String filePath) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/upload");
    final request = http.MultipartRequest("POST", url);

    final token = await AuthStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(await http.MultipartFile.fromPath("image", filePath));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  static Future<http.Response> getUserEvents(String id) async {
    return get("/api/users/$id/events");
  }

  static Future<http.Response> getMyEvents() async {
    return get("/api/users/me/events", auth: true);
  }

  // Collaborations
  static Future<http.Response> getCollaborations({String? search, String? category}) async {
    String query = "";
    if (search != null) query += "search=$search&";
    if (category != null) query += "category=$category&";
    return get("/api/collaborations?$query");
  }

  static Future<http.Response> getCollaborationById(String id) async {
    return get("/api/collaborations/$id");
  }

  static Future<http.Response> createCollaboration(
    Map<String, dynamic> data,
  ) async {
    return post("/api/collaborations", data, auth: true);
  }

  static Future<http.Response> updateCollaborationStatus(
    String id,
    String status,
  ) async {
    return put("/api/collaborations/$id/status", {
      "status": status,
    }, auth: true);
  }

  // Users
  static Future<http.Response> getUsers() async {
    return get("/api/users");
  }

  static Future<http.Response> getUserById(String id) async {
    return get("/api/users/$id");
  }

  // Collaboration Requests
  static Future<http.Response> sendCollaborationRequest(
    Map<String, dynamic> data,
  ) async {
    return post("/api/collaboration-requests", data, auth: true);
  }

  // User reviews
  static Future<http.Response> getUserReviews(String userId) async {
    return get("/api/users/$userId/reviews");
  }

  static Future<http.Response> addUserReview(String userId, Map<String, dynamic> data) async {
    return post("/api/users/$userId/reviews", data, auth: true);
  }

  static Future<http.Response> getCollaborationInbox() async {
    return get("/api/collaboration-requests/me", auth: true);
  }

  static Future<http.Response> updateCollaborationRequestStatus(
    String id,
    String status,
  ) async {
    return put("/api/collaboration-requests/$id/status", {
      "status": status,
    }, auth: true);
  }

  // Direct Messages
  static Future<http.Response> sendMessage(
    String receiverId,
    String content,
  ) async {
    return post("/api/messages", {
      "receiver_id": receiverId,
      "content": content,
    }, auth: true);
  }

  static Future<http.Response> getChat(String otherUserId) async {
    return get("/api/messages/chat/$otherUserId", auth: true);
  }

  static Future<http.Response> getConversations() async {
    return get("/api/messages/conversations", auth: true);
  }

  static Future<http.Response> getWithCache(String endpoint, {bool auth = false}) async {
    try {
      // 1. Try Network
      final response = await get(endpoint, auth: auth);
      if (response.statusCode == 200) {
        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cache_$endpoint', response.body);
      }
      return response;
    } catch (e) {
      // 2. Fallback to Cache
      debugPrint("Network failed, checking cache for $endpoint: $e");
      final prefs = await SharedPreferences.getInstance();
      final cachedBody = prefs.getString('cache_$endpoint');
      if (cachedBody != null) {
        debugPrint("Returning cached data for $endpoint");
        return http.Response(cachedBody, 200);
      }
      rethrow;
    }
  }

  // Products
  static Future<http.Response> getProducts({
    String? category,
    double? minPrice,
    double? maxPrice,
    String? search,
    String? sellerId,
  }) async {
    String query = "";
    if (category != null) query += "category=$category&";
    if (minPrice != null) query += "minPrice=$minPrice&";
    if (maxPrice != null) query += "maxPrice=$maxPrice&";
    if (search != null) query += "search=$search&";
    if (sellerId != null) query += "seller_id=$sellerId&";
    // Use cache for product feed
    return getWithCache("/api/products?$query");
  }

  static Future<http.Response> getProductById(String id) async {
    return get("/api/products/$id");
  }

  static Future<http.Response> createProduct(Map<String, dynamic> data) async {
    return post("/api/products", data, auth: true);
  }

  static Future<http.Response> updateProduct(
    String id,
    Map<String, dynamic> data,
  ) async {
    return put("/api/products/$id", data, auth: true);
  }

  static Future<http.Response> deleteProduct(String id) async {
    return delete("/api/products/$id", auth: true);
  }

  static Future<http.Response> addProductReview(
    String id,
    Map<String, dynamic> data,
  ) async {
    return post("/api/products/$id/reviews", data, auth: true);
  }

  static Future<http.Response> getProductReviews(String id) async {
    return get("/api/products/$id/reviews");
  }

  // Events
  static Future<http.Response> getEvents({String? category, String? search}) async {
    String query = "";
    if (category != null) query += "category=$category&";
    if (search != null) query += "search=$search&";
    return getWithCache("/api/events?$query");
  }

  static Future<http.Response> getEventById(String id) async {
    return get("/api/events/$id");
  }

  static Future<http.Response> createEvent(Map<String, dynamic> data) async {
    return post("/api/events", data, auth: true);
  }

  static Future<http.Response> registerForEvent(String id) async {
    return post("/api/events/$id/register", {}, auth: true);
  }

  // Posts
  static Future<http.Response> getPosts() async {
    return getWithCache("/api/posts");
  }

  static Future<http.Response> createPost(Map<String, dynamic> data) async {
    return post("/api/posts", data, auth: true);
  }

  static Future<http.Response> likePost(String id) async {
    return post("/api/posts/$id/like", {}, auth: true);
  }

  static Future<http.Response> getPostComments(String id) async {
    return get("/api/posts/$id/comments");
  }

  static Future<http.Response> addComment(String postId, String content) async {
    return post("/api/posts/$postId/comments", {
      "content": content,
    }, auth: true);
  }

  static Future<http.Response> sharePost(String id) async {
    return post("/api/posts/$id/share", {}, auth: true);
  }

  // Payments
  static Future<http.Response> initiatePayment(
    int amount,
    String referenceId,
    String type,
  ) async {
    return post("/api/payments/initiate", {
      "amount": amount,
      "reference_id": referenceId,
      "type": type,
    }, auth: true);
  }

  static Future<http.Response> verifyPayment(
    String transactionId,
    bool success,
  ) async {
    return post("/api/payments/verify", {
      "transaction_id": transactionId,
      "success": success,
    }, auth: true);
  }

  static Future<http.Response> getPaymentHistory() async {
    return get("/api/payments/history", auth: true);
  }
  
  // Forgot / Reset Password
  static Future<http.Response> forgotPassword(String email) async {
    return post("/api/auth/forgot-password", {"email": email});
  }

  static Future<http.Response> resetPassword(String email, String newPassword, String token) async {
    return post("/api/auth/reset-password", {"email": email, "newPassword": newPassword, "token": token});
  }

  // Edit / Delete Post
  static Future<http.Response> editPost(String id, String content, String? imageUrl) async {
    return put("/api/posts/$id", {
      "content": content,
      "image_url": imageUrl,
    }, auth: true);
  }

  static Future<http.Response> deletePost(String id) async {
    return delete("/api/posts/$id", auth: true);
  }

  // Saved Items
  static Future<http.Response> getSavedItems() async {
    return get("/api/saved", auth: true);
  }

  static Future<http.Response> saveItem(String type, String id) async {
    return post("/api/saved", {
      "entity_type": type,
      "entity_id": id,
    }, auth: true);
  }

  static Future<http.Response> unsaveItem(String type, String id) async {
    return delete("/api/saved/$type/$id", auth: true);
  }
}
