/// Configuración de API y endpoints del backend
class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://localhost:8080'; // API Gateway
  static const String apiPrefix = '/api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentTypeJson = 'application/json';
  static const String contentTypeMultipart = 'multipart/form-data';

  // Auth
  static const String authHeader = 'Authorization';
  static const String authPrefix = 'Bearer';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // ==================== COMMUNITY SERVICE (9001) ====================
  // Auth
  static const String authRegister = '/users/auth/register';
  static const String authLogin = '/users/auth/login';

  // Users
  static const String userProfile = '/users/profile';
  static String userById(String id) => '/users/$id';
  static const String allUsers = '/users';

  // Ratings
  static const String ratings = '/ratings';
  static String ratingsByUser(String userId) => '/ratings/user/$userId';
  static String ratingsByEntity(String entityType, String entityId) =>
      '/ratings/entity/$entityType/$entityId';
  static String ratingsAverage(String entityType, String entityId) =>
      '/ratings/entity/$entityType/$entityId/average';
  static String userEntityRating(String userId, String entityType, String entityId) =>
      '/ratings/user/$userId/entity/$entityType/$entityId';
  static String deleteRating(String ratingId) => '/ratings/$ratingId';

  // Comments
  static const String comments = '/comments';
  static String commentsByEntity(String entityType, String entityId) =>
      '/comments/entity/$entityType/$entityId';
  static String commentReplies(String commentId) => '/comments/$commentId/replies';
  static String commentsByUser(String userId) => '/comments/user/$userId';
  static String commentById(String id) => '/comments/$id';

  // Artist Metrics
  static String artistMetrics(String artistId) => '/metrics/artists/$artistId';
  static String incrementArtistPlays(String artistId) => '/metrics/artists/$artistId/plays';
  static String incrementArtistListeners(String artistId) =>
      '/metrics/artists/$artistId/listeners';
  static String incrementArtistFollowers(String artistId) =>
      '/metrics/artists/$artistId/followers/increment';
  static String decrementArtistFollowers(String artistId) =>
      '/metrics/artists/$artistId/followers/decrement';
  static String artistSales(String artistId) => '/metrics/artists/$artistId/sales';

  // Song Metrics
  static String songMetrics(String songId) => '/metrics/songs/$songId';
  static String incrementSongPlays(String songId) => '/metrics/songs/$songId/plays';

  // User Metrics
  static String userMetrics(String userId) => '/metrics/users/$userId';

  // Global Metrics
  static const String globalMetrics = '/metrics/global';

  // Notifications
  static const String notifications = '/notifications';
  static String notificationsByUser(String userId) => '/notifications/user/$userId';
  static String unreadNotifications(String userId) => '/notifications/user/$userId/unread';
  static String unreadNotificationsCount(String userId) =>
      '/notifications/user/$userId/unread/count';
  static String notificationsByType(String userId, String type) =>
      '/notifications/user/$userId/type/$type';
  static String notificationById(String id) => '/notifications/$id';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static String markAllNotificationsRead(String userId) =>
      '/notifications/user/$userId/read-all';

  // Contact
  static const String contact = '/contact';
  static String contactByUser(String userId) => '/contact/user/$userId';
  static String contactByStatus(String status) => '/contact/status/$status';
  static String contactById(String id) => '/contact/$id';
  static String contactUpdateStatus(String id) => '/contact/$id/status';
  static String contactRespond(String id) => '/contact/$id/respond';

  // FAQs
  static const String faqs = '/faqs';
  static const String activeFaqs = '/faqs/active';
  static String faqsByCategory(String category) => '/faqs/category/$category';
  static String faqById(String id) => '/faqs/$id';
  static String faqToggleActive(String id) => '/faqs/$id/toggle-active';
  static String faqView(String id) => '/faqs/$id/view';
  static String faqHelpful(String id) => '/faqs/$id/helpful';
  static String faqNotHelpful(String id) => '/faqs/$id/not-helpful';

  // ==================== MUSIC CATALOG SERVICE (9002) ====================
  // Songs
  static const String songs = '/songs';
  static String songById(String id) => '/songs/$id';
  static String songsByArtist(String artistId) => '/songs/artist/$artistId';
  static String songsByAlbum(String albumId) => '/songs/album/$albumId';
  static String songsByGenre(String genreId) => '/songs/genre/$genreId';
  static const String searchSongs = '/songs/search';

  // Albums
  static const String albums = '/albums';
  static String albumById(String id) => '/albums/$id';
  static String albumsByArtist(String artistId) => '/albums/artist/$artistId';
  static String albumsByGenre(String genreId) => '/albums/genre/$genreId';

  // Genres
  static const String genres = '/genres';
  static String genreById(String id) => '/genres/$id';

  // Collaborations
  static const String collaborations = '/collaborations';
  static String collaborationsBySong(String songId) => '/collaborations/song/$songId';
  static String collaborationsByArtist(String artistId) =>
      '/collaborations/artist/$artistId';
  static String deleteCollaboration(String id) => '/collaborations/$id';

  // Discovery
  static const String discoverySongs = '/discovery/search/songs';
  static const String discoveryAlbums = '/discovery/search/albums';
  static const String trendingSongs = '/discovery/trending/songs';
  static const String trendingAlbums = '/discovery/trending/albums';
  static const String recommendations = '/discovery/recommendations';

  // ==================== PLAYBACK SERVICE (9003) ====================
  // Playback
  static const String playbackPlay = '/playback/play';
  static String playbackPause(String sessionId) => '/playback/$sessionId/pause';
  static String playbackResume(String sessionId) => '/playback/$sessionId/resume';
  static String playbackSeek(String sessionId) => '/playback/$sessionId/seek';
  static String playbackStop(String sessionId) => '/playback/$sessionId';
  static String currentPlayback(String userId) => '/playback/current/$userId';
  static String playbackSessions(String userId) => '/playback/sessions/$userId';

  // Playlists
  static const String playlists = '/playlists';
  static String playlistById(String id) => '/playlists/$id';
  static String playlistsByUser(String userId) => '/playlists/user/$userId';
  static const String publicPlaylists = '/playlists/public';
  static String publicPlaylistsByUser(String userId) => '/playlists/public/user/$userId';
  static String addSongToPlaylist(String playlistId) => '/playlists/$playlistId/songs';
  static String removeSongFromPlaylist(String playlistId, String songId) =>
      '/playlists/$playlistId/songs/$songId';
  static String reorderPlaylist(String playlistId) => '/playlists/$playlistId/songs/reorder';
  static String playlistSongs(String playlistId) => '/playlists/$playlistId/songs';

  // Queue
  static String queue(String userId) => '/queue/$userId';
  static const String addToQueue = '/queue';
  static String clearQueue(String userId) => '/queue/$userId/clear';
  static String setQueueIndex(String userId) => '/queue/$userId/index';
  static String toggleShuffle(String userId) => '/queue/$userId/shuffle';
  static String setRepeatMode(String userId) => '/queue/$userId/repeat';

  // History
  static const String history = '/history';
  static String historyByUser(String userId) => '/history/user/$userId';
  static String recentHistory(String userId) => '/history/user/$userId/recent';
  static String clearHistory(String userId) => '/history/user/$userId';

  // Library
  static const String libraryItems = '/library/items';
  static String libraryByUser(String userId) => '/library/user/$userId';
  static String libraryByType(String userId, String type) =>
      '/library/user/$userId/type/$type';
  static String libraryFavorites(String userId) => '/library/user/$userId/favorites';
  static const String toggleFavorite = '/library/items/favorite';
  static String clearLibrary(String userId) => '/library/user/$userId';

  // Collections
  static const String collections = '/library/collections';
  static String collectionById(String id) => '/library/collections/$id';
  static String collectionsByUser(String userId) => '/library/collections/user/$userId';
  static String addToCollection(String collectionId) =>
      '/library/collections/$collectionId/items';
  static String removeFromCollection(String collectionId, String itemId) =>
      '/library/collections/$collectionId/items/$itemId';

  // ==================== COMMERCE SERVICE (9004) ====================
  // Products
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String productCategories = '/products/categories';
  static String updateProductStock(String id) => '/products/$id/stock';

  // Product Variants
  static String productVariants(String productId) => '/products/$productId/variants';
  static String variantById(String variantId) => '/products/variants/$variantId';
  static String updateVariantStock(String variantId) =>
      '/products/variants/$variantId/stock';

  // Cart
  static String cart(String userId) => '/cart/$userId';
  static String cartItems(String userId) => '/cart/$userId/items';
  static String cartItem(String userId, String itemId) => '/cart/$userId/items/$itemId';
  static String cartCount(String userId) => '/cart/$userId/count';
  static String cartTotal(String userId) => '/cart/$userId/total';

  // Orders
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderByNumber(String orderNumber) => '/orders/order-number/$orderNumber';
  static String ordersByUser(String userId) => '/orders/user/$userId';
  static String ordersByStatus(String status) => '/orders/status/$status';
  static String ordersByUserAndStatus(String userId, String status) =>
      '/orders/user/$userId/status/$status';
  static String updateOrderStatus(String id) => '/orders/$id/status';
  static String cancelOrder(String id) => '/orders/$id/cancel';

  // Payments
  static const String payments = '/payments';
  static String paymentById(String id) => '/payments/$id';
  static String paymentByOrder(String orderId) => '/payments/order/$orderId';
  static String paymentsByUser(String userId) => '/payments/user/$userId';
  static String processPayment(String id) => '/payments/$id/process';
  static String completePayment(String id) => '/payments/$id/complete';
  static String failPayment(String id) => '/payments/$id/fail';
  static String refundPayment(String id) => '/payments/$id/refund';
}
