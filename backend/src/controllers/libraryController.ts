import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { LibraryItem, Library } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const getUserLibrary = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver esta biblioteca', 403);
    }

    const allItems = extendedStorage.getLibrary(userId);
    const paginatedItems = allItems.slice(
      Number(offset),
      Number(offset) + Number(limit)
    );

    const response: Library = {
      userId,
      items: paginatedItems,
      total: allItems.length
    };

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
};

export const addItemToLibrary = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;
    const { itemId, type, name, artistName, albumName } = req.body;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta biblioteca', 403);
    }

    // Check if item already exists
    const existingItems = extendedStorage.getLibrary(userId);
    const exists = existingItems.some(item => item.itemId === itemId);

    if (exists) {
      throw createError('CONFLICT', 'El elemento ya está en la biblioteca', 409);
    }

    const libraryItem: LibraryItem = {
      id: uuidv4(),
      itemId,
      type,
      name,
      artistName,
      albumName,
      addedAt: new Date().toISOString()
    };

    extendedStorage.addToLibrary(userId, libraryItem);
    res.status(201).json({ message: 'Elemento añadido exitosamente' });
  } catch (error) {
    next(error);
  }
};

export const removeFromLibrary = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, itemId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta biblioteca', 403);
    }

    const success = extendedStorage.removeFromLibrary(userId, itemId);
    if (!success) {
      throw createError('NOT_FOUND', 'Elemento no encontrado en la biblioteca', 404);
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
