import { Request, Response, NextFunction } from 'express';
import { storage } from '../models/storage';
import { UserMetrics, ArtistMetrics, SongMetrics, GlobalMetrics } from '../types';
import { createError } from '../utils/errors';

export const getUserMetrics = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;

    const user = storage.getUser(id);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id
      });
    }

    const followers = storage.getFollowers(id);

    // Mock data for posts and likes - in production these would come from database
    const metrics: UserMetrics = {
      posts: Math.floor(Math.random() * 100),
      followers: followers.length,
      likes: Math.floor(Math.random() * 10000)
    };

    res.status(200).json(metrics);
  } catch (error) {
    next(error);
  }
};

export const getArtistMetrics = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;

    // In production, this would check if the artist exists in the database
    // For now, we'll return mock data
    const metrics: ArtistMetrics = {
      albums: Math.floor(Math.random() * 20) + 1,
      followers: Math.floor(Math.random() * 1000000),
      streams: Math.floor(Math.random() * 50000000)
    };

    res.status(200).json(metrics);
  } catch (error) {
    next(error);
  }
};

export const getSongMetrics = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;

    // In production, this would check if the song exists in the database
    // For now, we'll return mock data
    const metrics: SongMetrics = {
      plays: Math.floor(Math.random() * 1000000),
      likes: Math.floor(Math.random() * 50000),
      shares: Math.floor(Math.random() * 10000)
    };

    res.status(200).json(metrics);
  } catch (error) {
    next(error);
  }
};

export const getGlobalMetrics = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const userCount = storage.getUserCount();

    const metrics: GlobalMetrics = {
      totalUsers: userCount,
      totalArtists: Math.floor(userCount * 0.1), // Mock: 10% of users are artists
      totalStreams: Math.floor(userCount * 1000) // Mock: average 1000 streams per user
    };

    res.status(200).json(metrics);
  } catch (error) {
    next(error);
  }
};
