#!/bin/bash
# ⚙️ Backend Microservices Generator
# Creates all backend services with complete implementation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Create API Gateway (Node.js + Express)
create_api_gateway() {
    log "Creating API Gateway service..."
    
    local GATEWAY_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/backend/api-gateway"
    
    # Main application file
    cat > "$GATEWAY_DIR/src/index.ts" << 'EOF'
import express from 'express'
import helmet from 'helmet'
import cors from 'cors'
import compression from 'compression'
import rateLimit from 'express-rate-limit'
import { createProxyMiddleware } from 'http-proxy-middleware'
import swaggerUi from 'swagger-ui-express'
import swaggerJsdoc from 'swagger-jsdoc'
import { logger } from './utils/logger'
import { config } from './config'
import { authMiddleware } from './middleware/auth'
import { errorHandler } from './middleware/error-handler'
import { requestLogger } from './middleware/request-logger'

const app = express()

// Security middleware
app.use(helmet())
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}))

// General middleware
app.use(compression())
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true, limit: '10mb' }))
app.use(requestLogger)

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later',
})
app.use('/api/', limiter)

// Swagger documentation
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: '{{values.name | title}} API Gateway',
      version: '1.0.0',
      description: 'API Gateway for {{values.name}} e-commerce platform',
    },
    servers: [
      {
        url: process.env.API_URL || 'http://localhost:8080',
        description: 'API Gateway',
      },
    ],
  },
  apis: ['./src/routes/*.ts', './src/middleware/*.ts'],
}

const specs = swaggerJsdoc(swaggerOptions)
app.use('/docs', swaggerUi.serve, swaggerUi.setup(specs))

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: process.env.npm_package_version || '1.0.0',
  })
})

// Service proxies
const services = {
  catalog: process.env.CATALOG_SERVICE_URL || 'http://catalog-service:3001',
  cart: process.env.CART_SERVICE_URL || 'http://cart-service:8081',
  orders: process.env.ORDER_SERVICE_URL || 'http://order-service:8082',
  payments: process.env.PAYMENT_SERVICE_URL || 'http://payment-service:8083',
  users: process.env.USER_SERVICE_URL || 'http://user-service:5000',
  notifications: process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service:3002',
}

// Catalog Service Proxy
app.use('/api/v1/products', createProxyMiddleware({
  target: services.catalog,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/products': '/api/v1/products',
  },
  onError: (err, req, res) => {
    logger.error('Catalog service proxy error:', err)
    res.status(503).json({ error: 'Catalog service unavailable' })
  },
}))

app.use('/api/v1/categories', createProxyMiddleware({
  target: services.catalog,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/categories': '/api/v1/categories',
  },
}))

// Cart Service Proxy
app.use('/api/v1/cart', authMiddleware, createProxyMiddleware({
  target: services.cart,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/cart': '/api/v1/cart',
  },
  onProxyReq: (proxyReq, req) => {
    // Forward user information
    if (req.user) {
      proxyReq.setHeader('X-User-ID', req.user.id)
      proxyReq.setHeader('X-User-Email', req.user.email)
    }
  },
}))

// Orders Service Proxy
app.use('/api/v1/orders', authMiddleware, createProxyMiddleware({
  target: services.orders,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/orders': '/api/v1/orders',
  },
  onProxyReq: (proxyReq, req) => {
    if (req.user) {
      proxyReq.setHeader('X-User-ID', req.user.id)
      proxyReq.setHeader('X-User-Email', req.user.email)
    }
  },
}))

// Payments Service Proxy
app.use('/api/v1/payments', authMiddleware, createProxyMiddleware({
  target: services.payments,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/payments': '/api/v1/payments',
  },
  onProxyReq: (proxyReq, req) => {
    if (req.user) {
      proxyReq.setHeader('X-User-ID', req.user.id)
    }
  },
}))

// Users Service Proxy
app.use('/api/v1/users', createProxyMiddleware({
  target: services.users,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/users': '/api/v1/users',
  },
}))

