import '../api_client.dart';
import '../../models/faq.dart';

class FaqService {
  static final FaqService _instance = FaqService._internal();
  factory FaqService() => _instance;
  FaqService._internal();

  final ApiClient _apiClient = ApiClient();

  /// Get all FAQs
  Future<ApiResponse<List<FAQ>>> getAllFaqs() async {
    try {
      final response = await _apiClient.get('/api/faqs');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final faqs = data.map((json) => FAQ.fromJson(json)).toList();
        return ApiResponse.success(faqs);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch FAQs');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get active FAQs only
  Future<ApiResponse<List<FAQ>>> getActiveFaqs() async {
    try {
      final response = await _apiClient.get('/api/faqs/active');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final faqs = data.map((json) => FAQ.fromJson(json)).toList();
        return ApiResponse.success(faqs);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch active FAQs');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get FAQs by category
  Future<ApiResponse<List<FAQ>>> getFaqsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/api/faqs/category/$category');

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List;
        final faqs = data.map((json) => FAQ.fromJson(json)).toList();
        return ApiResponse.success(faqs);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch FAQs by category');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Get FAQ by ID
  Future<ApiResponse<FAQ>> getFaqById(int id) async {
    try {
      final response = await _apiClient.get('/api/faqs/$id');

      if (response.success && response.data != null) {
        final faq = FAQ.fromJson(response.data);
        return ApiResponse.success(faq);
      }

      return ApiResponse.error(response.error ?? 'Failed to fetch FAQ');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Increment view count for FAQ
  Future<ApiResponse<void>> incrementViewCount(int id) async {
    try {
      final response = await _apiClient.post('/api/faqs/$id/view');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to increment view count');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Mark FAQ as helpful
  Future<ApiResponse<void>> markAsHelpful(int id) async {
    try {
      final response = await _apiClient.post('/api/faqs/$id/helpful');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to mark as helpful');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Mark FAQ as not helpful
  Future<ApiResponse<void>> markAsNotHelpful(int id) async {
    try {
      final response = await _apiClient.post('/api/faqs/$id/not-helpful');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to mark as not helpful');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Create FAQ (admin only)
  Future<ApiResponse<FAQ>> createFaq({
    required String question,
    required String answer,
    required String category,
    bool isActive = true,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/faqs',
        body: {
          'question': question,
          'answer': answer,
          'category': category,
          'isActive': isActive,
        },
      );

      if (response.success && response.data != null) {
        final faq = FAQ.fromJson(response.data);
        return ApiResponse.success(faq);
      }

      return ApiResponse.error(response.error ?? 'Failed to create FAQ');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Update FAQ (admin only)
  Future<ApiResponse<FAQ>> updateFaq({
    required int id,
    String? question,
    String? answer,
    String? category,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (question != null) body['question'] = question;
      if (answer != null) body['answer'] = answer;
      if (category != null) body['category'] = category;
      if (isActive != null) body['isActive'] = isActive;

      final response = await _apiClient.put('/api/faqs/$id', body: body);

      if (response.success && response.data != null) {
        final faq = FAQ.fromJson(response.data);
        return ApiResponse.success(faq);
      }

      return ApiResponse.error(response.error ?? 'Failed to update FAQ');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Toggle FAQ active status (admin only)
  Future<ApiResponse<FAQ>> toggleActive(int id) async {
    try {
      final response = await _apiClient.put('/api/faqs/$id/toggle-active');

      if (response.success && response.data != null) {
        final faq = FAQ.fromJson(response.data);
        return ApiResponse.success(faq);
      }

      return ApiResponse.error(response.error ?? 'Failed to toggle FAQ status');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Delete FAQ (admin only)
  Future<ApiResponse<void>> deleteFaq(int id) async {
    try {
      final response = await _apiClient.delete('/api/faqs/$id');

      if (response.success) {
        return ApiResponse.success(null);
      }

      return ApiResponse.error(response.error ?? 'Failed to delete FAQ');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
