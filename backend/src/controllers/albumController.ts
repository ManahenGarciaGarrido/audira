import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Album } from '../types';
import { createError } from '../utils/errors';

export const getAllAlbums = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const albums = extendedStorage.getAllAlbums();
    res.status(200).json(albums);
  } catch (error) {
    next(error);
  }
};

export const getAlbumById = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const album = extendedStorage.getAlbum(id);
    if (!album) {
      throw createError('NOT_FOUND', 'Álbum no encontrado', 404, { resource: 'album', id });
    }
    res.status(200).json(album);
  } catch (error) {
    next(error);
  }
};

export const getAlbumsByArtist = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { artistId } = req.params;
    const albums = extendedStorage.getAlbumsByArtist(artistId);
    res.status(200).json(albums);
  } catch (error) {
    next(error);
  }
};

export const createAlbum = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { title, artistId, genre } = req.body;
    const album: Album = {
      id: uuidv4(),
      title,
      artistId,
      releaseDate: new Date().toISOString().split('T')[0],
      genre
    };
    extendedStorage.createAlbum(album);
    res.status(201).json(album);
  } catch (error) {
    next(error);
  }
};

export const updateAlbum = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const { title, genre } = req.body;
    const success = extendedStorage.updateAlbum(id, { title, genre });
    if (!success) {
      throw createError('NOT_FOUND', 'Álbum no encontrado', 404, { resource: 'album', id });
    }
    res.status(200).json(extendedStorage.getAlbum(id));
  } catch (error) {
    next(error);
  }
};

export const deleteAlbum = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const success = extendedStorage.deleteAlbum(id);
    if (!success) {
      throw createError('NOT_FOUND', 'Álbum no encontrado', 404, { resource: 'album', id });
    }
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
