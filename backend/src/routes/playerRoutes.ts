import { Router } from 'express';
import { body } from 'express-validator';
import {
  getSongStream,
  getSongPreview,
  getSongDownloadLink,
  updateUserPlaybackProgress,
  getUserPlaybackQueue
} from '../controllers/playerController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const progressValidation = [
  body('progress').isNumeric().withMessage('Progress must be a number')
];

router.get('/stream/:songId', getSongStream);
router.get('/preview/:songId', getSongPreview);
router.get('/download/:songId', authenticate, getSongDownloadLink);
router.put('/progress/:userId/:songId', authenticate, validate(progressValidation), updateUserPlaybackProgress);
router.get('/queue/:userId', authenticate, getUserPlaybackQueue);

export default router;
