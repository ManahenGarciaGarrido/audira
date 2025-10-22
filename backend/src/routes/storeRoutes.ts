import { Router } from 'express';
import {
  getAllStoreProducts,
  getStoreProductById,
  getAllProductCategories,
  getAvailableProductFilters
} from '../controllers/storeController';

const router = Router();

router.get('/products', getAllStoreProducts);
router.get('/products/:id', getStoreProductById);
router.get('/categories', getAllProductCategories);
router.get('/filters', getAvailableProductFilters);

export default router;
