import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import { extendedStorage } from '../models/storageExtended';
import { Collaboration } from '../types';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const createCollaboration = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authReq = req as AuthRequest;
    const { title, description, type, participants } = req.body;

    if (!authReq.user) {
      throw createError('UNAUTHORIZED', 'Autenticación requerida', 401);
    }

    const collaboration: Collaboration = {
      id: uuidv4(),
      title,
      description,
      status: 'active',
      type,
      initiatorId: authReq.user.id,
      participants: participants.map((p: any) => ({
        id: uuidv4(),
        artistId: p.artistId,
        role: p.role,
        status: 'invited'
      })),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    extendedStorage.createCollaboration(collaboration);
    res.status(201).json(collaboration);
  } catch (error) {
    next(error);
  }
};

export const getCollaborationDetails = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const collab = extendedStorage.getCollaboration(id);
    if (!collab) {
      throw createError('NOT_FOUND', 'Colaboración no encontrada', 404, { resource: 'collaboration', id });
    }
    res.status(200).json(collab);
  } catch (error) {
    next(error);
  }
};

export const updateCollaboration = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const { title, description, status, participants } = req.body;

    const updates: any = { updatedAt: new Date().toISOString() };
    if (title) updates.title = title;
    if (description !== undefined) updates.description = description;
    if (status) updates.status = status;
    if (participants) {
      updates.participants = participants.map((p: any) => ({
        id: uuidv4(),
        artistId: p.artistId,
        role: p.role,
        status: 'invited'
      }));
    }

    const success = extendedStorage.updateCollaboration(id, updates);
    if (!success) {
      throw createError('NOT_FOUND', 'Colaboración no encontrada', 404, { resource: 'collaboration', id });
    }
    res.status(200).json(extendedStorage.getCollaboration(id));
  } catch (error) {
    next(error);
  }
};

export const cancelCollaboration = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const success = extendedStorage.deleteCollaboration(id);
    if (!success) {
      throw createError('NOT_FOUND', 'Colaboración no encontrada', 404, { resource: 'collaboration', id });
    }
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const inviteToCollaboration = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const { artistId, role } = req.body;

    const collab = extendedStorage.getCollaboration(id);
    if (!collab) {
      throw createError('NOT_FOUND', 'Colaboración no encontrada', 404, { resource: 'collaboration', id });
    }

    // Check if artist is already invited
    const exists = collab.participants.some(p => p.artistId === artistId);
    if (exists) {
      throw createError('CONFLICT', 'El artista ya está invitado a esta colaboración', 409);
    }

    collab.participants.push({
      id: uuidv4(),
      artistId,
      role,
      status: 'invited'
    });

    extendedStorage.updateCollaboration(id, { participants: collab.participants });
    res.status(201).json({ message: 'Invitación enviada exitosamente' });
  } catch (error) {
    next(error);
  }
};
