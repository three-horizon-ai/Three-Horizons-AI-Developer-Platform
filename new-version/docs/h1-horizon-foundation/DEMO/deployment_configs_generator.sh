#!/bin/bash
# 🚀 Deployment & Configuration Generator
# Creates Kubernetes manifests, Docker configs, and deployment scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Create Kubernetes manifests
create_kubernetes_manifests() {
    log "Creating Kubernetes manifests..."
    
    local K8S_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/k8s"
    
    # Base namespace
    cat > "$K8S_DIR/base/namespace.yaml" << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: {{values.name}}-{{values.azure.environment}}
  labels:
    app: {{values.name}}
    environment: {{values.azure.environment}}
    managed-by: three-horizons
    backstage.io/managed-by-location: url:{{steps.publish.output.remoteUrl}}
  annotations:
    backstage.io/managed-by-location: url:{{steps.publish.output.remoteUrl}}
    azure.workload.identity/service-account-token-expiration: "3600"
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{values.name}}-sa
  namespace: {{values.name}}-{{values.azure.environment}}
  annotations:
    azure.workload.identity/client-id: "{{values.azure.clientId}}"
    azure.workload.identity/tenant-id: "{{values.azure.tenantId}}"
  labels:
    azure.workload.identity/use: "true"
EOF

    # ConfigMap
    cat > "$K8S_DIR/base/configmap.yaml" << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{values.name}}-config
  namespace: {{values.name}}-{{values.azure.environment}}
data:
  # Application Configuration
  APP_NAME: "{{values.name}}"
  APP_ENV: "{{values.azure.environment}}"
  NODE_ENV: "{{values.azure.environment}}"
  
  # URLs and Endpoints
  API_URL: "https://api-{{values.name}}.demo.threehorizons.io"
  FRONTEND_URL: "https://{{values.name}}.demo.threehorizons.io"
  
  # Service URLs (internal)
  CATALOG_SERVICE_URL: "http://catalog-service:3001"
  CART_SERVICE_URL: "http://cart-service:8081"
  ORDER_SERVICE_URL: "http://order-service:8082"
  PAYMENT_SERVICE_URL: "http://payment-service:8083"
  USER_SERVICE_URL: "http://user-service:5000"
  NOTIFICATION_SERVICE_URL: "http://notification-service:3002"
  
  # Azure Configuration
  AZURE_REGION: "{{values.azure.region}}"
  AZURE_RESOURCE_GROUP: "rg-{{values.name}}-{{values.azure.environment}}"
  
  # Feature Flags
  FEATURE_PAYMENTS: "{{values.features.payments}}"
  FEATURE_SEARCH: "{{values.features.search}}"
  FEATURE_RECOMMENDATIONS: "{{values.features.recommendations}}"
  FEATURE_ANALYTICS: "{{values.features.analytics}}"
  FEATURE_INVENTORY: "{{values.features.inventory}}"
  
  # Logging
  LOG_LEVEL: "{{values.azure.environment == 'production' && 'info' || 'debug'}}"
  
  # CORS
  ALLOWED_ORIGINS: "https://{{values.name}}.demo.threehorizons.io,https://admin-{{values.name}}.demo.threehorizons.io"
  
  # Redis Configuration
  REDIS_HOST: "redis-{{values.name}}-{{values.azure.environment}}.redis.cache.windows.net"
  REDIS_PORT: "6380"
  REDIS_SSL: "true"
  
  # MongoDB Configuration  
  MONGO_HOST: "{{values.name}}-cosmos.mongo.cosmos.azure.com"
  MONGO_PORT: "10255"
  MONGO_DATABASE: "{{values.name}}"
  
  # PostgreSQL Configuration
  POSTGRES_HOST: "psql-{{values.name}}-{{values.azure.environment}}.postgres.database.azure.com"
  POSTGRES_PORT: "5432"
  POSTGRES_DATABASE: "{{values.name}}"
  POSTGRES_USER: "{{values.name}}admin"
  POSTGRES_SSL_MODE: "require"
