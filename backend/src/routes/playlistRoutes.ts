import { Router } from 'express';
import { body } from 'express-validator';
import {
  createPlaylist,
  getUserPlaylists,
  getPlaylistDetails,
  getPlaylistMetrics,
  updatePlaylist,
  deletePlaylist,
  getPlaylistSongs,
  addSongToPlaylist,
  removeSongFromPlaylist
} from '../controllers/playlistController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const createPlaylistValidation = [
  body('name').trim().notEmpty().isLength({ max: 100 }).withMessage('Name is required and must be less than 100 characters'),
  body('description').optional().isLength({ max: 500 }),
  body('isPublic').optional().isBoolean()
];

const updatePlaylistValidation = [
  body('name').optional().trim().isLength({ max: 100 }),
  body('description').optional().isLength({ max: 500 }),
  body('isPublic').optional().isBoolean()
];

const addSongValidation = [
  body('songId').isUUID().withMessage('Song ID must be a valid UUID'),
  body('position').optional().isInt({ min: 1 })
];

router.post('/', authenticate, validate(createPlaylistValidation), createPlaylist);
router.get('/user/:userId', getUserPlaylists);
router.get('/:id', getPlaylistDetails);
router.get('/:id/metrics', getPlaylistMetrics);
router.put('/:id', authenticate, validate(updatePlaylistValidation), updatePlaylist);
router.delete('/:id', authenticate, deletePlaylist);
router.get('/:id/songs', getPlaylistSongs);
router.post('/:id/songs', authenticate, validate(addSongValidation), addSongToPlaylist);
router.delete('/:id/songs/:songId', authenticate, removeSongFromPlaylist);

export default router;
