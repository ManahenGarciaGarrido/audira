// Extended in-memory storage for ÉPICAS 2, 3, 4
import {
  Genre, Album, Song, Collaboration,
  Playlist, PlaylistSong, LibraryItem,
  Product, Category, Cart, CartItem,
  Order, Payment
} from '../types';
import { storage as baseStorage } from './storage';

class ExtendedStorage {
  // ÉPICA 2 - Catálogo Musical
  private genres: Map<string, Genre> = new Map();
  private albums: Map<string, Album> = new Map();
  private songs: Map<string, Song> = new Map();
  private collaborations: Map<string, Collaboration> = new Map();

  // ÉPICA 3 - Reproducción y Experiencia
  private playlists: Map<string, Playlist> = new Map();
  private playlistSongs: Map<string, PlaylistSong[]> = new Map();
  private libraries: Map<string, LibraryItem[]> = new Map();
  private playbackQueues: Map<string, any[]> = new Map();
  private playbackProgress: Map<string, Map<string, number>> = new Map();

  // ÉPICA 4 - Tienda y Pagos
  private products: Map<string, Product> = new Map();
  private categories: Map<string, Category> = new Map();
  private carts: Map<string, Cart> = new Map();
  private orders: Map<string, Order> = new Map();
  private payments: Map<string, Payment> = new Map();

  constructor() {
    this.initializeGenres();
    this.initializeProducts();
    this.initializeCategories();
  }

  private initializeGenres() {
    const genres: Genre[] = [
      { id: 'genre-001', name: 'Rock', description: 'Un género musical de ritmo marcado.' },
      { id: 'genre-002', name: 'Pop', description: 'Música popular contemporánea.' },
      { id: 'genre-003', name: 'Jazz', description: 'Género musical con improvisación.' },
      { id: 'genre-004', name: 'Electronic', description: 'Música electrónica.' },
      { id: 'genre-005', name: 'Hip Hop', description: 'Género urbano con rap.' }
    ];
    genres.forEach(g => this.genres.set(g.id, g));
  }

  private initializeProducts() {
    const products: Product[] = [
      { id: 'prod_001', name: 'Merchandise T-Shirt', description: 'High-quality cotton t-shirt', price: 25.99, inStock: true },
      { id: 'prod_002', name: 'Vinyl Record', description: 'Limited edition vinyl', price: 39.99, inStock: true },
      { id: 'prod_003', name: 'Concert Ticket', description: 'VIP access ticket', price: 150.00, inStock: false }
    ];
    products.forEach(p => this.products.set(p.id, p));
  }

  private initializeCategories() {
    const categories: Category[] = [
      { id: 'cat_apparel', name: 'Apparel' },
      { id: 'cat_music', name: 'Music' },
      { id: 'cat_tickets', name: 'Tickets' }
    ];
    categories.forEach(c => this.categories.set(c.id, c));
  }

  // ==================== ÉPICA 2 Methods ====================
  getAllGenres() { return Array.from(this.genres.values()); }
  getGenre(id: string) { return this.genres.get(id); }
  createGenre(genre: Genre) { this.genres.set(genre.id, genre); }
  updateGenre(id: string, updates: Partial<Genre>) { const g = this.genres.get(id); if (!g) return false; this.genres.set(id, { ...g, ...updates }); return true; }
  deleteGenre(id: string) { return this.genres.delete(id); }

  getAllAlbums() { return Array.from(this.albums.values()); }
  getAlbum(id: string) { return this.albums.get(id); }
  getAlbumsByArtist(artistId: string) { return Array.from(this.albums.values()).filter(a => a.artistId === artistId); }
  createAlbum(album: Album) { this.albums.set(album.id, album); }
  updateAlbum(id: string, updates: Partial<Album>) { const a = this.albums.get(id); if (!a) return false; this.albums.set(id, { ...a, ...updates }); return true; }
  deleteAlbum(id: string) { return this.albums.delete(id); }

  getAllSongs() { return Array.from(this.songs.values()); }
  getSong(id: string) { return this.songs.get(id); }
  createSong(song: Song) { this.songs.set(song.id, song); }
  updateSong(id: string, updates: Partial<Song>) { const s = this.songs.get(id); if (!s) return false; this.songs.set(id, { ...s, ...updates }); return true; }
  deleteSong(id: string) { return this.songs.delete(id); }
  searchSongs(query: string) { return Array.from(this.songs.values()).filter(s => s.title.toLowerCase().includes(query.toLowerCase())); }

  getCollaboration(id: string) { return this.collaborations.get(id); }
  createCollaboration(collab: Collaboration) { this.collaborations.set(collab.id, collab); }
  updateCollaboration(id: string, updates: Partial<Collaboration>) { const c = this.collaborations.get(id); if (!c) return false; this.collaborations.set(id, { ...c, ...updates }); return true; }
  deleteCollaboration(id: string) { return this.collaborations.delete(id); }