EOF

    # Secret (template - actual secrets managed by Azure Key Vault)
    cat > "$K8S_DIR/base/secret.yaml" << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: {{values.name}}-secrets
  namespace: {{values.name}}-{{values.azure.environment}}
type: Opaque
stringData:
  # These will be populated by Azure Key Vault CSI driver
  DATABASE_URL: ""
  REDIS_URL: ""
  MONGO_URL: ""
  JWT_SECRET: ""
  API_KEY: ""
  WEBHOOK_SECRET: ""
  SESSION_SECRET: ""
{% if values.features.payments %}
  STRIPE_SECRET_KEY: ""
  STRIPE_WEBHOOK_SECRET: ""
{% endif %}
{% if values.features.search %}
  AZURE_SEARCH_API_KEY: ""
{% endif %}
{% if values.features.recommendations %}
  AZURE_OPENAI_API_KEY: ""
{% endif %}
---
# Azure Key Vault CSI SecretProviderClass
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: {{values.name}}-kv-secrets
  namespace: {{values.name}}-{{values.azure.environment}}
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "false"
    clientID: "{{values.azure.clientId}}"
    keyvaultName: "kv-{{values.name}}-{{values.azure.environment}}"
    tenantId: "{{values.azure.tenantId}}"
    objects: |
      array:
        - |
          objectName: postgres-connection-string
          objectType: secret
          objectVersion: ""
        - |
          objectName: redis-connection-string
          objectType: secret
          objectVersion: ""
        - |
          objectName: jwt-secret
          objectType: secret
          objectVersion: ""
        - |
          objectName: api-key
          objectType: secret
          objectVersion: ""
{% if values.features.payments %}
        - |
          objectName: stripe-secret-key
          objectType: secret
          objectVersion: ""
{% endif %}
{% if values.features.search %}
        - |
          objectName: azure-search-api-key
          objectType: secret
          objectVersion: ""
{% endif %}
  secretObjects:
  - secretName: {{values.name}}-secrets
    type: Opaque
    data:
    - objectName: postgres-connection-string
      key: DATABASE_URL
    - objectName: redis-connection-string
      key: REDIS_URL
    - objectName: jwt-secret
      key: JWT_SECRET
    - objectName: api-key
      key: API_KEY
{% if values.features.payments %}
    - objectName: stripe-secret-key
      key: STRIPE_SECRET_KEY
{% endif %}
{% if values.features.search %}
    - objectName: azure-search-api-key
      key: AZURE_SEARCH_API_KEY
{% endif %}
EOF

    # Frontend Portal Deployment
    cat > "$K8S_DIR/base/frontend-portal.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-portal
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: frontend-portal
    component: frontend
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend-portal
  template:
    metadata:
      labels:
        app: frontend-portal
        component: frontend
        version: v1
    spec:
      serviceAccountName: {{values.name}}-sa
      containers:
      - name: frontend-portal
        image: frontend-portal:latest
        ports:
        - containerPort: 3000
          name: http
        env:
        - name: PORT
          value: "3000"
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: {{values.name}}-config
              key: NODE_ENV
        - name: NEXT_PUBLIC_API_URL
          valueFrom:
            configMapKeyRef:
              name: {{values.name}}-config
              key: API_URL
{% if values.features.payments %}
        - name: NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
          value: "pk_test_..." # This should come from ConfigMap in real deployment
{% endif %}
{% if values.features.analytics %}
        - name: NEXT_PUBLIC_MIXPANEL_TOKEN
          value: "your-mixpanel-token"
{% endif %}
        envFrom:
        - configMapRef:
            name: {{values.name}}-config
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
      - name: secrets-store
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: {{values.name}}-kv-secrets
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-portal
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: frontend-portal
spec:
  selector:
    app: frontend-portal
  ports:
  - port: 80
    targetPort: 3000
    name: http
  type: ClusterIP
