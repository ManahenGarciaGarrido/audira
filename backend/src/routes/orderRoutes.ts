import { Router } from 'express';
import { body } from 'express-validator';
import {
  createOrder,
  getOrderById,
  getOrdersByUserId,
  updateOrder,
  deleteOrder
} from '../controllers/orderController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const createOrderValidation = [
  body('items').isArray({ min: 1 }).withMessage('Order must contain at least one item'),
  body('items.*.itemId').notEmpty(),
  body('items.*.name').notEmpty(),
  body('items.*.quantity').isInt({ min: 1 }),
  body('items.*.price').isNumeric(),
  body('total').isNumeric().withMessage('Total must be a number'),
  body('status').optional().isIn(['pending', 'paid', 'shipped', 'delivered', 'cancelled'])
];

const updateOrderValidation = [
  body('status').optional().isIn(['pending', 'paid', 'shipped', 'delivered', 'cancelled']),
  body('items').optional().isArray(),
  body('total').optional().isNumeric()
];

router.post('/', authenticate, validate(createOrderValidation), createOrder);
router.get('/:id', authenticate, getOrderById);
router.get('/user/:userId', authenticate, getOrdersByUserId);
router.put('/:id', authenticate, validate(updateOrderValidation), updateOrder);
router.delete('/:id', authenticate, deleteOrder);

export default router;
