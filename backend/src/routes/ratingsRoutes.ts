import { Router } from 'express';
import { body } from 'express-validator';
import {
  createRating,
  updateRating,
  deleteRating,
  getRatingsByProduct
} from '../controllers/ratingsController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

// Validation rules
const createRatingValidation = [
  body('productId').notEmpty().withMessage('Product ID is required'),
  body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('comment').optional().isString().isLength({ max: 1000 }).withMessage('Comment must be less than 1000 characters')
];

const updateRatingValidation = [
  body('rating').optional().isInt({ min: 1, max: 5 }).withMessage('Rating must be between 1 and 5'),
  body('comment').optional().isString().isLength({ max: 1000 }).withMessage('Comment must be less than 1000 characters')
];

// Routes
router.post('/', authenticate, validate(createRatingValidation), createRating);
router.put('/:id', authenticate, validate(updateRatingValidation), updateRating);
router.delete('/:id', authenticate, deleteRating);
router.get('/product/:productId', getRatingsByProduct);

export default router;