EOF

    # API Gateway Deployment
    cat > "$K8S_DIR/base/api-gateway.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: api-gateway
    component: gateway
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
        component: gateway
        version: v1
    spec:
      serviceAccountName: {{values.name}}-sa
      containers:
      - name: api-gateway
        image: api-gateway:latest
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: PORT
          value: "8080"
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: {{values.name}}-secrets
              key: JWT_SECRET
        envFrom:
        - configMapRef:
            name: {{values.name}}-config
        - secretRef:
            name: {{values.name}}-secrets
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
      - name: secrets-store
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: {{values.name}}-kv-secrets
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: api-gateway
spec:
  selector:
    app: api-gateway
  ports:
  - port: 80
    targetPort: 8080
    name: http
  type: ClusterIP
EOF

    # Catalog Service Deployment
    cat > "$K8S_DIR/base/catalog-service.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog-service
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: catalog-service
    component: backend
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: catalog-service
  template:
    metadata:
      labels:
        app: catalog-service
        component: backend
        version: v1
    spec:
      serviceAccountName: {{values.name}}-sa
      containers:
      - name: catalog-service
        image: catalog-service:latest
        ports:
        - containerPort: 3001
          name: http
        env:
        - name: PORT
          value: "3001"
        - name: MONGO_URI
          valueFrom:
            secretKeyRef:
              name: {{values.name}}-secrets
              key: MONGO_URL
{% if values.features.search %}
        - name: AZURE_SEARCH_ENDPOINT
          value: "https://{{values.name}}-search.search.windows.net"
        - name: AZURE_SEARCH_API_KEY
          valueFrom:
            secretKeyRef:
              name: {{values.name}}-secrets
              key: AZURE_SEARCH_API_KEY
{% endif %}
{% if values.features.recommendations %}
        - name: AZURE_OPENAI_ENDPOINT
          value: "https://{{values.name}}-openai.openai.azure.com"
        - name: AZURE_OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: {{values.name}}-secrets
              key: AZURE_OPENAI_API_KEY
{% endif %}
        envFrom:
        - configMapRef:
            name: {{values.name}}-config
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3001
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
      - name: secrets-store
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: {{values.name}}-kv-secrets
---
apiVersion: v1
kind: Service
metadata:
  name: catalog-service
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: catalog-service
spec:
  selector:
    app: catalog-service
  ports:
  - port: 80
    targetPort: 3001
    name: http
  type: ClusterIP
EOF

    # Cart Service Deployment
    cat > "$K8S_DIR/base/cart-service.yaml" << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cart-service
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: cart-service
    component: backend
    version: v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cart-service
  template:
    metadata:
      labels:
        app: cart-service
        component: backend
        version: v1
    spec:
      serviceAccountName: {{values.name}}-sa
      containers:
      - name: cart-service
        image: cart-service:latest
        ports:
        - containerPort: 8081
          name: http
        env:
        - name: PORT
          value: "8081"
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: {{values.name}}-secrets
              key: REDIS_URL
        envFrom:
        - configMapRef:
            name: {{values.name}}-config
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "250m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8081
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: secrets-store
          mountPath: "/mnt/secrets-store"
          readOnly: true
      volumes:
      - name: secrets-store
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: {{values.name}}-kv-secrets
---
apiVersion: v1
kind: Service
metadata:
  name: cart-service
  namespace: {{values.name}}-{{values.azure.environment}}
  labels:
    app: cart-service
spec:
  selector:
    app: cart-service
  ports:
  - port: 80
    targetPort: 8081
    name: http
  type: ClusterIP
EOF

    # Ingress Configuration
    cat > "$K8S_DIR/base/ingress.yaml" << 'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{values.name}}-ingress
  namespace: {{values.name}}-{{values.azure.environment}}
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
spec:
  tls:
  - hosts:
    - {{values.name}}.demo.threehorizons.io
    - api-{{values.name}}.demo.threehorizons.io
    - admin-{{values.name}}.demo.threehorizons.io
    secretName: {{values.name}}-tls
  rules:
  - host: {{values.name}}.demo.threehorizons.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-portal
            port:
              number: 80
  - host: api-{{values.name}}.demo.threehorizons.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway
            port:
              number: 80
  - host: admin-{{values.name}}.demo.threehorizons.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-admin
            port:
              number: 80
EOF

    success "Kubernetes manifests created successfully!"
}

