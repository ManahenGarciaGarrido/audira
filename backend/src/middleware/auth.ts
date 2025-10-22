import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { storage } from '../models/storage';
import { createError } from '../utils/errors';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
  };
}

export const authenticate = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError('UNAUTHORIZED', 'Token no proporcionado o formato inválido', 401);
    }

    const token = authHeader.substring(7);

    // Check if token is blacklisted
    if (storage.isTokenBlacklisted(token)) {
      throw createError('UNAUTHORIZED', 'Token inválido o expirado', 401);
    }

    const secret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
    const decoded = jwt.verify(token, secret) as { id: string; email: string };

    (req as AuthRequest).user = decoded;
    next();
  } catch (error: any) {
    if (error.name === 'JsonWebTokenError') {
      return next(createError('UNAUTHORIZED', 'Token inválido', 401));
    }
    if (error.name === 'TokenExpiredError') {
      return next(createError('UNAUTHORIZED', 'Token expirado', 401));
    }
    next(error);
  }
};

export const optionalAuth = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);

      if (!storage.isTokenBlacklisted(token)) {
        const secret = process.env.JWT_SECRET || 'your-secret-key-change-in-production';
        const decoded = jwt.verify(token, secret) as { id: string; email: string };
        (req as AuthRequest).user = decoded;
      }
    }
    next();
  } catch (error) {
    // For optional auth, we just continue without setting the user
    next();
  }
};
