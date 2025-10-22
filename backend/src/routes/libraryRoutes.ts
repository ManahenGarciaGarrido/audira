import { Router } from 'express';
import { body } from 'express-validator';
import {
  getUserLibrary,
  addItemToLibrary,
  removeFromLibrary
} from '../controllers/libraryController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const addItemValidation = [
  body('itemId').isUUID().withMessage('Item ID must be a valid UUID'),
  body('type').isIn(['song', 'album', 'playlist']).withMessage('Invalid item type'),
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('artistName').optional().isString(),
  body('albumName').optional().isString()
];

router.get('/:userId', authenticate, getUserLibrary);
router.post('/:userId', authenticate, validate(addItemValidation), addItemToLibrary);
router.delete('/:userId/:itemId', authenticate, removeFromLibrary);

export default router;
