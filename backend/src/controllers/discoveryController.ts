import { Request, Response, NextFunction } from 'express';
import { extendedStorage } from '../models/storageExtended';
import { createError } from '../utils/errors';

export const searchContent = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { query } = req.query;
    if (!query || typeof query !== 'string') {
      throw createError('BAD_REQUEST', 'Query parameter is required', 400);
    }
    const songs = extendedStorage.searchSongs(query);
    res.status(200).json(songs);
  } catch (error) {
    next(error);
  }
};

export const getUserRecommendations = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { userId } = req.params;
    // Mock recommendations - in production this would use a recommendation algorithm
    const allSongs = extendedStorage.getAllSongs();
    const recommendations = allSongs.slice(0, 10);
    res.status(200).json(recommendations);
  } catch (error) {
    next(error);
  }
};

export const getTrendingContent = (req: Request, res: Response, next: NextFunction): void => {
  try {
    // Mock trending - in production this would be based on actual metrics
    const albums = extendedStorage.getAllAlbums();
    const trending = albums.slice(0, 10);
    res.status(200).json(trending);
  } catch (error) {
    next(error);
  }
};
