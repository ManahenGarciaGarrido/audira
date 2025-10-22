import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Payment } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const initiatePayment = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { amount, currency, paymentMethod, orderId } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    if (!amount || amount <= 0) {
      throw createError('BAD_REQUEST', 'El monto debe ser mayor a 0', 400);
    }

    if (!currency || !/^[A-Z]{3}$/.test(currency)) {
      throw createError('BAD_REQUEST', 'La moneda debe ser un código ISO de 3 letras', 400);
    }

    const payment: Payment = {
      id: uuidv4(),
      amount,
      currency,
      status: 'pending',
      paymentMethod,
      userId: authReq.user.id,
      createdAt: new Date().toISOString()
    };

    extendedStorage.createPayment(payment);
    res.status(201).json(payment);
  } catch (error) {
    next(error);
  }
};

export const getPaymentStatus = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { id } = req.params;

    const payment = extendedStorage.getPayment(id);
    if (!payment) {
      throw createError('NOT_FOUND', 'Pago no encontrado', 404, { resource: 'payment', id });
    }

    if (!authReq.user || authReq.user.id !== payment.userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver este pago', 403);
    }

    res.status(200).json(payment);
  } catch (error) {
    next(error);
  }
};

export const getUserPaymentHistory = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;
    const { limit = 20, offset = 0 } = req.query;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver este historial', 403);
    }

    const allPayments = extendedStorage.getPaymentsByUser(userId);
    const paginatedPayments = allPayments.slice(
      Number(offset),
      Number(offset) + Number(limit)
    );

    res.status(200).json(paginatedPayments);
  } catch (error) {
    next(error);
  }
};

export const paymentGatewayWebhook = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { eventType, paymentId, status } = req.body;

    // In production, verify webhook signature here
    // const signature = req.headers['x-webhook-signature'];

    if (!paymentId) {
      throw createError('BAD_REQUEST', 'Payment ID es requerido', 400);
    }

    const payment = extendedStorage.getPayment(paymentId);
    if (!payment) {
      throw createError('NOT_FOUND', 'Pago no encontrado', 404, { resource: 'payment', id: paymentId });
    }

    // Update payment status based on webhook
    if (status === 'completed' || status === 'failed') {
      extendedStorage.updatePayment(paymentId, { status });
    }

    res.status(200).json({ message: 'Webhook procesado exitosamente' });
  } catch (error) {
    next(error);
  }
};
