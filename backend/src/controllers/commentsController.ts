import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { storage } from '../models/storage';
import { Comment } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const createComment = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { productId, content } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const commentData: Comment = {
      id: uuidv4(),
      productId,
      userId: authReq.user.id,
      content,
      createdAt: new Date().toISOString()
    };

    storage.createComment(commentData);
    res.status(201).json(commentData);
  } catch (error) {
    next(error);
  }
};

export const updateComment = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;
    const { content } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const existingComment = storage.getComment(id);
    if (!existingComment) {
      throw createError('NOT_FOUND', 'Comentario no encontrado', 404, {
        resource: 'comment',
        id
      });
    }

    if (existingComment.userId !== authReq.user.id) {
      throw createError('FORBIDDEN', 'No tienes permiso para actualizar este comentario', 403);
    }

    storage.updateComment(id, { content });

    const updatedComment = storage.getComment(id);
    res.status(200).json(updatedComment);
  } catch (error) {
    next(error);
  }
};

export const deleteComment = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const existingComment = storage.getComment(id);
    if (!existingComment) {
      throw createError('NOT_FOUND', 'Comentario no encontrado', 404, {
        resource: 'comment',
        id
      });
    }

    if (existingComment.userId !== authReq.user.id) {
      throw createError('FORBIDDEN', 'No tienes permiso para eliminar este comentario', 403);
    }

    storage.deleteComment(id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const getCommentsByProduct = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { productId } = req.params;

    const comments = storage.getCommentsByProduct(productId);
    res.status(200).json(comments);
  } catch (error) {
    next(error);
  }
};
