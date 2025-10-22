import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Genre } from '../types';
import { createError } from '../utils/errors';

export const getAllGenres = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const genres = extendedStorage.getAllGenres();
    res.status(200).json(genres);
  } catch (error) {
    next(error);
  }
};

export const createGenre = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { name, description } = req.body;
    const genre: Genre = {
      id: uuidv4(),
      name,
      description
    };
    extendedStorage.createGenre(genre);
    res.status(201).json(genre);
  } catch (error) {
    next(error);
  }
};

export const updateGenre = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const { name, description } = req.body;
    const success = extendedStorage.updateGenre(id, { name, description });
    if (!success) {
      throw createError('NOT_FOUND', 'Género no encontrado', 404);
    }
    res.status(200).json(extendedStorage.getGenre(id));
  } catch (error) {
    next(error);
  }
};

export const deleteGenre = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const success = extendedStorage.deleteGenre(id);
    if (!success) {
      throw createError('NOT_FOUND', 'Género no encontrado', 404);
    }
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
