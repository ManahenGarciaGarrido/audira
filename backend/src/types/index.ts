import { Request } from 'express';

// User Types
export interface UserProfile {
  id: string;
  username: string;
  email: string;
  followers: number;
  following: number;
  bio?: string;
}

export interface UserRegister {
  username: string;
  email: string;
  password: string;
}

export interface UserLogin {
  email: string;
  password: string;
}

export interface UserUpdate {
  username?: string;
  email?: string;
  bio?: string;
}

export interface AuthResponse {
  token: string;
  expiresIn: number;
}

// Metrics Types
export interface UserMetrics {
  posts: number;
  followers: number;
  likes: number;
}

export interface ArtistMetrics {
  albums: number;
  followers: number;
  streams: number;
}

export interface SongMetrics {
  plays: number;
  likes: number;
  shares: number;
}

export interface GlobalMetrics {
  totalUsers: number;
  totalArtists: number;
  totalStreams: number;
}

// Rating & Comment Types
export interface Rating {
  id: string;
  productId: string;
  userId: string;
  rating: number;
  comment?: string;
  createdAt: string;
}

export interface Comment {
  id: string;
  productId: string;
  userId: string;
  content: string;
  createdAt: string;
}

// Communication Types
export interface ContactMessageRequest {
  name: string;
  email: string;
  subject: string;
  message: string;
}

export interface ContactMessageResponse {
  messageId: string;
  status: string;
}

export interface FAQ {
  id: string;
  question: string;
  answer: string;
}

export interface Notification {
  notificationId: string;
  title: string;
  message: string;
  read: boolean;
  createdAt: string;
}

// Error Types
export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
  timestamp: string;
  path: string;
  requestId: string;
}

// Express Request Extension
export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
  };
}

// ==================== ÉPICA 2: Catálogo Musical y Contenido ====================

// Genre Types
export interface Genre {
  id: string;
  name: string;
  description?: string;
}

// Album Types
export interface Album {
  id: string;
  title: string;
  artistId: string;
  releaseDate?: string;
  genre?: string;
}

export interface AlbumCreate {
  title: string;
  artistId: string;
  genre?: string;
}

export interface AlbumUpdate {
  title?: string;
  genre?: string;
}

// Song Types
export interface Song {
  id: string;
  title: string;
  artistId: string;
  albumId?: string;
  duration?: number;
  genre?: string;
}

export interface SongCreate {
  title: string;
  artistId: string;
  albumId?: string;
  genre?: string;
  duration?: number;
}

export interface SongUpdate {
  title?: string;
  genre?: string;
  duration?: number;
}

// Collaboration Types
export type CollaborationType = 'song' | 'album' | 'remix' | 'feature';
export type CollaborationStatus = 'draft' | 'active' | 'completed' | 'cancelled';
export type ParticipantRole = 'lead_artist' | 'featured_artist' | 'producer' | 'songwriter';
export type ParticipantStatus = 'invited' | 'accepted' | 'declined';

export interface CollaborationParticipant {
  id: string;
  artistId: string;
  artistName?: string;
  role: ParticipantRole;
  status: ParticipantStatus;
}

export interface Collaboration {
  id: string;
  title: string;
  description?: string;
  status: CollaborationStatus;
  type: CollaborationType;
  initiatorId: string;
  participants: CollaborationParticipant[];
  createdAt?: string;
  updatedAt?: string;
}

export interface CreateCollaborationRequest {
  title: string;
  description?: string;
  type: CollaborationType;
  participants: Array<{
    artistId: string;
    role: ParticipantRole;
  }>;
}

export interface UpdateCollaborationRequest {
  title?: string;
  description?: string;
  status?: CollaborationStatus;
  participants?: Array<{
    artistId: string;
    role: ParticipantRole;
  }>;
}

export interface InviteArtistRequest {
  artistId: string;
  role: ParticipantRole;
  message?: string;
}

// ==================== ÉPICA 3: Reproducción y Experiencia del Usuario ====================

// Player Types
export interface StreamResponse {
  streamUrl: string;
  songId: string;
  message?: string;
}

export interface PreviewResponse {
  previewUrl: string;
  songId: string;
}

export interface DownloadResponse {
  downloadUrl: string;
  songId: string;
}

export interface QueueItem {
  songId: string;
  title: string;
  artist: string;
  duration: number;
}

export interface QueueResponse {
  userId: string;
  queue: QueueItem[];
}

// Library Types
export type LibraryItemType = 'song' | 'album' | 'playlist';

export interface LibraryItem {
  id: string;
  itemId: string;
  type: LibraryItemType;
  name: string;
  artistName?: string;
  albumName?: string;
  addedAt: string;
}

export interface Library {
  userId: string;
  items: LibraryItem[];
  total: number;
}

// Playlist Types
export interface Playlist {
  id: string;
  name: string;
  description?: string;
  userId: string;
  isPublic: boolean;
  songCount: number;
  coverUrl?: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreatePlaylistRequest {
  name: string;
  description?: string;
  isPublic?: boolean;
}

export interface UpdatePlaylistRequest {
  name?: string;
  description?: string;
  isPublic?: boolean;
}

export interface PlaylistSong {
  id: string;
  songId: string;
  name: string;
  artistName?: string;
  albumName?: string;
  duration?: number;
  position: number;
  addedAt: string;
}

export interface AddSongToPlaylistRequest {
  songId: string;
  position?: number;
}

export interface PlaylistMetrics {
  totalSongs: number;
  totalPlays: number;
  likes: number;
}

// ==================== ÉPICA 4: Tienda, Carrito y Pagos ====================

// Store Types
export interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  inStock: boolean;
}

export interface Category {
  id: string;
  name: string;
}

export interface ProductFilters {
  categories?: string[];
  brands?: string[];
  priceRanges?: string[];
}

// Cart Types
export interface CartItem {
  itemId: string;
  name: string;
  quantity: number;
  price: number;
}

export interface Cart {
  userId: string;
  items: CartItem[];
  totalAmount: number;
}

export interface CartTotal {
  totalAmount: number;
  currency: string;
  itemCount: number;
}

export interface UpdateCartItemRequest {
  quantity: number;
}

// Order Types
export type OrderStatus = 'pending' | 'paid' | 'shipped' | 'delivered' | 'cancelled';

export interface OrderItem {
  itemId: string;
  name: string;
  quantity: number;
  price: number;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  total: number;
  status: OrderStatus;
  createdAt: string;
}

// Payment Types
export type PaymentStatus = 'pending' | 'completed' | 'failed' | 'refunded';
export type PaymentMethod = 'stripe' | 'paypal' | 'credit_card';

export interface PaymentRequest {
  amount: number;
  currency: string;
  paymentMethod: PaymentMethod;
  orderId?: string;
}

export interface Payment {
  id: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  paymentMethod: string;
  userId: string;
  createdAt: string;
}

export interface WebhookPayload {
  eventType: string;
  paymentId: string;
  status: 'completed' | 'failed';
}
