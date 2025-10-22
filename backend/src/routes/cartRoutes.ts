import { Router } from 'express';
import { body } from 'express-validator';
import {
  getCartByUserId,
  getCartTotalByUserId,
  addItemToCart,
  updateCartItemQuantity,
  removeItemFromCart,
  deleteCartByUserId
} from '../controllers/cartController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const updateQuantityValidation = [
  body('quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1')
];

router.get('/:userId', authenticate, getCartByUserId);
router.get('/:userId/total', authenticate, getCartTotalByUserId);
router.post('/:userId/:itemId', authenticate, addItemToCart);
router.put('/:userId/:itemId', authenticate, validate(updateQuantityValidation), updateCartItemQuantity);
router.delete('/:userId/:itemId', authenticate, removeItemFromCart);
router.delete('/:userId', authenticate, deleteCartByUserId);

export default router;