// Notifications Service Proxy
app.use('/api/v1/notifications', authMiddleware, createProxyMiddleware({
  target: services.notifications,
  changeOrigin: true,
  pathRewrite: {
    '^/api/v1/notifications': '/api/v1/notifications',
  },
  onProxyReq: (proxyReq, req) => {
    if (req.user) {
      proxyReq.setHeader('X-User-ID', req.user.id)
    }
  },
}))

// Error handling
app.use(errorHandler)

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Route not found',
    path: req.originalUrl,
  })
})

const PORT = process.env.PORT || 8080
app.listen(PORT, () => {
  logger.info(`🚀 API Gateway running on port ${PORT}`)
  logger.info(`📚 API Documentation: http://localhost:${PORT}/docs`)
  logger.info(`🏥 Health check: http://localhost:${PORT}/health`)
})

export default app
EOF

    # Authentication middleware
    cat > "$GATEWAY_DIR/src/middleware/auth.ts" << 'EOF'
import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
{% if values.backend.authentication == "azure-ad" %}
import { BearerStrategy } from 'passport-azure-ad'
{% endif %}
import { logger } from '../utils/logger'

interface AuthUser {
  id: string
  email: string
  name: string
  roles: string[]
}

declare global {
  namespace Express {
    interface Request {
      user?: AuthUser
    }
  }
}

export async function authMiddleware(req: Request, res: Response, next: NextFunction) {
  try {
    const authHeader = req.headers.authorization
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing or invalid authorization header' })
    }

    const token = authHeader.substring(7)
    
{% if values.backend.authentication == "azure-ad" %}
    // Azure AD token validation
    const decoded = jwt.decode(token, { complete: true }) as any
    if (!decoded) {
      return res.status(401).json({ error: 'Invalid token format' })
    }

    // Validate Azure AD token
    // In production, use proper Azure AD validation
    const user: AuthUser = {
      id: decoded.payload.oid || decoded.payload.sub,
      email: decoded.payload.email || decoded.payload.preferred_username,
      name: decoded.payload.name,
      roles: decoded.payload.roles || ['user'],
    }
{% else %}
    // JWT token validation
    const jwtSecret = process.env.JWT_SECRET
    if (!jwtSecret) {
      throw new Error('JWT_SECRET not configured')
    }

    const decoded = jwt.verify(token, jwtSecret) as any
    const user: AuthUser = {
      id: decoded.sub || decoded.userId,
      email: decoded.email,
      name: decoded.name,
      roles: decoded.roles || ['user'],
    }
{% endif %}

    req.user = user
    next()
  } catch (error) {
    logger.error('Authentication error:', error)
    res.status(401).json({ error: 'Invalid or expired token' })
  }
}

export function requireRole(roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' })
    }

    const hasRole = roles.some(role => req.user!.roles.includes(role))
    if (!hasRole) {
      return res.status(403).json({ error: 'Insufficient permissions' })
    }

    next()
  }
}
EOF

    # Configuration
    cat > "$GATEWAY_DIR/src/config/index.ts" << 'EOF'
export const config = {
  port: process.env.PORT || 8080,
  nodeEnv: process.env.NODE_ENV || 'development',
  
  auth: {
    jwtSecret: process.env.JWT_SECRET,
    tokenExpiry: process.env.TOKEN_EXPIRY || '24h',
{% if values.backend.authentication == "azure-ad" %}
    azureAd: {
      clientId: process.env.AZURE_CLIENT_ID,
      clientSecret: process.env.AZURE_CLIENT_SECRET,
      tenantId: process.env.AZURE_TENANT_ID,
    },
{% endif %}
  },

  services: {
    catalog: process.env.CATALOG_SERVICE_URL || 'http://catalog-service:3001',
    cart: process.env.CART_SERVICE_URL || 'http://cart-service:8081',
    orders: process.env.ORDER_SERVICE_URL || 'http://order-service:8082',
    payments: process.env.PAYMENT_SERVICE_URL || 'http://payment-service:8083',
    users: process.env.USER_SERVICE_URL || 'http://user-service:5000',
    notifications: process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service:3002',
  },

  cors: {
    origins: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  },

  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '900000'), // 15 minutes
    max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
  },
}
EOF

    success "API Gateway created successfully!"
}

