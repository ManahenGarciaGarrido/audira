import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { storage } from '../models/storage';
import { Rating } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const createRating = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { productId, rating, comment } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const ratingData: Rating = {
      id: uuidv4(),
      productId,
      userId: authReq.user.id,
      rating,
      comment,
      createdAt: new Date().toISOString()
    };

    storage.createRating(ratingData);
    res.status(201).json(ratingData);
  } catch (error) {
    next(error);
  }
};

export const updateRating = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;
    const { rating, comment } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const existingRating = storage.getRating(id);
    if (!existingRating) {
      throw createError('NOT_FOUND', 'Valoración no encontrada', 404, {
        resource: 'rating',
        id
      });
    }

    if (existingRating.userId !== authReq.user.id) {
      throw createError('FORBIDDEN', 'No tienes permiso para actualizar esta valoración', 403);
    }

    const updates: Partial<Rating> = {};
    if (rating !== undefined) updates.rating = rating;
    if (comment !== undefined) updates.comment = comment;

    storage.updateRating(id, updates);

    const updatedRating = storage.getRating(id);
    res.status(200).json(updatedRating);
  } catch (error) {
    next(error);
  }
};

export const deleteRating = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const existingRating = storage.getRating(id);
    if (!existingRating) {
      throw createError('NOT_FOUND', 'Valoración no encontrada', 404, {
        resource: 'rating',
        id
      });
    }

    if (existingRating.userId !== authReq.user.id) {
      throw createError('FORBIDDEN', 'No tienes permiso para eliminar esta valoración', 403);
    }

    storage.deleteRating(id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const getRatingsByProduct = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { productId } = req.params;

    const ratings = storage.getRatingsByProduct(productId);
    res.status(200).json(ratings);
  } catch (error) {
    next(error);
  }
};