# Create Docker Compose for local development
create_docker_compose() {
    log "Creating Docker Compose configuration..."
    
    local COMPOSE_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton"
    
    # Main docker-compose.yml
    cat > "$COMPOSE_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  # Frontend Portal
  frontend-portal:
    build:
      context: ./frontend/portal
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - NEXT_PUBLIC_API_URL=http://localhost:8080
{% if values.features.payments %}
      - NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
{% endif %}
{% if values.features.analytics %}
      - NEXT_PUBLIC_MIXPANEL_TOKEN=your_mixpanel_token
{% endif %}
    volumes:
      - ./frontend/portal:/app
      - /app/node_modules
      - /app/.next
    depends_on:
      - api-gateway
    networks:
      - {{values.name}}-network

  # Frontend Admin
  frontend-admin:
    build:
      context: ./frontend/admin
      dockerfile: Dockerfile
    ports:
      - "3001:3000"
    environment:
      - NODE_ENV=development
      - NEXT_PUBLIC_API_URL=http://localhost:8080
    volumes:
      - ./frontend/admin:/app
      - /app/node_modules
      - /app/.next
    depends_on:
      - api-gateway
    networks:
      - {{values.name}}-network

  # API Gateway
  api-gateway:
    build:
      context: ./backend/api-gateway
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - PORT=8080
      - NODE_ENV=development
      - JWT_SECRET=your-dev-jwt-secret
      - CATALOG_SERVICE_URL=http://catalog-service:3001
      - CART_SERVICE_URL=http://cart-service:8081
      - ORDER_SERVICE_URL=http://order-service:8082
      - PAYMENT_SERVICE_URL=http://payment-service:8083
      - USER_SERVICE_URL=http://user-service:5000
      - NOTIFICATION_SERVICE_URL=http://notification-service:3002
    volumes:
      - ./backend/api-gateway:/app
      - /app/node_modules
    depends_on:
      - catalog-service
      - cart-service
    networks:
      - {{values.name}}-network

  # Catalog Service
  catalog-service:
    build:
      context: ./backend/catalog-service
      dockerfile: Dockerfile
    ports:
      - "3001:3001"
    environment:
      - PORT=3001
      - NODE_ENV=development
      - MONGO_URI=mongodb://mongo:27017/{{values.name}}_catalog
{% if values.features.search %}
      - AZURE_SEARCH_ENDPOINT=https://your-search.search.windows.net
      - AZURE_SEARCH_API_KEY=your-search-api-key
{% endif %}
{% if values.features.recommendations %}
      - AZURE_OPENAI_ENDPOINT=https://your-openai.openai.azure.com
      - AZURE_OPENAI_API_KEY=your-openai-api-key
{% endif %}
    volumes:
      - ./backend/catalog-service:/app
      - /app/node_modules
    depends_on:
      - mongo
    networks:
      - {{values.name}}-network

  # Cart Service
  cart-service:
    build:
      context: ./backend/cart-service
      dockerfile: Dockerfile
    ports:
      - "8081:8081"
    environment:
      - PORT=8081
      - REDIS_ADDRESS=redis:6379
      - REDIS_PASSWORD=
      - REDIS_DB=0
    volumes:
      - ./backend/cart-service:/app
    depends_on:
      - redis
    networks:
      - {{values.name}}-network

  # Order Service
  order-service:
    build:
      context: ./backend/order-service
      dockerfile: Dockerfile
    ports:
      - "8082:8082"
    environment:
      - SERVER_PORT=8082
      - SPRING_PROFILES_ACTIVE=development
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/{{values.name}}_orders
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=postgres
      - SPRING_REDIS_HOST=redis
      - SPRING_REDIS_PORT=6379
    volumes:
      - ./backend/order-service:/app
    depends_on:
      - postgres
      - redis
    networks:
      - {{values.name}}-network

  # Payment Service
  payment-service:
    build:
      context: ./backend/payment-service
      dockerfile: Dockerfile
    ports:
      - "8083:8083"
    environment:
      - PORT=8083
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/{{values.name}}_payments
      - REDIS_URL=redis://redis:6379
{% if values.features.payments %}
      - STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
      - STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
{% endif %}
    volumes:
      - ./backend/payment-service:/app
    depends_on:
      - postgres
      - redis
    networks:
      - {{values.name}}-network

  # User Service
  user-service:
    build:
      context: ./backend/user-service
      dockerfile: Dockerfile
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:5000
      - ConnectionStrings__DefaultConnection=Host=postgres;Database={{values.name}}_users;Username=postgres;Password=postgres
      - ConnectionStrings__Redis=redis:6379
{% if values.backend.authentication == "azure-ad" %}
      - AzureAd__ClientId=your-client-id
      - AzureAd__ClientSecret=your-client-secret
      - AzureAd__TenantId=your-tenant-id
{% endif %}
    volumes:
      - ./backend/user-service:/app
    depends_on:
      - postgres
      - redis
    networks:
      - {{values.name}}-network

  # Notification Service
  notification-service:
    build:
      context: ./backend/notification-service
      dockerfile: Dockerfile
    ports:
      - "3002:3002"
    environment:
      - PORT=3002
      - NODE_ENV=development
      - REDIS_URL=redis://redis:6379
      - EMAIL_PROVIDER=smtp
      - SMTP_HOST=mailhog
      - SMTP_PORT=1025
      - SMTP_USER=
      - SMTP_PASSWORD=
    volumes:
      - ./backend/notification-service:/app
      - /app/node_modules
    depends_on:
      - redis
      - mailhog
    networks:
      - {{values.name}}-network

  # Databases and Infrastructure
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB={{values.name}}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./data/sql/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - {{values.name}}-network

  mongo:
    image: mongo:7
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=admin
      - MONGO_INITDB_DATABASE={{values.name}}_catalog
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db
      - ./data/mongo/init.js:/docker-entrypoint-initdb.d/init.js
    networks:
      - {{values.name}}-network

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - {{values.name}}-network

  # Development Tools
  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "1025:1025"
      - "8025:8025"
    networks:
      - {{values.name}}-network

  adminer:
    image: adminer:latest
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    networks:
      - {{values.name}}-network

  redis-commander:
    image: rediscommander/redis-commander:latest
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    depends_on:
      - redis
    networks:
      - {{values.name}}-network

volumes:
  postgres_data:
  mongo_data:
  redis_data:

networks:
  {{values.name}}-network:
    driver: bridge
EOF

    # Development docker-compose override
    cat > "$COMPOSE_DIR/docker-compose.dev.yml" << 'EOF'
version: '3.8'

services:
  # Override for development with hot reload
  frontend-portal:
    command: npm run dev
    environment:
      - WATCHPACK_POLLING=true
    stdin_open: true
    tty: true

  frontend-admin:
    command: npm run dev
    environment:
      - WATCHPACK_POLLING=true
    stdin_open: true
    tty: true

  api-gateway:
    command: npm run dev
    environment:
      - DEBUG=*
    stdin_open: true
    tty: true

  catalog-service:
    command: npm run dev
    environment:
      - DEBUG=*
    stdin_open: true
    tty: true

  cart-service:
    command: go run main.go
    environment:
      - GO_ENV=development
    stdin_open: true
    tty: true

  notification-service:
    command: npm run dev
    environment:
      - DEBUG=*
    stdin_open: true
    tty: true
EOF

    # Production docker-compose
    cat > "$COMPOSE_DIR/docker-compose.prod.yml" << 'EOF'
version: '3.8'

services:
  frontend-portal:
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  frontend-admin:
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  api-gateway:
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    
  catalog-service:
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  cart-service:
    environment:
      - GO_ENV=production
    restart: unless-stopped

  order-service:
    environment:
      - SPRING_PROFILES_ACTIVE=production
    restart: unless-stopped

  payment-service:
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  user-service:
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
    restart: unless-stopped

  notification-service:
    environment:
      - NODE_ENV=production
    restart: unless-stopped

  postgres:
    restart: unless-stopped
    
  mongo:
    restart: unless-stopped
    
  redis:
    restart: unless-stopped
EOF

    success "Docker Compose configuration created successfully!"
}

