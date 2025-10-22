import { Router } from 'express';
import { body } from 'express-validator';
import {
  createComment,
  updateComment,
  deleteComment,
  getCommentsByProduct
} from '../controllers/commentsController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

// Validation rules
const createCommentValidation = [
  body('productId').notEmpty().withMessage('Product ID is required'),
  body('content').notEmpty().isString().isLength({ min: 1, max: 2000 }).withMessage('Content must be between 1 and 2000 characters')
];

const updateCommentValidation = [
  body('content').notEmpty().isString().isLength({ min: 1, max: 2000 }).withMessage('Content must be between 1 and 2000 characters')
];

// Routes
router.post('/', authenticate, validate(createCommentValidation), createComment);
router.put('/:id', authenticate, validate(updateCommentValidation), updateComment);
router.delete('/:id', authenticate, deleteComment);
router.get('/product/:productId', getCommentsByProduct);

export default router;
