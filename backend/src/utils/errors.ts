export class AppError extends Error {
  public code: string;
  public statusCode: number;
  public details?: Record<string, any>;

  constructor(code: string, message: string, statusCode: number = 500, details?: Record<string, any>) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
    this.details = details;
    Error.captureStackTrace(this, this.constructor);
  }
}

export const createError = (
  code: string,
  message: string,
  statusCode: number = 500,
  details?: Record<string, any>
): AppError => {
  return new AppError(code, message, statusCode, details);
};
