import { Request, Response, NextFunction } from 'express';
import { extendedStorage } from '../models/storageExtended';
import { StreamResponse, PreviewResponse, DownloadResponse, QueueResponse } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const getSongStream = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { songId } = req.params;
    const song = extendedStorage.getSong(songId);

    if (!song) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id: songId });
    }

    // Mock streaming URL - in production this would be a real CDN URL
    const response: StreamResponse = {
      streamUrl: `https://cdn.audira.io/stream/${songId}`,
      songId,
      message: 'Streaming started'
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const getSongPreview = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { songId } = req.params;
    const song = extendedStorage.getSong(songId);

    if (!song) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id: songId });
    }

    const response: PreviewResponse = {
      previewUrl: `https://cdn.audira.io/preview/${songId}`,
      songId
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const getSongDownloadLink = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { songId } = req.params;
    const song = extendedStorage.getSong(songId);

    if (!song) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id: songId });
    }

    const response: DownloadResponse = {
      downloadUrl: `https://cdn.audira.io/download/${songId}`,
      songId
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const updateUserPlaybackProgress = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, songId } = req.params;
    const { progress } = req.body;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para actualizar este progreso', 403);
    }

    if (typeof progress !== 'number' || progress < 0) {
      throw createError('BAD_REQUEST', 'El progreso debe ser un número positivo', 400);
    }

    extendedStorage.setProgress(userId, songId, progress);
    res.status(200).json({ message: 'Progreso actualizado correctamente' });
  } catch (error) {
    next(error);
  }
};

export const getUserPlaybackQueue = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver esta cola', 403);
    }

    const queue = extendedStorage.getQueue(userId);
    const response: QueueResponse = {
      userId,
      queue
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const setUserPlaybackQueue = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;
    const { queue } = req.body;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta cola', 403);
    }

    if (!Array.isArray(queue)) {
      throw createError('BAD_REQUEST', 'La cola debe ser un array', 400);
    }

    extendedStorage.setQueue(userId, queue);
    res.status(200).json({ message: 'Cola actualizada correctamente', queue });
  } catch (error) {
    next(error);
  }
};

export const addToUserPlaybackQueue = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;
    const { songId } = req.body;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta cola', 403);
    }

    const song = extendedStorage.getSong(songId);
    if (!song) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id: songId });
    }

    const queueItem = {
      songId: song.id,
      title: song.title,
      artistId: song.artistId,
      duration: song.duration
    };

    extendedStorage.addToQueue(userId, queueItem);
    res.status(201).json({ message: 'Canción añadida a la cola', item: queueItem });
  } catch (error) {
    next(error);
  }
};

export const removeFromUserPlaybackQueue = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, songId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta cola', 403);
    }

    const success = extendedStorage.removeFromQueue(userId, songId);
    if (!success) {
      throw createError('NOT_FOUND', 'Canción no encontrada en la cola', 404);
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const clearUserPlaybackQueue = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta cola', 403);
    }

    extendedStorage.clearQueue(userId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
