import { Request, Response, NextFunction } from 'express';
import { extendedStorage } from '../models/storageExtended';
import { createError } from '../utils/errors';

export const getAllStoreProducts = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { limit = 20, offset = 0 } = req.query;
    const allProducts = extendedStorage.getAllProducts();
    const paginatedProducts = allProducts.slice(
      Number(offset),
      Number(offset) + Number(limit)
    );

    res.status(200).json({
      products: paginatedProducts,
      total: allProducts.length
    });
  } catch (error) {
    next(error);
  }
};

export const getStoreProductById = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const product = extendedStorage.getProduct(id);

    if (!product) {
      throw createError('NOT_FOUND', 'Producto no encontrado', 404, { resource: 'product', id });
    }

    res.status(200).json(product);
  } catch (error) {
    next(error);
  }
};

export const getAllProductCategories = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const categories = extendedStorage.getAllCategories();
    res.status(200).json(categories);
  } catch (error) {
    next(error);
  }
};

export const getAvailableProductFilters = (req: Request, res: Response, next: NextFunction): void => {
  try {
    // Mock filters - in production these would be generated from actual data
    const filters = {
      categories: ['Apparel', 'Music', 'Tickets'],
      brands: ['Brand A', 'Brand B', 'Brand C'],
      priceRanges: ['0-25', '25-50', '50-100', '100+']
    };

    res.status(200).json(filters);
  } catch (error) {
    next(error);
  }
};
