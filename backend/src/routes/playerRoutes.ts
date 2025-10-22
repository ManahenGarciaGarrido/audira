import { Router } from 'express';
import { body } from 'express-validator';
import {
  getSongStream,
  getSongPreview,
  getSongDownloadLink,
  updateUserPlaybackProgress,
  getUserPlaybackQueue,
  setUserPlaybackQueue,
  addToUserPlaybackQueue,
  removeFromUserPlaybackQueue,
  clearUserPlaybackQueue
} from '../controllers/playerController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const progressValidation = [
  body('progress').isNumeric().withMessage('Progress must be a number')
];

const queueValidation = [
  body('queue').isArray().withMessage('Queue must be an array')
];

const addToQueueValidation = [
  body('songId').isUUID().withMessage('Song ID must be a valid UUID')
];

router.get('/stream/:songId', getSongStream);
router.get('/preview/:songId', getSongPreview);
router.get('/download/:songId', authenticate, getSongDownloadLink);
router.put('/progress/:userId/:songId', authenticate, validate(progressValidation), updateUserPlaybackProgress);
router.get('/queue/:userId', authenticate, getUserPlaybackQueue);
router.put('/queue/:userId', authenticate, validate(queueValidation), setUserPlaybackQueue);
router.post('/queue/:userId', authenticate, validate(addToQueueValidation), addToUserPlaybackQueue);
router.delete('/queue/:userId/songs/:songId', authenticate, removeFromUserPlaybackQueue);
router.delete('/queue/:userId', authenticate, clearUserPlaybackQueue);

export default router;
