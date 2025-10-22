import { Router } from 'express';
import { body } from 'express-validator';
import {
  getAllSongs,
  getSongById,
  createSong,
  updateSong,
  deleteSong
} from '../controllers/songController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const createSongValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('artistId').isUUID().withMessage('Artist ID must be a valid UUID'),
  body('albumId').optional().isUUID(),
  body('genre').optional().isString(),
  body('duration').optional().isNumeric()
];

const updateSongValidation = [
  body('title').optional().trim().notEmpty(),
  body('genre').optional().isString(),
  body('duration').optional().isNumeric()
];

router.get('/', getAllSongs);
router.get('/:id', getSongById);
router.post('/', authenticate, validate(createSongValidation), createSong);
router.put('/:id', authenticate, validate(updateSongValidation), updateSong);
router.delete('/:id', authenticate, deleteSong);

export default router;
