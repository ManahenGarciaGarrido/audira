import { Router } from 'express';
import {
  searchContent,
  getUserRecommendations,
  getTrendingContent
} from '../controllers/discoveryController';

const router = Router();

router.get('/search', searchContent);
router.get('/recommendations/user/:userId', getUserRecommendations);
router.get('/trending', getTrendingContent);

export default router;