# Create development scripts
create_dev_scripts() {
    log "Creating development scripts..."
    
    local SCRIPTS_DIR="demos/ecommerce-showcase/templates/ecommerce-fullstack/skeleton/scripts"
    
    # Development setup script
    cat > "$SCRIPTS_DIR/dev-setup.sh" << 'EOF'
#!/bin/bash
# 🛠️ Development Environment Setup Script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
warning() { echo -e "${YELLOW}[WARNING] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; }

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    local missing=()
    
    # Check required tools
    command -v docker >/dev/null 2>&1 || missing+=("docker")
    command -v docker-compose >/dev/null 2>&1 || missing+=("docker-compose")
    command -v node >/dev/null 2>&1 || missing+=("node")
    command -v npm >/dev/null 2>&1 || missing+=("npm")
    command -v go >/dev/null 2>&1 || missing+=("go")
    command -v java >/dev/null 2>&1 || missing+=("java")
    command -v python3 >/dev/null 2>&1 || missing+=("python3")
    command -v dotnet >/dev/null 2>&1 || missing+=("dotnet")
    
    if [ ${#missing[@]} -gt 0 ]; then
        error "Missing required tools: ${missing[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
    
    success "All prerequisites satisfied!"
}

# Install dependencies
install_dependencies() {
    log "Installing dependencies..."
    
    # Frontend dependencies
    log "Installing frontend dependencies..."
    cd frontend/portal && npm install && cd ../..
    cd frontend/admin && npm install && cd ../..
    
    # Backend dependencies
    log "Installing backend dependencies..."
    cd backend/api-gateway && npm install && cd ../..
    cd backend/catalog-service && npm install && cd ../..
    cd backend/notification-service && npm install && cd ../..
    
    # Go dependencies
    log "Installing Go dependencies..."
    cd backend/cart-service && go mod download && cd ../..
    
    # Java dependencies
    log "Installing Java dependencies..."
    cd backend/order-service && ./gradlew build -x test && cd ../..
    
    # Python dependencies
    log "Installing Python dependencies..."
    cd backend/payment-service && pip install -r requirements.txt && cd ../..
    
    # .NET dependencies
    log "Installing .NET dependencies..."
    cd backend/user-service && dotnet restore && cd ../..
    
    success "All dependencies installed!"
}

# Setup environment files
setup_environment() {
    log "Setting up environment files..."
    
    # Create .env files from templates
    for dir in frontend/portal frontend/admin backend/*/; do
        if [ -f "$dir/.env.example" ]; then
            cp "$dir/.env.example" "$dir/.env"
            log "Created .env file for $dir"
        fi
    done
    
    # Create main .env file
    cat > .env << 'ENV_EOF'
# {{values.name | title}} E-commerce Platform - Development Environment

# Application
APP_NAME={{values.name}}
APP_ENV=development
NODE_ENV=development

# URLs
FRONTEND_URL=http://localhost:3000
API_URL=http://localhost:8080

# Database URLs
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/{{values.name}}
MONGO_URI=mongodb://admin:admin@localhost:27017/{{values.name}}_catalog?authSource=admin
REDIS_URL=redis://localhost:6379

# Authentication
JWT_SECRET=your-dev-jwt-secret-change-in-production
SESSION_SECRET=your-dev-session-secret-change-in-production

# Feature Flags
FEATURE_PAYMENTS={{values.features.payments}}
FEATURE_SEARCH={{values.features.search}}
FEATURE_RECOMMENDATIONS={{values.features.recommendations}}
FEATURE_ANALYTICS={{values.features.analytics}}

{% if values.features.payments %}
# Stripe (Test Keys)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
{% endif %}

{% if values.features.search %}
# Azure Cognitive Search
AZURE_SEARCH_ENDPOINT=https://your-search-service.search.windows.net
AZURE_SEARCH_API_KEY=your-search-api-key
{% endif %}

{% if values.features.recommendations %}
# Azure OpenAI
AZURE_OPENAI_ENDPOINT=https://your-openai.openai.azure.com
AZURE_OPENAI_API_KEY=your-openai-api-key
AZURE_OPENAI_DEPLOYMENT_NAME=gpt-35-turbo
{% endif %}

# Email (Development)
EMAIL_PROVIDER=smtp
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASSWORD=

# Logging
LOG_LEVEL=debug
DEBUG=*
ENV_EOF
    
    success "Environment files created!"
}

# Setup database
setup_database() {
    log "Setting up databases..."
    
    # Wait for databases to be ready
    log "Waiting for databases to start..."
    sleep 10
    
    # Run database migrations
    log "Running database migrations..."
    
    # PostgreSQL setup
    PGPASSWORD=postgres psql -h localhost -U postgres -d {{values.name}} -f data/sql/schema.sql || true
    PGPASSWORD=postgres psql -h localhost -U postgres -d {{values.name}} -f data/sql/seed.sql || true
    
    # MongoDB setup
    mongosh "mongodb://admin:admin@localhost:27017/{{values.name}}_catalog?authSource=admin" data/mongo/seed.js || true
    
    success "Database setup complete!"
}

# Main setup function
main() {
    echo -e "${BLUE}"
    cat << 'BANNER'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🛠️ {{values.name | title}} Development Setup               ║
║                                                              ║
║    Setting up your local development environment            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
    echo -e "${NC}"
    
    check_prerequisites
    
    log "Starting Docker services..."
    docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d postgres mongo redis mailhog
    
    setup_environment
    install_dependencies
    setup_database
    
    success "Development environment setup complete!"
    
    echo -e "\n${GREEN}🚀 Your development environment is ready!${NC}"
    echo -e "\n📋 Quick start commands:"
    echo -e "  • Start all services: ${YELLOW}npm run dev${NC}"
    echo -e "  • Start frontend only: ${YELLOW}npm run dev:frontend${NC}"
    echo -e "  • Start backend only: ${YELLOW}npm run dev:backend${NC}"
    echo -e "  • View logs: ${YELLOW}docker-compose logs -f${NC}"
    echo -e "\n🌐 Access points:"
    echo -e "  • Frontend: ${BLUE}http://localhost:3000${NC}"
    echo -e "  • Admin: ${BLUE}http://localhost:3001${NC}"
    echo -e "  • API Gateway: ${BLUE}http://localhost:8080${NC}"
    echo -e "  • MailHog: ${BLUE}http://localhost:8025${NC}"
    echo -e "  • Adminer: ${BLUE}http://localhost:8080${NC}"
    echo -e "  • Redis Commander: ${BLUE}http://localhost:8081${NC}"
}

main "$@"
EOF

    chmod +x "$SCRIPTS_DIR/dev-setup.sh"

    # Build script
    cat > "$SCRIPTS_DIR/build.sh" << 'EOF'
#!/bin/bash
# 🏗️ Build Script for {{values.name | title}}

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }

# Build all services
build_all() {
    log "Building all services..."
    
    # Build frontend
    log "Building frontend services..."
    cd frontend/portal && npm run build && cd ../..
    cd frontend/admin && npm run build && cd ../..
    
    # Build backend services
    log "Building backend services..."
    cd backend/api-gateway && npm run build && cd ../..
    cd backend/catalog-service && npm run build && cd ../..
    cd backend/cart-service && go build -o bin/cart-service main.go && cd ../..
    cd backend/order-service && ./gradlew build && cd ../..
    cd backend/payment-service && python -m py_compile main.py && cd ../..
    cd backend/user-service && dotnet build --configuration Release && cd ../..
    cd backend/notification-service && npm run build && cd ../..
    
    success "All services built successfully!"
}

# Build Docker images
build_images() {
    log "Building Docker images..."
    
    docker-compose build --parallel
    
    success "Docker images built successfully!"
}

# Parse arguments
case "${1:-all}" in
    "frontend")
        cd frontend/portal && npm run build && cd ../..
        cd frontend/admin && npm run build && cd ../..
        ;;
    "backend")
        build_all
        ;;
    "images")
        build_images
        ;;
    "all")
        build_all
        build_images
        ;;
    *)
        echo "Usage: $0 [frontend|backend|images|all]"
        exit 1
        ;;
esac
EOF

    chmod +x "$SCRIPTS_DIR/build.sh"

    # Test script
    cat > "$SCRIPTS_DIR/test.sh" << 'EOF'
#!/bin/bash
# 🧪 Test Script for {{values.name | title}}

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')] $1${NC}"; }
success() { echo -e "${GREEN}[SUCCESS] $1${NC}"; }
error() { echo -e "${RED}[ERROR] $1${NC}" >&2; }

# Run tests for all services
run_all_tests() {
    local failed=()
    
    log "Running all tests..."
    
    # Frontend tests
    log "Testing frontend services..."
    cd frontend/portal
    if npm test -- --watchAll=false; then
        success "Frontend portal tests passed"
    else
        failed+=("frontend-portal")
    fi
    cd ../..
    
    cd frontend/admin
    if npm test -- --watchAll=false; then
        success "Frontend admin tests passed"
    else
        failed+=("frontend-admin")
    fi
    cd ../..
    
    # Backend tests
    log "Testing backend services..."
    cd backend/api-gateway
    if npm test; then
        success "API Gateway tests passed"
    else
        failed+=("api-gateway")
    fi
    cd ../..
    
    cd backend/catalog-service
    if npm test; then
        success "Catalog service tests passed"
    else
        failed+=("catalog-service")
    fi
    cd ../..
    
    cd backend/cart-service
    if go test ./...; then
        success "Cart service tests passed"
    else
        failed+=("cart-service")
    fi
    cd ../..
    
    cd backend/order-service
    if ./gradlew test; then
        success "Order service tests passed"
    else
        failed+=("order-service")
    fi
    cd ../..
    
    cd backend/payment-service
    if pytest; then
        success "Payment service tests passed"
    else
        failed+=("payment-service")
    fi
    cd ../..
    
    cd backend/user-service
    if dotnet test; then
        success "User service tests passed"
    else
        failed+=("user-service")
    fi
    cd ../..
    
    cd backend/notification-service
    if npm test; then
        success "Notification service tests passed"
    else
        failed+=("notification-service")
    fi
    cd ../..
    
    # Summary
    if [ ${#failed[@]} -eq 0 ]; then
        success "All tests passed! 🎉"
    else
        error "Failed services: ${failed[*]}"
        exit 1
    fi
}

# Integration tests
run_integration_tests() {
    log "Running integration tests..."
    
    # Start test environment
    docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
    
    # Wait for services to be ready
    sleep 30
    
    # Run integration tests
    cd tests/integration
    if npm test; then
        success "Integration tests passed"
    else
        error "Integration tests failed"
        docker-compose -f docker-compose.yml -f docker-compose.test.yml down
        exit 1
    fi
    cd ../..
    
    # Cleanup
    docker-compose -f docker-compose.yml -f docker-compose.test.yml down
}

# E2E tests
run_e2e_tests() {
    log "Running E2E tests..."
    
    cd tests/e2e
    if npx cypress run; then
        success "E2E tests passed"
    else
        error "E2E tests failed"
        exit 1
    fi
    cd ../..
}

# Parse arguments
case "${1:-all}" in
    "unit")
        run_all_tests
        ;;
    "integration")
        run_integration_tests
        ;;
    "e2e")
        run_e2e_tests
        ;;
    "all")
        run_all_tests
        run_integration_tests
        ;;
    *)
        echo "Usage: $0 [unit|integration|e2e|all]"
        exit 1
        ;;
esac
EOF

    chmod +x "$SCRIPTS_DIR/test.sh"

    success "Development scripts created successfully!"
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║    🚀 Deployment & Configuration Generator                   ║
║                                                              ║
║    Creating Kubernetes manifests, Docker configs,           ║
║    and deployment scripts for Three Horizons demo           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    create_kubernetes_manifests
    create_docker_compose
    create_dev_scripts
    
    success "Deployment configurations generated successfully!"
    
    echo -e "\n${GREEN}✅ Deployment configurations are ready!${NC}"
    echo -e "\n📁 Configurations created:"
    echo -e "  • Kubernetes manifests for production deployment"
    echo -e "  • Docker Compose for local development"
    echo -e "  • Development setup and build scripts"
    echo -e "  • Testing scripts for all services"
    echo -e "\n🚀 Ready for database schemas and final integration!"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi