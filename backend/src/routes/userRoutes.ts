import { Router } from 'express';
import { body } from 'express-validator';
import {
  registerUser,
  loginUser,
  logoutUser,
  getUserProfile,
  updateUserProfile,
  deleteUserAccount,
  getUserFollowers,
  getUserFollowing,
  followUser,
  unfollowUser
} from '../controllers/userController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

// Validation rules
const registerValidation = [
  body('username').trim().isLength({ min: 3, max: 50 }).withMessage('Username must be between 3 and 50 characters'),
  body('email').isEmail().withMessage('Must be a valid email address'),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters long')
];

const loginValidation = [
  body('email').isEmail().withMessage('Must be a valid email address'),
  body('password').notEmpty().withMessage('Password is required')
];

const updateProfileValidation = [
  body('username').optional().trim().isLength({ min: 3, max: 50 }).withMessage('Username must be between 3 and 50 characters'),
  body('email').optional().isEmail().withMessage('Must be a valid email address'),
  body('bio').optional().isString().isLength({ max: 500 }).withMessage('Bio must be less than 500 characters')
];

// Routes
router.post('/register', validate(registerValidation), registerUser);
router.post('/login', validate(loginValidation), loginUser);
router.post('/logout', authenticate, logoutUser);
router.get('/:id', getUserProfile);
router.put('/:id', authenticate, validate(updateProfileValidation), updateUserProfile);
router.delete('/:id', authenticate, deleteUserAccount);
router.get('/:id/followers', getUserFollowers);
router.get('/:id/following', getUserFollowing);
router.post('/:id/follow', authenticate, followUser);
router.delete('/:id/unfollow', authenticate, unfollowUser);

export default router;
