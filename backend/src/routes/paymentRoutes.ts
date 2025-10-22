import { Router } from 'express';
import { body } from 'express-validator';
import {
  initiatePayment,
  getPaymentStatus,
  getUserPaymentHistory,
  paymentGatewayWebhook
} from '../controllers/paymentController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const paymentValidation = [
  body('amount').isNumeric().isFloat({ min: 0.01 }).withMessage('Amount must be greater than 0'),
  body('currency').matches(/^[A-Z]{3}$/).withMessage('Currency must be a 3-letter ISO code'),
  body('paymentMethod').isIn(['stripe', 'paypal', 'credit_card']).withMessage('Invalid payment method'),
  body('orderId').optional().isUUID()
];

router.post('/', authenticate, validate(paymentValidation), initiatePayment);
router.get('/:id', authenticate, getPaymentStatus);
router.get('/user/:userId', authenticate, getUserPaymentHistory);
router.post('/webhook', paymentGatewayWebhook);

export default router;