  // ==================== ÉPICA 3 Methods ====================
  getPlaylist(id: string) { return this.playlists.get(id); }
  getPlaylistsByUser(userId: string) { return Array.from(this.playlists.values()).filter(p => p.userId === userId); }
  createPlaylist(playlist: Playlist) { this.playlists.set(playlist.id, playlist); this.playlistSongs.set(playlist.id, []); }
  updatePlaylist(id: string, updates: Partial<Playlist>) { const p = this.playlists.get(id); if (!p) return false; this.playlists.set(id, { ...p, ...updates, updatedAt: new Date().toISOString() }); return true; }
  deletePlaylist(id: string) { this.playlistSongs.delete(id); return this.playlists.delete(id); }

  getPlaylistSongs(playlistId: string) { return this.playlistSongs.get(playlistId) || []; }
  addSongToPlaylist(playlistId: string, song: PlaylistSong) {
    if (!this.playlistSongs.has(playlistId)) this.playlistSongs.set(playlistId, []);
    const songs = this.playlistSongs.get(playlistId)!;
    songs.push(song);
    const playlist = this.playlists.get(playlistId);
    if (playlist) {
      playlist.songCount = songs.length;
      playlist.updatedAt = new Date().toISOString();
    }
  }
  removeSongFromPlaylist(playlistId: string, songId: string) {
    const songs = this.playlistSongs.get(playlistId);
    if (!songs) return false;
    const filtered = songs.filter(s => s.songId !== songId);
    this.playlistSongs.set(playlistId, filtered);
    const playlist = this.playlists.get(playlistId);
    if (playlist) {
      playlist.songCount = filtered.length;
      playlist.updatedAt = new Date().toISOString();
    }
    return true;
  }

  getLibrary(userId: string) { return this.libraries.get(userId) || []; }
  addToLibrary(userId: string, item: LibraryItem) { if (!this.libraries.has(userId)) this.libraries.set(userId, []); this.libraries.get(userId)!.push(item); }
  removeFromLibrary(userId: string, itemId: string) { const items = this.libraries.get(userId); if (!items) return false; this.libraries.set(userId, items.filter(i => i.id !== itemId)); return true; }

  getQueue(userId: string) { return this.playbackQueues.get(userId) || []; }
  setQueue(userId: string, queue: any[]) { this.playbackQueues.set(userId, queue); }
  getProgress(userId: string, songId: string) { return this.playbackProgress.get(userId)?.get(songId) || 0; }
  setProgress(userId: string, songId: string, progress: number) {
    if (!this.playbackProgress.has(userId)) this.playbackProgress.set(userId, new Map());
    this.playbackProgress.get(userId)!.set(songId, progress);
  }

  // ==================== ÉPICA 4 Methods ====================
  getAllProducts() { return Array.from(this.products.values()); }
  getProduct(id: string) { return this.products.get(id); }

  getAllCategories() { return Array.from(this.categories.values()); }

  getCart(userId: string) { return this.carts.get(userId); }
  createCart(cart: Cart) { this.carts.set(cart.userId, cart); }
  updateCart(userId: string, updates: Partial<Cart>) { const cart = this.carts.get(userId); if (!cart) return false; this.carts.set(userId, { ...cart, ...updates }); return true; }
  deleteCart(userId: string) { return this.carts.delete(userId); }
  addItemToCart(userId: string, item: CartItem) {
    let cart = this.carts.get(userId);
    if (!cart) { cart = { userId, items: [], totalAmount: 0 }; this.carts.set(userId, cart); }
    const existingItem = cart.items.find(i => i.itemId === item.itemId);
    if (existingItem) { existingItem.quantity += item.quantity; }
    else { cart.items.push(item); }
    cart.totalAmount = cart.items.reduce((sum, i) => sum + (i.price * i.quantity), 0);
  }
  updateCartItem(userId: string, itemId: string, quantity: number) {
    const cart = this.carts.get(userId);
    if (!cart) return false;
    const item = cart.items.find(i => i.itemId === itemId);
    if (!item) return false;
    item.quantity = quantity;
    cart.totalAmount = cart.items.reduce((sum, i) => sum + (i.price * i.quantity), 0);
    return true;
  }
  removeCartItem(userId: string, itemId: string) {
    const cart = this.carts.get(userId);
    if (!cart) return false;
    cart.items = cart.items.filter(i => i.itemId !== itemId);
    cart.totalAmount = cart.items.reduce((sum, i) => sum + (i.price * i.quantity), 0);
    return true;
  }

  getOrder(id: string) { return this.orders.get(id); }
  getOrdersByUser(userId: string) { return Array.from(this.orders.values()).filter(o => o.userId === userId); }
  createOrder(order: Order) { this.orders.set(order.id, order); }
  updateOrder(id: string, updates: Partial<Order>) { const order = this.orders.get(id); if (!order) return false; this.orders.set(id, { ...order, ...updates }); return true; }
  deleteOrder(id: string) { return this.orders.delete(id); }

  getPayment(id: string) { return this.payments.get(id); }
  getPaymentsByUser(userId: string) { return Array.from(this.payments.values()).filter(p => p.userId === userId); }
  createPayment(payment: Payment) { this.payments.set(payment.id, payment); }
  updatePayment(id: string, updates: Partial<Payment>) { const payment = this.payments.get(id); if (!payment) return false; this.payments.set(id, { ...payment, ...updates }); return true; }
}

export const extendedStorage = new ExtendedStorage();
export { baseStorage as storage };
