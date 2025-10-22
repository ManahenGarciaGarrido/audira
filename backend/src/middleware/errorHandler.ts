import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { ApiError } from '../types';

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const error: ApiError = {
    code: err.code || 'INTERNAL_SERVER_ERROR',
    message: err.message || 'Ha ocurrido un error interno',
    details: err.details || {},
    timestamp: new Date().toISOString(),
    path: req.path,
    requestId: uuidv4()
  };

  const statusCode = err.statusCode || 500;

  console.error(`[${error.timestamp}] ${error.code} - ${error.message}`, {
    path: error.path,
    requestId: error.requestId,
    details: error.details
  });

  res.status(statusCode).json(error);
};

export const notFoundHandler = (req: Request, res: Response): void => {
  const error: ApiError = {
    code: 'NOT_FOUND',
    message: 'El recurso solicitado no fue encontrado',
    timestamp: new Date().toISOString(),
    path: req.path,
    requestId: uuidv4()
  };

  res.status(404).json(error);
};
