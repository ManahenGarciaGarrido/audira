import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { storage } from '../models/storage';
import { ContactMessageResponse, Notification } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const sendContactMessage = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { name, email, subject, message } = req.body;

    // In production, this would send an email or create a support ticket
    const messageId = `msg_${uuidv4().substring(0, 8)}`;

    const response: ContactMessageResponse = {
      messageId,
      status: 'Message received successfully'
    };

    console.log(`Contact message received from ${name} (${email}): ${subject}`);

    res.status(201).json(response);
  } catch (error) {
    next(error);
  }
};

export const getFAQs = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const faqs = storage.getFAQs();
    res.status(200).json(faqs);
  } catch (error) {
    next(error);
  }
};

export const getUserNotifications = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    // Check if user is requesting their own notifications
    if (authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver estas notificaciones', 403);
    }

    const user = storage.getUser(userId);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id: userId
      });
    }

    const notifications = storage.getNotifications(userId);
    res.status(200).json(notifications);
  } catch (error) {
    next(error);
  }
};
