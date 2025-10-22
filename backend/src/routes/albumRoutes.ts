import { Router } from 'express';
import { body } from 'express-validator';
import {
  getAllAlbums,
  getAlbumById,
  getAlbumsByArtist,
  createAlbum,
  updateAlbum,
  deleteAlbum,
  getAlbumSongs
} from '../controllers/albumController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const createAlbumValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('artistId').isUUID().withMessage('Artist ID must be a valid UUID'),
  body('genre').optional().isString()
];

const updateAlbumValidation = [
  body('title').optional().trim().notEmpty(),
  body('genre').optional().isString()
];

router.get('/', getAllAlbums);
router.get('/:id', getAlbumById);
router.get('/:id/songs', getAlbumSongs);
router.get('/artist/:artistId', getAlbumsByArtist);
router.post('/', authenticate, validate(createAlbumValidation), createAlbum);
router.put('/:id', authenticate, validate(updateAlbumValidation), updateAlbum);
router.delete('/:id', authenticate, deleteAlbum);

export default router;
