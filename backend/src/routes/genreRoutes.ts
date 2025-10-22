import { Router } from 'express';
import { body } from 'express-validator';
import {
  getAllGenres,
  createGenre,
  updateGenre,
  deleteGenre
} from '../controllers/genreController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const genreValidation = [
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('description').optional().isString()
];

router.get('/', getAllGenres);
router.post('/', authenticate, validate(genreValidation), createGenre);
router.put('/:id', authenticate, validate(genreValidation), updateGenre);
router.delete('/:id', authenticate, deleteGenre);

export default router;
