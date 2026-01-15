import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_storage.dart';

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
    return get("/api/products?$query");
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
    return get("/api/events?$query");
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
    return get("/api/posts");
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
}
