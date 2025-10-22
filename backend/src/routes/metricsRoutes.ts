import { Router } from 'express';
import {
  getUserMetrics,
  getArtistMetrics,
  getSongMetrics,
  getGlobalMetrics
} from '../controllers/metricsController';

const router = Router();

// Routes
router.get('/user/:id', getUserMetrics);
router.get('/artist/:id', getArtistMetrics);
router.get('/song/:id', getSongMetrics);
router.get('/global', getGlobalMetrics);

export default router;
