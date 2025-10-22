import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import userRoutes from './routes/userRoutes';
import metricsRoutes from './routes/metricsRoutes';
import ratingsRoutes from './routes/ratingsRoutes';
import commentsRoutes from './routes/commentsRoutes';
import communicationRoutes from './routes/communicationRoutes';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

// Load environment variables
dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet()); // Security headers
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true
}));
app.use(morgan('dev')); // HTTP request logger
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// API Routes - v1
const API_PREFIX = '/api/v1';

app.use(`${API_PREFIX}/users`, userRoutes);
app.use(`${API_PREFIX}/metrics`, metricsRoutes);
app.use(`${API_PREFIX}/ratings`, ratingsRoutes);
app.use(`${API_PREFIX}/comments`, commentsRoutes);
app.use(`${API_PREFIX}/contact`, communicationRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'Audira API',
    version: '1.0.0',
    description: 'Backend API for Audira platform - ÉPICA 1: Gestión de Usuarios y Comunidad',
    endpoints: {
      health: '/health',
      api: API_PREFIX,
      documentation: 'https://api.audira.io/docs'
    }
  });
});

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
const server = app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   🎵  AUDIRA API - Backend Server                        ║
║                                                           ║
║   Environment: ${process.env.NODE_ENV || 'development'}                                   ║
║   Port:        ${PORT}                                        ║
║   API Base:    ${API_PREFIX}                            ║
║                                                           ║
║   Status:      ✅ Server is running                       ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

export default app;