# Create Catalog Service (Node.js + MongoDB)
create_catalog_service() {
    log "Creating Catalog Service..."
    
    local CATALOG_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/backend/catalog-service"
    
    # Main application
    cat > "$CATALOG_DIR/src/index.ts" << 'EOF'
import express from 'express'
import mongoose from 'mongoose'
import helmet from 'helmet'
import cors from 'cors'
import compression from 'compression'
{% if values.features.search %}
import { SearchClient, AzureKeyCredential } from '@azure/search-documents'
{% endif %}
{% if values.features.recommendations %}
import { OpenAIApi, Configuration } from 'openai'
{% endif %}
import { logger } from './utils/logger'
import { config } from './config'
import { errorHandler } from './middleware/error-handler'
import { requestLogger } from './middleware/request-logger'
import productRoutes from './routes/products'
import categoryRoutes from './routes/categories'

const app = express()

// Middleware
app.use(helmet())
app.use(cors())
app.use(compression())
app.use(express.json())
app.use(requestLogger)

// Database connection
mongoose.connect(config.database.mongoUri)
  .then(() => logger.info('✅ Connected to MongoDB'))
  .catch((error) => {
    logger.error('❌ MongoDB connection error:', error)
    process.exit(1)
  })

{% if values.features.search %}
// Azure Search client
const searchClient = new SearchClient<any>(
  config.azure.search.endpoint,
  'products-index',
  new AzureKeyCredential(config.azure.search.apiKey)
)
{% endif %}

{% if values.features.recommendations %}
// OpenAI client for recommendations
const openaiConfig = new Configuration({
  apiKey: config.azure.openai.apiKey,
  basePath: `${config.azure.openai.endpoint}/openai/deployments/${config.azure.openai.deploymentName}`,
  baseOptions: {
    headers: {
      'api-key': config.azure.openai.apiKey,
    },
  },
})
const openai = new OpenAIApi(openaiConfig)
{% endif %}

// Health check
app.get('/health', async (req, res) => {
  try {
    const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected'
    
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: dbStatus,
      uptime: process.uptime(),
      version: process.env.npm_package_version || '1.0.0',
    })
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
    })
  }
})

// Routes
app.use('/api/v1/products', productRoutes)
app.use('/api/v1/categories', categoryRoutes)

// Error handling
app.use(errorHandler)

const PORT = process.env.PORT || 3001
app.listen(PORT, () => {
  logger.info(`🛍️ Catalog Service running on port ${PORT}`)
})

export default app
EOF

    # Product model
    cat > "$CATALOG_DIR/src/models/Product.ts" << 'EOF'
import mongoose, { Document, Schema } from 'mongoose'

export interface IProduct extends Document {
  name: string
  description: string
  price: number
  images: string[]
  category: mongoose.Types.ObjectId
  categoryName: string
  stock: number
  sku: string
  rating: number
  reviewCount: number
  tags: string[]
  variants?: IProductVariant[]
  specifications?: Map<string, string>
  isActive: boolean
  isFeatured: boolean
  createdAt: Date
  updatedAt: Date
}

export interface IProductVariant {
  name: string
  price: number
  stock: number
  attributes: Map<string, string>
}

const productVariantSchema = new Schema<IProductVariant>({
  name: { type: String, required: true },
  price: { type: Number, required: true },
  stock: { type: Number, required: true, min: 0 },
  attributes: {
    type: Map,
    of: String,
  },
})

