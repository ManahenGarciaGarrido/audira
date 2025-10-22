import { Router } from 'express';
import {
  searchProducts,
  getUserRecommendations,
  getTrendingProducts
} from '../controllers/discoveryController';

const router = Router();

router.get('/search', searchProducts);
router.get('/recommendations/user/:userId', getUserRecommendations);
router.get('/trending', getTrendingProducts);

export default router;
