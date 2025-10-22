import { Router } from 'express';
import { body } from 'express-validator';
import {
  sendContactMessage,
  getFAQs,
  getUserNotifications
} from '../controllers/communicationController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

// Validation rules
const contactMessageValidation = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('email').isEmail().withMessage('Must be a valid email address'),
  body('subject').trim().notEmpty().isLength({ max: 200 }).withMessage('Subject is required and must be less than 200 characters'),
  body('message').trim().notEmpty().isLength({ max: 5000 }).withMessage('Message is required and must be less than 5000 characters')
];

// Routes
router.post('/messages', validate(contactMessageValidation), sendContactMessage);
router.get('/faqs', getFAQs);
router.get('/notifications/:userId', authenticate, getUserNotifications);

export default router;
