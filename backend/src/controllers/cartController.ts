import { Request, Response, NextFunction } from 'express';
import { extendedStorage } from '../models/storageExtended';
import { CartItem } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const getCartByUserId = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver este carrito', 403);
    }

    const cart = extendedStorage.getCart(userId);
    if (!cart) {
      // Return empty cart if it doesn't exist
      res.status(200).json({
        userId,
        items: [],
        totalAmount: 0
      });
      return;
    }

    res.status(200).json(cart);
  } catch (error) {
    next(error);
  }
};

export const getCartTotalByUserId = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para ver este carrito', 403);
    }

    const cart = extendedStorage.getCart(userId);
    const totalAmount = cart?.totalAmount || 0;
    const itemCount = cart?.items.length || 0;

    res.status(200).json({
      totalAmount,
      currency: 'USD',
      itemCount
    });
  } catch (error) {
    next(error);
  }
};

export const addItemToCart = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, itemId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar este carrito', 403);
    }

    const product = extendedStorage.getProduct(itemId);
    if (!product) {
      throw createError('NOT_FOUND', 'Producto no encontrado', 404, { resource: 'product', id: itemId });
    }

    const cartItem: CartItem = {
      itemId,
      name: product.name,
      quantity: 1,
      price: product.price
    };

    extendedStorage.addItemToCart(userId, cartItem);
    res.status(201).json({ message: 'Ítem añadido correctamente' });
  } catch (error) {
    next(error);
  }
};

export const updateCartItemQuantity = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, itemId } = req.params;
    const { quantity } = req.body;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar este carrito', 403);
    }

    if (!quantity || quantity < 1) {
      throw createError('BAD_REQUEST', 'La cantidad debe ser al menos 1', 400);
    }

    const success = extendedStorage.updateCartItem(userId, itemId, quantity);
    if (!success) {
      throw createError('NOT_FOUND', 'Ítem no encontrado en el carrito', 404);
    }

    res.status(200).json({ message: 'Ítem actualizado correctamente' });
  } catch (error) {
    next(error);
  }
};

export const removeItemFromCart = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId, itemId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para modificar este carrito', 403);
    }

    const success = extendedStorage.removeCartItem(userId, itemId);
    if (!success) {
      throw createError('NOT_FOUND', 'Ítem no encontrado en el carrito', 404);
    }

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const deleteCartByUserId = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { userId } = req.params;

    if (!authReq.user || authReq.user.id !== userId) {
      throw createError('FORBIDDEN', 'No tienes permiso para eliminar este carrito', 403);
    }

    extendedStorage.deleteCart(userId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
