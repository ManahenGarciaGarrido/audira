import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Playlist, PlaylistSong, PlaylistMetrics } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const createPlaylist = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { name, description, isPublic = false } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const playlist: Playlist = {
      id: uuidv4(),
      name,
      description,
      userId: authReq.user.id,
      isPublic,
      songCount: 0,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    extendedStorage.createPlaylist(playlist);
    res.status(201).json(playlist);
  } catch (error) {
    next(error);
  }
};

export const getUserPlaylists = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { userId } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    const allPlaylists = extendedStorage.getPlaylistsByUser(userId);
    const paginatedPlaylists = allPlaylists.slice(
      Number(offset),
      Number(offset) + Number(limit)
    );

    res.status(200).json({
      playlists: paginatedPlaylists,
      total: allPlaylists.length
    });
  } catch (error) {
    next(error);
  }
};

export const getPlaylistDetails = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const playlist = extendedStorage.getPlaylist(id);

    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    res.status(200).json(playlist);
  } catch (error) {
    next(error);
  }
};

export const getPlaylistMetrics = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const playlist = extendedStorage.getPlaylist(id);

    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    // Mock metrics - in production these would be real metrics
    const metrics: PlaylistMetrics = {
      totalSongs: playlist.songCount,
      totalPlays: Math.floor(Math.random() * 10000),
      likes: Math.floor(Math.random() * 1000)
    };

    res.status(200).json(metrics);
  } catch (error) {
    next(error);
  }
};

export const updatePlaylist = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;
    const { name, description, isPublic } = req.body;

    const playlist = extendedStorage.getPlaylist(id);
    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    if (!authReq.user || authReq.user.id !== playlist.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta playlist', 403);
    }

    const updates: any = {};
    if (name) updates.name = name;
    if (description !== undefined) updates.description = description;
    if (isPublic !== undefined) updates.isPublic = isPublic;

    extendedStorage.updatePlaylist(id, updates);
    res.status(200).json(extendedStorage.getPlaylist(id));
  } catch (error) {
    next(error);
  }
};

export const deletePlaylist = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;

    const playlist = extendedStorage.getPlaylist(id);
    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    if (!authReq.user || authReq.user.id !== playlist.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para eliminar esta playlist', 403);
    }

    extendedStorage.deletePlaylist(id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const getPlaylistSongs = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    const playlist = extendedStorage.getPlaylist(id);
    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    const allSongs = extendedStorage.getPlaylistSongs(id);
    const paginatedSongs = allSongs.slice(
      Number(offset),
      Number(offset) + Number(limit)
    );

    res.status(200).json({
      songs: paginatedSongs,
      total: allSongs.length
    });
  } catch (error) {
    next(error);
  }
};

export const addSongToPlaylist = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;
    const { songId, position } = req.body;

    const playlist = extendedStorage.getPlaylist(id);
    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    if (!authReq.user || authReq.user.id !== playlist.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta playlist', 403);
    }

    const song = extendedStorage.getSong(songId);
    if (!song) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id: songId });
    }

    // Get the artist name
    const artist = extendedStorage.getAlbum(song.albumId || '');
    const artistName = artist?.artistName || 'Unknown Artist';

    // Check if song already exists in playlist
    const existingSongs = extendedStorage.getPlaylistSongs(id);
    const exists = existingSongs.some(s => s.songId === songId);
    if (exists) {
      throw createError('CONFLICT', 'La canción ya está en la playlist', 409);
    }

    const playlistSong: PlaylistSong = {
      id: uuidv4(),
      songId,
      name: song.title,
      artistName,
      duration: song.duration,
      position: position || existingSongs.length + 1,
      addedAt: new Date().toISOString()
    };

    extendedStorage.addSongToPlaylist(id, playlistSong);
    res.status(201).json({ message: 'Canción añadida exitosamente' });
  } catch (error) {
    next(error);
  }
};

export const removeSongFromPlaylist = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id, songId } = req.params;

    const playlist = extendedStorage.getPlaylist(id);
    if (!playlist) {
      throw createError('NOT_FOUND', 'Playlist no encontrada', 404, { resource: 'playlist', id });
    }

    if (!authReq.user || authReq.user.id !== playlist.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta playlist', 403);
    }

    const success = extendedStorage.removeSongFromPlaylist(id, songId);
    if (!success) {
      throw createError('NOT_FOUND', 'Canción no encontrada en la playlist', 404);
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
