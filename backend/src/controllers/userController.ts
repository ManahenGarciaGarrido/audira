import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';
import bcrypt from 'bcryptjs';
import { storage } from '../models/storage';
import { UserProfile, AuthResponse } from '../types';
import { generateToken, getExpiresIn } from '../utils/jwt';
import { createError } from '../utils/errors';
import { AuthRequest } from '../middleware/auth';

export const registerUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { username, email, password } = req.body;

    // Check if user already exists
    const existingUser = storage.getUserByEmail(email);
    if (existingUser) {
      throw createError('CONFLICT', 'El email ya está registrado', 409, {
        field: 'email'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const userId = uuidv4();
    const newUser = {
      id: userId,
      username,
      email,
      password: hashedPassword,
      followers: 0,
      following: 0,
      bio: ''
    };

    storage.createUser(newUser);

    const userProfile: UserProfile = {
      id: newUser.id,
      username: newUser.username,
      email: newUser.email,
      followers: newUser.followers,
      following: newUser.following,
      bio: newUser.bio
    };

    res.status(201).json(userProfile);
  } catch (error) {
    next(error);
  }
};

export const loginUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { email, password } = req.body;

    // Find user
    const user = storage.getUserByEmail(email);
    if (!user) {
      throw createError('UNAUTHORIZED', 'Credenciales inválidas', 401);
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      throw createError('UNAUTHORIZED', 'Credenciales inválidas', 401);
    }

    // Generate token
    const token = generateToken({ id: user.id, email: user.email });
    const authResponse: AuthResponse = {
      token,
      expiresIn: getExpiresIn()
    };

    res.status(200).json(authResponse);
  } catch (error) {
    next(error);
  }
};

export const logoutUser = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      storage.blacklistToken(token);
    }

    res.status(200).json({ message: 'Sesión cerrada exitosamente' });
  } catch (error) {
    next(error);
  }
};

export const getUserProfile = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;

    const user = storage.getUser(id);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id
      });
    }

    const followers = storage.getFollowers(id);
    const following = storage.getFollowing(id);

    const userProfile: UserProfile = {
      id: user.id,
      username: user.username,
      email: user.email,
      followers: followers.length,
      following: following.length,
      bio: user.bio || ''
    };

    res.status(200).json(userProfile);
  } catch (error) {
    next(error);
  }
};

export const updateUserProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const authReq = req as AuthRequest;

    // Check if user is updating their own profile
    if (authReq.user?.id !== id) {
      throw createError('FORBIDDEN', 'No tienes permiso para actualizar este perfil', 403);
    }

    const user = storage.getUser(id);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id
      });
    }

    const { username, email, bio } = req.body;

    // Check if email is being changed and already exists
    if (email && email !== user.email) {
      const existingUser = storage.getUserByEmail(email);
      if (existingUser) {
        throw createError('CONFLICT', 'El email ya está en uso', 409, {
          field: 'email'
        });
      }
    }

    const updates: any = {};
    if (username) updates.username = username;
    if (email) updates.email = email;
    if (bio !== undefined) updates.bio = bio;

    storage.updateUser(id, updates);

    const updatedUser = storage.getUser(id)!;
    const followers = storage.getFollowers(id);
    const following = storage.getFollowing(id);

    const userProfile: UserProfile = {
      id: updatedUser.id,
      username: updatedUser.username,
      email: updatedUser.email,
      followers: followers.length,
      following: following.length,
      bio: updatedUser.bio || ''
    };

    res.status(200).json(userProfile);
  } catch (error) {
    next(error);
  }
};

export const deleteUserAccount = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;
    const authReq = req as AuthRequest;

    // Check if user is deleting their own account
    if (authReq.user?.id !== id) {
      throw createError('FORBIDDEN', 'No tienes permiso para eliminar esta cuenta', 403);
    }

    const user = storage.getUser(id);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id
      });
    }

    storage.deleteUser(id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const getUserFollowers = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;

    const user = storage.getUser(id);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id
      });
    }

    const followerIds = storage.getFollowers(id);
    const followers: UserProfile[] = followerIds
      .map(followerId => storage.getUser(followerId))
      .filter(Boolean)
      .map(user => ({
        id: user!.id,
        username: user!.username,
        email: user!.email,
        followers: storage.getFollowers(user!.id).length,
        following: storage.getFollowing(user!.id).length,
        bio: user!.bio || ''
      }));

    res.status(200).json(followers);
  } catch (error) {
    next(error);
  }
};

export const getUserFollowing = (req: Request, res: Response, next: NextFunction): void => {
  try {
    const { id } = req.params;

    const user = storage.getUser(id);
    if (!user) {
      throw createError('NOT_FOUND', 'Usuario no encontrado', 404, {
        resource: 'user',
        id
      });
    }

    const followingIds = storage.getFollowing(id);
    const following: UserProfile[] = followingIds
      .map(followingId => storage.getUser(followingId))
      .filter(Boolean)
      .map(user => ({
        id: user!.id,
        username: user!.username,
        email: user!.email,
        followers: storage.getFollowers(user!.id).length,
        following: storage.getFollowing(user!.id).length,
        bio: user!.bio || ''
      }));

    res.status(200).json(following);
  } catch (error) {
    next(error);
  }
};