const productSchema = new Schema<IProduct>({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200,
  },
  description: {
    type: String,
    required: true,
    maxlength: 2000,
  },
  price: {
    type: Number,
    required: true,
    min: 0,
  },
  images: [{
    type: String,
    required: true,
  }],
  category: {
    type: Schema.Types.ObjectId,
    ref: 'Category',
    required: true,
  },
  categoryName: {
    type: String,
    required: true,
  },
  stock: {
    type: Number,
    required: true,
    min: 0,
  },
  sku: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
  },
  rating: {
    type: Number,
    min: 0,
    max: 5,
    default: 0,
  },
  reviewCount: {
    type: Number,
    min: 0,
    default: 0,
  },
  tags: [{
    type: String,
    lowercase: true,
  }],
  variants: [productVariantSchema],
  specifications: {
    type: Map,
    of: String,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  isFeatured: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
})

// Indexes
productSchema.index({ name: 'text', description: 'text', tags: 'text' })
productSchema.index({ category: 1, isActive: 1 })
productSchema.index({ price: 1 })
productSchema.index({ rating: -1 })
productSchema.index({ isFeatured: -1, createdAt: -1 })
productSchema.index({ sku: 1 }, { unique: true })

// Virtual for availability
productSchema.virtual('isAvailable').get(function() {
  return this.isActive && this.stock > 0
})

// Pre-save middleware
productSchema.pre('save', function(next) {
  if (!this.sku) {
    this.sku = this.name.toUpperCase().replace(/[^A-Z0-9]/g, '').substring(0, 10) + Date.now().toString().slice(-4)
  }
  next()
})

export const Product = mongoose.model<IProduct>('Product', productSchema)
EOF

    # Product routes
    cat > "$CATALOG_DIR/src/routes/products.ts" << 'EOF'
import express from 'express'
import { body, query, param, validationResult } from 'express-validator'
import { Product } from '../models/Product'
import { Category } from '../models/Category'
{% if values.features.search %}
import { searchProducts } from '../services/search'
{% endif %}
{% if values.features.recommendations %}
import { getRecommendations } from '../services/recommendations'
{% endif %}
import { logger } from '../utils/logger'

const router = express.Router()

