// In-memory storage for demo purposes
// In production, this would be replaced with a real database

import { UserProfile, Rating, Comment, FAQ, Notification } from '../types';

// Storage interfaces
interface UserStore extends UserProfile {
  password: string;
}

class InMemoryStorage {
  private users: Map<string, UserStore> = new Map();
  private ratings: Map<string, Rating> = new Map();
  private comments: Map<string, Comment> = new Map();
  private faqs: FAQ[] = [];
  private notifications: Map<string, Notification[]> = new Map();
  private followers: Map<string, Set<string>> = new Map();
  private following: Map<string, Set<string>> = new Map();
  private blacklistedTokens: Set<string> = new Set();

  constructor() {
    this.initializeFAQs();
  }

  private initializeFAQs() {
    this.faqs = [
      {
        id: 'faq-001',
        question: '¿Cómo puedo crear una playlist?',
        answer: "Puedes crear una playlist desde la sección 'Biblioteca' haciendo clic en el botón 'Nueva Playlist'."
      },
      {
        id: 'faq-002',
        question: '¿Cómo puedo seguir a un artista?',
        answer: 'Visita el perfil del artista y haz clic en el botón "Seguir".'
      },
      {
        id: 'faq-003',
        question: '¿Cómo descargo música para escuchar sin conexión?',
        answer: 'Selecciona la canción o álbum y activa la opción "Disponible sin conexión".'
      }
    ];
  }

  // User methods
  getUser(id: string): UserStore | undefined {
    return this.users.get(id);
  }

  getUserByEmail(email: string): UserStore | undefined {
    return Array.from(this.users.values()).find(u => u.email === email);
  }

  createUser(user: UserStore): void {
    this.users.set(user.id, user);
    this.followers.set(user.id, new Set());
    this.following.set(user.id, new Set());
  }

  updateUser(id: string, updates: Partial<UserStore>): boolean {
    const user = this.users.get(id);
    if (!user) return false;
    this.users.set(id, { ...user, ...updates });
    return true;
  }

  deleteUser(id: string): boolean {
    return this.users.delete(id);
  }

  // Follower methods
  getFollowers(userId: string): string[] {
    return Array.from(this.followers.get(userId) || []);
  }

  getFollowing(userId: string): string[] {
    return Array.from(this.following.get(userId) || []);
  }

  addFollower(userId: string, followerId: string): void {
    if (!this.followers.has(userId)) {
      this.followers.set(userId, new Set());
    }
    if (!this.following.has(followerId)) {
      this.following.set(followerId, new Set());
    }
    this.followers.get(userId)!.add(followerId);
    this.following.get(followerId)!.add(userId);
  }

  removeFollower(userId: string, followerId: string): void {
    this.followers.get(userId)?.delete(followerId);
    this.following.get(followerId)?.delete(userId);
  }

  // Rating methods
  getRating(id: string): Rating | undefined {
    return this.ratings.get(id);
  }

  getRatingsByProduct(productId: string): Rating[] {
    return Array.from(this.ratings.values()).filter(r => r.productId === productId);
  }

  createRating(rating: Rating): void {
    this.ratings.set(rating.id, rating);
  }

  updateRating(id: string, updates: Partial<Rating>): boolean {
    const rating = this.ratings.get(id);
    if (!rating) return false;
    this.ratings.set(id, { ...rating, ...updates });
    return true;
  }

  deleteRating(id: string): boolean {
    return this.ratings.delete(id);
  }

  // Comment methods
  getComment(id: string): Comment | undefined {
    return this.comments.get(id);
  }

  getCommentsByProduct(productId: string): Comment[] {
    return Array.from(this.comments.values()).filter(c => c.productId === productId);
  }

  createComment(comment: Comment): void {
    this.comments.set(comment.id, comment);
  }

  updateComment(id: string, updates: Partial<Comment>): boolean {
    const comment = this.comments.get(id);
    if (!comment) return false;
    this.comments.set(id, { ...comment, ...updates });
    return true;
  }

  deleteComment(id: string): boolean {
    return this.comments.delete(id);
  }

  // FAQ methods
  getFAQs(): FAQ[] {
    return this.faqs;
  }

  // Notification methods
  getNotifications(userId: string): Notification[] {
    return this.notifications.get(userId) || [];
  }

  addNotification(userId: string, notification: Notification): void {
    if (!this.notifications.has(userId)) {
      this.notifications.set(userId, []);
    }
    this.notifications.get(userId)!.push(notification);
  }

  // Token blacklist methods
  blacklistToken(token: string): void {
    this.blacklistedTokens.add(token);
  }

  isTokenBlacklisted(token: string): boolean {
    return this.blacklistedTokens.has(token);
  }

  // Stats methods
  getUserCount(): number {
    return this.users.size;
  }

  getRatingCount(): number {
    return this.ratings.size;
  }

  getCommentCount(): number {
    return this.comments.size;
  }
}

export const storage = new InMemoryStorage();
