import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Order } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const createOrder = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, items, total, status = 'pending' } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    if (!items || items.length === 0) {
      throw createError('BAD_REQUEST', 'La orden debe contener al menos un item', 400);
    }

    const order: Order = {
      id: uuidv4(),
      userId: authReq.user.id,
      items,
      total,
      status,
      createdAt: new Date().toISOString()
    };

    extendedStorage.createOrder(order);
    res.status(201).json(order);
  } catch (error) {
    next(error);
  }
};

export const getOrderById = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;

    const order = extendedStorage.getOrder(id);
    if (!order) {
      throw createError('NOT_FOUND', 'Orden no encontrada', 404, { resource: 'order', id });
    }

    if (!authReq.user || authReq.user.id !== order.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver esta orden', 403);
    }

    res.status(200).json(order);
  } catch (error) {
    next(error);
  }
};

export const getOrdersByUserId = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver estas órdenes', 403);
    }

    const orders = extendedStorage.getOrdersByUser(userId);
    res.status(200).json(orders);
  } catch (error) {
    next(error);
  }
};

export const updateOrder = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;
    const { status, items, total } = req.body;

    const order = extendedStorage.getOrder(id);
    if (!order) {
      throw createError('NOT_FOUND', 'Orden no encontrada', 404, { resource: 'order', id });
    }

    if (!authReq.user || authReq.user.id !== order.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar esta orden', 403);
    }

    const updates: any = {};
    if (status) updates.status = status;
    if (items) updates.items = items;
    if (total) updates.total = total;

    extendedStorage.updateOrder(id, updates);
    res.status(200).json(extendedStorage.getOrder(id));
  } catch (error) {
    next(error);
  }
};

export const deleteOrder = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;

    const order = extendedStorage.getOrder(id);
    if (!order) {
      throw createError('NOT_FOUND', 'Orden no encontrada', 404, { resource: 'order', id });
    }

    if (!authReq.user || authReq.user.id !== order.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para eliminar esta orden', 403);
    }

    extendedStorage.deleteOrder(id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
