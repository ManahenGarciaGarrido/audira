import { Router } from 'express';
import { body } from 'express-validator';
import {
  createCollaboration,
  getCollaborationDetails,
  updateCollaboration,
  cancelCollaboration,
  inviteToCollaboration
} from '../controllers/collaborationController';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const createCollaborationValidation = [
  body('title').trim().notEmpty().isLength({ max: 100 }).withMessage('Title is required and must be less than 100 characters'),
  body('description').optional().isLength({ max: 1000 }),
  body('type').isIn(['song', 'album', 'remix', 'feature']).withMessage('Invalid collaboration type'),
  body('participants').isArray({ min: 1 }).withMessage('At least one participant is required'),
  body('participants.*.artistId').isUUID(),
  body('participants.*.role').isIn(['lead_artist', 'featured_artist', 'producer', 'songwriter'])
];

const updateCollaborationValidation = [
  body('title').optional().trim().isLength({ max: 100 }),
  body('description').optional().isLength({ max: 1000 }),
  body('status').optional().isIn(['draft', 'active', 'completed', 'cancelled']),
  body('participants').optional().isArray(),
  body('participants.*.artistId').optional().isUUID(),
  body('participants.*.role').optional().isIn(['lead_artist', 'featured_artist', 'producer', 'songwriter'])
];

const inviteValidation = [
  body('artistId').isUUID().withMessage('Artist ID must be a valid UUID'),
  body('role').isIn(['lead_artist', 'featured_artist', 'producer', 'songwriter']),
  body('message').optional().isLength({ max: 500 })
];

router.post('/', authenticate, validate(createCollaborationValidation), createCollaboration);
router.get('/:id', authenticate, getCollaborationDetails);
router.put('/:id', authenticate, validate(updateCollaborationValidation), updateCollaboration);
router.delete('/:id', authenticate, cancelCollaboration);
router.post('/:id/invite', authenticate, validate(inviteValidation), inviteToCollaboration);

export default router;
