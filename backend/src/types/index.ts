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
