import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Song } from '../types';
import { createError } from '../utils/errors';

export const getAllSongs = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const songs = extendedStorage.getAllSongs();
    res.status(200).json(songs);
  } catch (error) {
    next(error);
  }
};

export const getSongById = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const song = extendedStorage.getSong(id);
    if (!song) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id });
    }
    res.status(200).json(song);
  } catch (error) {
    next(error);
  }
};

export const createSong = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { title, artistId, albumId, genre, duration } = req.body;
    const song: Song = {
      id: uuidv4(),
      title,
      artistId,
      albumId,
      duration,
      genre
    };
    extendedStorage.createSong(song);
    res.status(201).json(song);
  } catch (error) {
    next(error);
  }
};

export const updateSong = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const { title, genre, duration } = req.body;
    const success = extendedStorage.updateSong(id, { title, genre, duration });
    if (!success) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id });
    }
    res.status(200).json(extendedStorage.getSong(id));
  } catch (error) {
    next(error);
  }
};

export const deleteSong = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const success = extendedStorage.deleteSong(id);
    if (!success) {
      throw createError('NOT_FOUND', 'Canción no encontrada', 404, { resource: 'song', id });
    }
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