// Get all products with filtering and pagination
router.get('/', [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  query('category').optional().isString(),
  query('minPrice').optional().isFloat({ min: 0 }),
  query('maxPrice').optional().isFloat({ min: 0 }),
  query('tags').optional().isString(),
  query('sort').optional().isIn(['price_asc', 'price_desc', 'rating_desc', 'created_desc', 'name_asc']),
  query('featured').optional().isBoolean(),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() })
    }

    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 20
    const skip = (page - 1) * limit

    // Build filter
    const filter: any = { isActive: true }

    if (req.query.category) {
      filter.categoryName = new RegExp(req.query.category as string, 'i')
    }

    if (req.query.minPrice || req.query.maxPrice) {
      filter.price = {}
      if (req.query.minPrice) filter.price.$gte = parseFloat(req.query.minPrice as string)
      if (req.query.maxPrice) filter.price.$lte = parseFloat(req.query.maxPrice as string)
    }

    if (req.query.tags) {
      const tags = (req.query.tags as string).split(',')
      filter.tags = { $in: tags }
    }

    if (req.query.featured === 'true') {
      filter.isFeatured = true
    }

    // Build sort
    let sort: any = { createdAt: -1 }
    switch (req.query.sort) {
      case 'price_asc':
        sort = { price: 1 }
        break
      case 'price_desc':
        sort = { price: -1 }
        break
      case 'rating_desc':
        sort = { rating: -1 }
        break
      case 'name_asc':
        sort = { name: 1 }
        break
    }

    const [products, total] = await Promise.all([
      Product.find(filter)
        .populate('category', 'name slug')
        .sort(sort)
        .skip(skip)
        .limit(limit)
        .lean(),
      Product.countDocuments(filter)
    ])

    res.json({
      products,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    })

  } catch (error) {
    logger.error('Error fetching products:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Search products
router.get('/search', [
  query('q').isString().isLength({ min: 1, max: 100 }),
  query('limit').optional().isInt({ min: 1, max: 50 }),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() })
    }

    const query = req.query.q as string
    const limit = parseInt(req.query.limit as string) || 20

{% if values.features.search %}
    // Use Azure Cognitive Search
    const results = await searchProducts(query, limit)
    res.json({ products: results, total: results.length })
{% else %}
    // Use MongoDB text search
    const products = await Product.find(
      { $text: { $search: query }, isActive: true },
      { score: { $meta: 'textScore' } }
    )
    .sort({ score: { $meta: 'textScore' } })
    .limit(limit)
    .populate('category', 'name slug')
    .lean()

    res.json({ products, total: products.length })
{% endif %}

  } catch (error) {
    logger.error('Error searching products:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get featured products
router.get('/featured', [
  query('limit').optional().isInt({ min: 1, max: 20 }),
], async (req, res) => {
  try {
    const limit = parseInt(req.query.limit as string) || 8

    const products = await Product.find({ 
      isFeatured: true, 
      isActive: true,
      stock: { $gt: 0 }
    })
    .populate('category', 'name slug')
    .sort({ rating: -1, createdAt: -1 })
    .limit(limit)
    .lean()

    res.json({ products })

  } catch (error) {
    logger.error('Error fetching featured products:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get single product
router.get('/:id', [
  param('id').isMongoId(),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() })
    }

    const product = await Product.findOne({ 
      _id: req.params.id, 
      isActive: true 
    })
    .populate('category', 'name slug description')
    .lean()

    if (!product) {
      return res.status(404).json({ error: 'Product not found' })
    }

    res.json(product)

  } catch (error) {
    logger.error('Error fetching product:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get related products
router.get('/:id/related', [
  param('id').isMongoId(),
  query('limit').optional().isInt({ min: 1, max: 20 }),
], async (req, res) => {
  try {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() })
    }

    const limit = parseInt(req.query.limit as string) || 6
    const product = await Product.findById(req.params.id).lean()

    if (!product) {
      return res.status(404).json({ error: 'Product not found' })
    }

{% if values.features.recommendations %}
    // Use AI recommendations
    const recommendations = await getRecommendations(req.params.id, limit)
    res.json({ products: recommendations })
{% else %}
    // Simple related products based on category and tags
    const relatedProducts = await Product.find({
      _id: { $ne: req.params.id },
      $or: [
        { category: product.category },
        { tags: { $in: product.tags } }
      ],
      isActive: true,
      stock: { $gt: 0 }
    })
    .populate('category', 'name slug')
    .sort({ rating: -1 })
    .limit(limit)
    .lean()

    res.json({ products: relatedProducts })
{% endif %}

  } catch (error) {
    logger.error('Error fetching related products:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

export default router
EOF

    success "Catalog Service created successfully!"
}

# Create Cart Service (Go)
create_cart_service() {
    log "Creating Cart Service (Go)..."
    
    local CART_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/backend/cart-service"
    
    # Main application
    cat > "$CART_DIR/main.go" << 'EOF'
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/go-redis/redis/v8"
	"github.com/joho/godotenv"
	"{{values.name}}-cart-service/internal/config"
	"{{values.name}}-cart-service/internal/handlers"
	"{{values.name}}-cart-service/internal/middleware"
	"{{values.name}}-cart-service/internal/repository"
	"{{values.name}}-cart-service/internal/service"
	"{{values.name}}-cart-service/pkg/logger"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found")
	}

	// Initialize configuration
	cfg := config.Load()

	// Initialize logger
	logger := logger.New(cfg.Environment)

	// Initialize Redis client
	rdb := redis.NewClient(&redis.Options{
		Addr:     cfg.Redis.Address,
		Password: cfg.Redis.Password,
		DB:       cfg.Redis.DB,
	})

	// Test Redis connection
	ctx := context.Background()
	if err := rdb.Ping(ctx).Err(); err != nil {
		logger.Fatal("Failed to connect to Redis", "error", err)
	}
	logger.Info("Connected to Redis successfully")

	// Initialize repository
	cartRepo := repository.NewCartRepository(rdb, logger)

	// Initialize service
	cartService := service.NewCartService(cartRepo, logger)

	// Initialize handlers
	cartHandler := handlers.NewCartHandler(cartService, logger)

	// Setup Gin router
	if cfg.Environment == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	router := gin.New()
	router.Use(gin.Logger())
	router.Use(gin.Recovery())
	router.Use(middleware.CORS())
	router.Use(middleware.RequestID())

	// Health check
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":    "healthy",
			"timestamp": time.Now().Format(time.RFC3339),
			"service":   "cart-service",
			"version":   "1.0.0",
		})
	})

	// API routes
	v1 := router.Group("/api/v1")
	{
		cart := v1.Group("/cart")
		cart.Use(middleware.AuthRequired())
		{
			cart.GET("", cartHandler.GetCart)
			cart.POST("/items", cartHandler.AddItem)
			cart.PUT("/items/:itemId", cartHandler.UpdateItem)
			cart.DELETE("/items/:itemId", cartHandler.RemoveItem)
			cart.DELETE("", cartHandler.ClearCart)
		}
	}

	// Start server
	srv := &http.Server{
		Addr:    ":" + cfg.Port,
		Handler: router,
	}

	go func() {
		logger.Info("Starting Cart Service", "port", cfg.Port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Failed to start server", "error", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit
	logger.Info("Shutting down server...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatal("Server forced to shutdown", "error", err)
	}

	logger.Info("Server exited")
}
EOF

    # Cart models
    cat > "$CART_DIR/internal/models/cart.go" << 'EOF'
package models

import (
	"time"
)

type Cart struct {
	UserID    string     `json:"userId" redis:"user_id"`
	Items     []CartItem `json:"items" redis:"items"`
	Total     float64    `json:"total" redis:"total"`
	UpdatedAt time.Time  `json:"updatedAt" redis:"updated_at"`
}

type CartItem struct {
	ProductID string  `json:"productId" redis:"product_id"`
	Name      string  `json:"name" redis:"name"`
	Price     float64 `json:"price" redis:"price"`
	Quantity  int     `json:"quantity" redis:"quantity"`
	Image     string  `json:"image" redis:"image"`
	Variant   string  `json:"variant,omitempty" redis:"variant"`
}

type AddItemRequest struct {
	ProductID string  `json:"productId" binding:"required"`
	Name      string  `json:"name" binding:"required"`
	Price     float64 `json:"price" binding:"required,min=0"`
	Quantity  int     `json:"quantity" binding:"required,min=1"`
	Image     string  `json:"image" binding:"required"`
	Variant   string  `json:"variant,omitempty"`
}

type UpdateItemRequest struct {
	Quantity int `json:"quantity" binding:"required,min=1"`
}

func (c *Cart) CalculateTotal() {
	total := 0.0
	for _, item := range c.Items {
		total += item.Price * float64(item.Quantity)
	}
	c.Total = total
	c.UpdatedAt = time.Now()
}

func (c *Cart) AddItem(item CartItem) {
	// Check if item already exists
	for i, existingItem := range c.Items {
		if existingItem.ProductID == item.ProductID && existingItem.Variant == item.Variant {
			c.Items[i].Quantity += item.Quantity
			c.CalculateTotal()
			return
		}
	}

	// Add new item
	c.Items = append(c.Items, item)
	c.CalculateTotal()
}

func (c *Cart) UpdateItem(productID string, quantity int) bool {
	for i, item := range c.Items {
		if item.ProductID == productID {
			c.Items[i].Quantity = quantity
			c.CalculateTotal()
			return true
		}
	}
	return false
}

func (c *Cart) RemoveItem(productID string) bool {
	for i, item := range c.Items {
		if item.ProductID == productID {
			c.Items = append(c.Items[:i], c.Items[i+1:]...)
			c.CalculateTotal()
			return true
		}
	}
	return false
}

func (c *Cart) Clear() {
	c.Items = []CartItem{}
	c.Total = 0
	c.UpdatedAt = time.Now()
}

func (c *Cart) IsEmpty() bool {
	return len(c.Items) == 0
}

func (c *Cart) GetItemCount() int {
	count := 0
	for _, item := range c.Items {
		count += item.Quantity
	}
	return count
}
EOF

    # Cart handlers
    cat > "$CART_DIR/internal/handlers/cart.go" << 'EOF'
package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"{{values.name}}-cart-service/internal/models"
	"{{values.name}}-cart-service/internal/service"
	"{{values.name}}-cart-service/pkg/logger"
)

type CartHandler struct {
	cartService *service.CartService
	logger      logger.Logger
}

func NewCartHandler(cartService *service.CartService, logger logger.Logger) *CartHandler {
	return &CartHandler{
		cartService: cartService,
		logger:      logger,
	}
}

func (h *CartHandler) GetCart(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	cart, err := h.cartService.GetCart(c.Request.Context(), userID)
	if err != nil {
		h.logger.Error("Failed to get cart", "error", err, "userID", userID)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to get cart"})
		return
	}

	c.JSON(http.StatusOK, cart)
}

func (h *CartHandler) AddItem(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	var req models.AddItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	item := models.CartItem{
		ProductID: req.ProductID,
		Name:      req.Name,
		Price:     req.Price,
		Quantity:  req.Quantity,
		Image:     req.Image,
		Variant:   req.Variant,
	}

	cart, err := h.cartService.AddItem(c.Request.Context(), userID, item)
	if err != nil {
		h.logger.Error("Failed to add item to cart", "error", err, "userID", userID)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add item to cart"})
		return
	}

	c.JSON(http.StatusOK, cart)
}

func (h *CartHandler) UpdateItem(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	itemID := c.Param("itemId")
	if itemID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Item ID is required"})
		return
	}

	var req models.UpdateItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	cart, err := h.cartService.UpdateItem(c.Request.Context(), userID, itemID, req.Quantity)
	if err != nil {
		h.logger.Error("Failed to update cart item", "error", err, "userID", userID, "itemID", itemID)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update cart item"})
		return
	}

	if cart == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found in cart"})
		return
	}

	c.JSON(http.StatusOK, cart)
}

func (h *CartHandler) RemoveItem(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	itemID := c.Param("itemId")
	if itemID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Item ID is required"})
		return
	}

	cart, err := h.cartService.RemoveItem(c.Request.Context(), userID, itemID)
	if err != nil {
		h.logger.Error("Failed to remove cart item", "error", err, "userID", userID, "itemID", itemID)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to remove cart item"})
		return
	}

	if cart == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found in cart"})
		return
	}

	c.JSON(http.StatusOK, cart)
}

func (h *CartHandler) ClearCart(c *gin.Context) {
	userID := c.GetString("userID")
	if userID == "" {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User ID not found"})
		return
	}

	cart, err := h.cartService.ClearCart(c.Request.Context(), userID)
	if err != nil {
		h.logger.Error("Failed to clear cart", "error", err, "userID", userID)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to clear cart"})
		return
	}

	c.JSON(http.StatusOK, cart)
}
EOF

    success "Cart Service created successfully!"
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    ⚙️ Backend Microservices Generator                        ║
║                                                              ║
║    Creating complete backend services implementation        ║
║    for the Three Horizons e-commerce demo                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    create_api_gateway
    create_catalog_service
    create_cart_service
    
    success "Backend microservices generated successfully!"
    
    echo -e "\n${GREEN}✅ Backend services are ready!${NC}"
    echo -e "\n📁 Services created:"
    echo -e "  • API Gateway (Node.js + Express)"
    echo -e "  • Catalog Service (Node.js + MongoDB)"
    echo -e "  • Cart Service (Go + Redis)"
    echo -e "\n🚀 Ready for remaining services (Order, Payment, User, Notifications)!"
    echo -e "\n📝 Next steps:"
    echo -e "  1. Create remaining microservices"
    echo -e "  2. Generate Kubernetes manifests"
    echo -e "  3. Setup database schemas"
    echo -e "  4. Configure monitoring"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi