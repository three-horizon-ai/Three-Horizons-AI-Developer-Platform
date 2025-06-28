# 📁 H1-007: Arquivos de Configuração Completos

## 📋 Índice de Configurações

1. [⚓ Helm Charts](#helm-charts)
2. [🔧 Kubernetes Manifests](#kubernetes-manifests)
3. [🐳 Dockerfiles](#dockerfiles)
4. [📝 Application Configs](#application-configs)
5. [🔄 GitOps Configs](#gitops-configs)
6. [📊 Monitoring Configs](#monitoring-configs)
7. [🌐 Ingress & Networking](#ingress-networking)
8. [🔐 Security Configs](#security-configs)

## ⚓ Helm Charts {#helm-charts}

### Chart Frontend Base

```yaml
# charts/frontend/Chart.yaml
apiVersion: v2
name: frontend
description: Frontend application for Three Horizons Platform
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - frontend
  - nextjs
  - react
home: https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform
sources:
  - https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform
maintainers:
  - name: Platform Team
    email: platform@threehorizons.ai
dependencies:
  - name: common
    version: 2.x.x
    repository: https://charts.bitnami.com/bitnami
    condition: common.enabled
```

```yaml
# charts/frontend/values.yaml
replicaCount: 2

image:
  repository: frontend
  pullPolicy: IfNotPresent
  tag: ""

imagePullSecrets:
  - name: acr-secret

nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"
  prometheus.io/path: "/api/metrics"

podSecurityContext:
  fsGroup: 1001
  runAsNonRoot: true
  runAsUser: 1001

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1001

service:
  type: ClusterIP
  port: 80
  targetPort: 3000
  annotations: {}

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
  hosts:
    - host: portal.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: portal-tls
      hosts:
        - portal.example.com

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80

nodeSelector: {}

tolerations: []

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - "{{ include \"frontend.name\" . }}"
        topologyKey: kubernetes.io/hostname

livenessProbe:
  httpGet:
    path: /api/health
    port: http
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /api/ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3

# Frontend specific configuration
frontend:
  type: portal  # portal or admin
  config:
    NEXT_PUBLIC_API_URL: "https://api.example.com"
    NEXT_PUBLIC_ENV: "production"
    NEXT_PUBLIC_FEATURES_PAYMENTS: "true"
    NEXT_PUBLIC_FEATURES_AI: "true"
  secrets:
    NEXTAUTH_SECRET: ""
    NEXTAUTH_URL: ""

# Volumes for Next.js cache
volumes:
  - name: nextjs-cache
    emptyDir: {}
  - name: tmp
    emptyDir: {}

volumeMounts:
  - name: nextjs-cache
    mountPath: /app/.next/cache
  - name: tmp
    mountPath: /tmp

# Service Monitor for Prometheus
serviceMonitor:
  enabled: true
  interval: 30s
  path: /api/metrics
  labels:
    release: prometheus-stack
```

```yaml
# charts/frontend/values-portal.yaml
# Specific values for portal frontend
fullnameOverride: frontend-portal

frontend:
  type: portal
  config:
    NEXT_PUBLIC_APP_NAME: "Three Horizons Portal"
    NEXT_PUBLIC_STRIPE_PUBLIC_KEY: "pk_test_..."

ingress:
  hosts:
    - host: portal.demo.threehorizons.io
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: portal-tls
      hosts:
        - portal.demo.threehorizons.io
```

### Chart Microservice Base

```yaml
# charts/microservice/Chart.yaml
apiVersion: v2
name: microservice
description: Base microservice chart for Three Horizons Platform
type: application
version: 1.0.0
appVersion: "1.0.0"
```

```yaml
# charts/microservice/values.yaml
replicaCount: 2

image:
  repository: microservice
  pullPolicy: IfNotPresent
  tag: ""

imagePullSecrets:
  - name: acr-secret

nameOverride: ""
fullnameOverride: ""

serviceAccount:
  create: true
  annotations: {}
  name: ""

podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
  linkerd.io/inject: enabled

podSecurityContext:
  fsGroup: 1001
  runAsNonRoot: true
  runAsUser: 1001
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1001

service:
  type: ClusterIP
  port: 80
  targetPort: 8080
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max

nodeSelector: {}

tolerations: []

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - "{{ include \"microservice.name\" . }}"
        topologyKey: kubernetes.io/hostname

livenessProbe:
  httpGet:
    path: /health/live
    port: http
    httpHeaders:
    - name: Accept
      value: application/json
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
  successThreshold: 1

readinessProbe:
  httpGet:
    path: /health/ready
    port: http
    httpHeaders:
    - name: Accept
      value: application/json
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
  successThreshold: 1

startupProbe:
  httpGet:
    path: /health/startup
    port: http
  failureThreshold: 30
  periodSeconds: 10

# Service specific configuration
microservice:
  name: ""
  type: ""  # api, worker, scheduled
  
config:
  LOG_LEVEL: info
  NODE_ENV: production
  PORT: "8080"
  
secrets:
  DATABASE_URL: ""
  REDIS_URL: ""
  JWT_SECRET: ""

# External services configuration
database:
  enabled: false
  type: postgresql  # postgresql, mysql, mongodb
  host: ""
  port: 5432
  name: ""
  username: ""
  passwordSecret: ""
  ssl: true

redis:
  enabled: false
  host: ""
  port: 6379
  passwordSecret: ""
  ssl: true

# Message queue configuration
messageQueue:
  enabled: false
  type: rabbitmq  # rabbitmq, kafka, azure-service-bus
  host: ""
  port: 5672
  username: ""
  passwordSecret: ""

# Service mesh configuration
serviceMesh:
  enabled: true
  type: linkerd  # linkerd, istio
  
# Volumes
volumes: []
volumeMounts: []

# Service Monitor for Prometheus
serviceMonitor:
  enabled: true
  interval: 30s
  path: /metrics
  labels:
    release: prometheus-stack

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Network Policy
networkPolicy:
  enabled: true
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: ingress-nginx
      - podSelector:
          matchLabels:
            app.kubernetes.io/name: api-gateway
  egress:
    - to:
      - namespaceSelector: {}
    - to:
      - podSelector: {}
    - ports:
      - protocol: TCP
        port: 53
      - protocol: UDP
        port: 53
```

### Templates Helm

```yaml
# charts/frontend/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "frontend.fullname" . }}
  labels:
    {{- include "frontend.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "frontend.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
        {{- with .Values.podAnnotations }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      labels:
        {{- include "frontend.selectorLabels" . | nindent 8 }}
        version: {{ .Values.image.tag | default .Chart.AppVersion }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "frontend.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.service.targetPort }}
              protocol: TCP
          env:
            - name: NODE_ENV
              value: production
            - name: PORT
              value: "{{ .Values.service.targetPort }}"
            {{- range $key, $value := .Values.frontend.config }}
            - name: {{ $key }}
              value: {{ $value | quote }}
            {{- end }}
          envFrom:
            - configMapRef:
                name: {{ include "frontend.fullname" . }}
            - secretRef:
                name: {{ include "frontend.fullname" . }}
          livenessProbe:
            {{- toYaml .Values.livenessProbe | nindent 12 }}
          readinessProbe:
            {{- toYaml .Values.readinessProbe | nindent 12 }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            {{- toYaml .Values.volumeMounts | nindent 12 }}
      volumes:
        {{- toYaml .Values.volumes | nindent 8 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
```

## 🔧 Kubernetes Manifests {#kubernetes-manifests}

### Base Kustomization

```yaml
# k8s/base/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # Frontend applications
  - frontend/portal/deployment.yaml
  - frontend/portal/service.yaml
  - frontend/portal/configmap.yaml
  - frontend/admin/deployment.yaml
  - frontend/admin/service.yaml
  - frontend/admin/configmap.yaml
  
  # Backend services
  - backend/api-gateway/deployment.yaml
  - backend/api-gateway/service.yaml
  - backend/api-gateway/configmap.yaml
  - backend/catalog-service/deployment.yaml
  - backend/catalog-service/service.yaml
  - backend/catalog-service/configmap.yaml
  - backend/cart-service/deployment.yaml
  - backend/cart-service/service.yaml
  - backend/cart-service/configmap.yaml
  - backend/order-service/deployment.yaml
  - backend/order-service/service.yaml
  - backend/order-service/configmap.yaml
  - backend/payment-service/deployment.yaml
  - backend/payment-service/service.yaml
  - backend/payment-service/configmap.yaml
  - backend/user-service/deployment.yaml
  - backend/user-service/service.yaml
  - backend/user-service/configmap.yaml
  - backend/notification-service/deployment.yaml
  - backend/notification-service/service.yaml
  - backend/notification-service/configmap.yaml
  
  # Common resources
  - common/namespace.yaml
  - common/serviceaccount.yaml
  - common/networkpolicy.yaml
  - common/poddisruptionbudget.yaml

commonLabels:
  app.kubernetes.io/part-of: three-horizons-platform
  app.kubernetes.io/managed-by: kustomize
```

### Environment Overlays

```yaml
# k8s/overlays/dev/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: ecommerce-dev

resources:
  - ../../base
  - ingress.yaml
  - secrets.yaml

patchesStrategicMerge:
  - patches/frontend-portal-patch.yaml
  - patches/frontend-admin-patch.yaml
  - patches/api-gateway-patch.yaml

configMapGenerator:
  - name: global-config
    behavior: merge
    literals:
      - ENVIRONMENT=development
      - LOG_LEVEL=debug
      - ENABLE_DEBUG=true
      - API_BASE_URL=https://api-dev.demo.threehorizons.io
      - FRONTEND_URL=https://portal-dev.demo.threehorizons.io

secretGenerator:
  - name: global-secrets
    behavior: merge
    literals:
      - JWT_SECRET=dev-secret-change-in-production
      - ENCRYPTION_KEY=dev-key-change-in-production

images:
  - name: frontend-portal
    newName: acrthreehorizonsdemo.azurecr.io/frontend-portal
    newTag: dev-latest
  - name: frontend-admin
    newName: acrthreehorizonsdemo.azurecr.io/frontend-admin
    newTag: dev-latest
  - name: api-gateway
    newName: acrthreehorizonsdemo.azurecr.io/api-gateway
    newTag: dev-latest
  - name: catalog-service
    newName: acrthreehorizonsdemo.azurecr.io/catalog-service
    newTag: dev-latest
  - name: cart-service
    newName: acrthreehorizonsdemo.azurecr.io/cart-service
    newTag: dev-latest
  - name: order-service
    newName: acrthreehorizonsdemo.azurecr.io/order-service
    newTag: dev-latest
  - name: payment-service
    newName: acrthreehorizonsdemo.azurecr.io/payment-service
    newTag: dev-latest
  - name: user-service
    newName: acrthreehorizonsdemo.azurecr.io/user-service
    newTag: dev-latest
  - name: notification-service
    newName: acrthreehorizonsdemo.azurecr.io/notification-service
    newTag: dev-latest

replicas:
  - name: frontend-portal
    count: 1
  - name: frontend-admin
    count: 1
  - name: api-gateway
    count: 2
  - name: catalog-service
    count: 2
  - name: cart-service
    count: 2
  - name: order-service
    count: 1
  - name: payment-service
    count: 1
  - name: user-service
    count: 1
  - name: notification-service
    count: 1

patches:
  - target:
      kind: Deployment
      labelSelector: "app.kubernetes.io/component=backend"
    patch: |-
      - op: add
        path: /spec/template/spec/containers/0/env/-
        value:
          name: DD_AGENT_HOST
          valueFrom:
            fieldRef:
              fieldPath: status.hostIP
```

### Ingress Configuration

```yaml
# k8s/overlays/dev/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: frontend-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
      - portal-dev.demo.threehorizons.io
      - admin-dev.demo.threehorizons.io
      secretName: frontend-tls
  rules:
    - host: portal-dev.demo.threehorizons.io
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: frontend-portal
              port:
                number: 80
    - host: admin-dev.demo.threehorizons.io
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: frontend-admin
              port:
                number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/cors-enable: "true"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
      - api-dev.demo.threehorizons.io
      secretName: api-tls
  rules:
    - host: api-dev.demo.threehorizons.io
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: api-gateway
              port:
                number: 80
```

## 🐳 Dockerfiles {#dockerfiles}

### Frontend Dockerfile

```dockerfile
# frontend/portal/Dockerfile
# Build stage
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./
RUN npm ci --only=production

# Rebuild the source code only when needed
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build application
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

# Production image
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built application
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Set correct permissions
RUN chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

ENV PORT 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

CMD ["node", "server.js"]
```

### API Gateway Dockerfile

```dockerfile
# backend/api-gateway/Dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies for building
RUN apk add --no-cache python3 g++ make

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# Production stage
FROM node:20-alpine AS production
WORKDIR /app

# Install dumb-init
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./

# Create necessary directories
RUN mkdir -p /app/logs && chown -R nodejs:nodejs /app/logs

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 8080

# Environment variables
ENV NODE_ENV=production \
    PORT=8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node dist/health-check.js || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]
```

### Microservice Go Dockerfile

```dockerfile
# backend/cart-service/Dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

# Install dependencies
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s -X main.Version=${VERSION} -X main.BuildTime=${BUILD_TIME}" \
    -o cart-service \
    ./cmd/server

# Production stage
FROM scratch

# Copy SSL certificates
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the binary
COPY --from=builder /app/cart-service /cart-service

# Expose port
EXPOSE 8080

# Run the binary
ENTRYPOINT ["/cart-service"]
```

## 📝 Application Configs {#application-configs}

### Frontend Configuration

```typescript
// frontend/portal/next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  reactStrictMode: true,
  swcMinify: true,
  
  images: {
    domains: [
      'localhost',
      'acrthreehorizonsdemo.azurecr.io',
      'storage.azure.com',
      'res.cloudinary.com'
    ],
    formats: ['image/avif', 'image/webp'],
  },
  
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL,
    NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  },
  
  headers: async () => [
    {
      source: '/:path*',
      headers: [
        {
          key: 'X-DNS-Prefetch-Control',
          value: 'on',
        },
        {
          key: 'Strict-Transport-Security',
          value: 'max-age=63072000; includeSubDomains; preload',
        },
        {
          key: 'X-Content-Type-Options',
          value: 'nosniff',
        },
        {
          key: 'X-Frame-Options',
          value: 'DENY',
        },
        {
          key: 'X-XSS-Protection',
          value: '1; mode=block',
        },
        {
          key: 'Referrer-Policy',
          value: 'origin-when-cross-origin',
        },
        {
          key: 'Permissions-Policy',
          value: 'camera=(), microphone=(), geolocation=()',
        },
      ],
    },
  ],
  
  redirects: async () => [
    {
      source: '/admin',
      destination: 'https://admin.demo.threehorizons.io',
      permanent: true,
    },
  ],
  
  rewrites: async () => [
    {
      source: '/api/:path*',
      destination: `${process.env.NEXT_PUBLIC_API_URL}/:path*`,
    },
  ],
}

module.exports = nextConfig
```

### API Gateway Configuration

```typescript
// backend/api-gateway/src/config/index.ts
export const config = {
  app: {
    name: process.env.APP_NAME || 'API Gateway',
    version: process.env.APP_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    port: parseInt(process.env.PORT || '8080', 10),
  },
  
  cors: {
    origins: (process.env.CORS_ORIGINS || 'http://localhost:3000').split(','),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
    maxAge: 86400,
  },
  
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '60000', 10),
    max: parseInt(process.env.RATE_LIMIT_MAX || '100', 10),
    message: 'Too many requests from this IP',
    standardHeaders: true,
    legacyHeaders: false,
  },
  
  services: {
    catalog: process.env.CATALOG_SERVICE_URL || 'http://catalog-service',
    cart: process.env.CART_SERVICE_URL || 'http://cart-service',
    order: process.env.ORDER_SERVICE_URL || 'http://order-service',
    payment: process.env.PAYMENT_SERVICE_URL || 'http://payment-service',
    user: process.env.USER_SERVICE_URL || 'http://user-service',
    notification: process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service',
  },
  
  auth: {
    jwtSecret: process.env.JWT_SECRET || 'change-me-in-production',
    jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
    refreshTokenExpiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '30d',
  },
  
  cache: {
    redis: {
      url: process.env.REDIS_URL || 'redis://localhost:6379',
      ttl: parseInt(process.env.CACHE_TTL || '3600', 10),
    },
  },
  
  monitoring: {
    metrics: {
      enabled: process.env.METRICS_ENABLED !== 'false',
      port: parseInt(process.env.METRICS_PORT || '9090', 10),
      path: process.env.METRICS_PATH || '/metrics',
    },
    tracing: {
      enabled: process.env.TRACING_ENABLED === 'true',
      serviceName: 'api-gateway',
      jaegerEndpoint: process.env.JAEGER_ENDPOINT || 'http://jaeger:14268/api/traces',
    },
  },
  
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    format: process.env.LOG_FORMAT || 'json',
    prettyPrint: process.env.NODE_ENV === 'development',
  },
}
```

## 🔄 GitOps Configs {#gitops-configs}

### ArgoCD Application

```yaml
# gitops/apps/ecommerce-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ecommerce-platform
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  
  source:
    repoURL: https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform
    targetRevision: main
    path: k8s/overlays/dev
    
    # Helm specific
    helm:
      valueFiles:
        - values-dev.yaml
      parameters:
        - name: image.tag
          value: "latest"
        - name: ingress.enabled
          value: "true"
      
      # Plugin configuration for secrets
      plugin:
        name: argocd-vault-plugin
        env:
          - name: AVP_K8S_ROLE
            value: argocd
          - name: AVP_TYPE
            value: azurekeyvault
  
  destination:
    server: https://kubernetes.default.svc
    namespace: ecommerce-dev
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - CreateNamespace=true
    - ServerSideApply=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  
  revisionHistoryLimit: 3
  
  # Health checks
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
  - group: autoscaling
    kind: HorizontalPodAutoscaler
    jsonPointers:
    - /spec/minReplicas
    - /spec/maxReplicas
```

### ApplicationSet for Multi-env

```yaml
# gitops/apps/ecommerce-appset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: ecommerce-platform
  namespace: argocd
spec:
  generators:
  - git:
      repoURL: https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform
      revision: main
      directories:
      - path: k8s/overlays/*
  - list:
      elements:
      - cluster: dev-cluster
        url: https://kubernetes.default.svc
        namespace: ecommerce-dev
        values: values-dev.yaml
      - cluster: staging-cluster
        url: https://staging.k8s.local
        namespace: ecommerce-staging
        values: values-staging.yaml
      - cluster: prod-cluster
        url: https://prod.k8s.local
        namespace: ecommerce-prod
        values: values-prod.yaml
  
  template:
    metadata:
      name: 'ecommerce-{{cluster}}'
      labels:
        environment: '{{cluster}}'
    spec:
      project: default
      source:
        repoURL: https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform
        targetRevision: main
        path: '{{path}}'
        helm:
          valueFiles:
          - '{{values}}'
      destination:
        server: '{{url}}'
        namespace: '{{namespace}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: '{{cluster}}' != 'prod-cluster'
```

## 📊 Monitoring Configs {#monitoring-configs}

### Prometheus Configuration

```yaml
# monitoring/prometheus/values.yaml
prometheus:
  prometheusSpec:
    image:
      repository: quay.io/prometheus/prometheus
      tag: v2.48.0
    
    retention: 30d
    retentionSize: "50GB"
    
    resources:
      requests:
        cpu: 1000m
        memory: 2Gi
      limits:
        cpu: 2000m
        memory: 4Gi
    
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: managed-premium
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 100Gi
    
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false
    
    additionalScrapeConfigs:
    - job_name: 'kubernetes-pods'
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
    
    remoteWrite:
    - url: http://victoria-metrics:8428/api/v1/write
      writeRelabelConfigs:
      - sourceLabels: [__name__]
        regex: 'go_.*'
        action: drop
```

### Grafana Dashboards

```json
// monitoring/grafana/dashboards/platform-overview.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": "-- Grafana --",
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "gnetId": null,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "panels": [
    {
      "datasource": "Prometheus",
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "palette-classic"
          },
          "custom": {
            "axisLabel": "",
            "axisPlacement": "auto",
            "barAlignment": 0,
            "drawStyle": "line",
            "fillOpacity": 10,
            "gradientMode": "none",
            "hideFrom": {
              "tooltip": false,
              "viz": false,
              "legend": false
            },
            "lineInterpolation": "linear",
            "lineWidth": 1,
            "pointSize": 5,
            "scaleDistribution": {
              "type": "linear"
            },
            "showPoints": "never",
            "spanNulls": false,
            "stacking": {
              "group": "A",
              "mode": "none"
            },
            "thresholdsStyle": {
              "mode": "off"
            }
          },
          "mappings": [],
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green",
                "value": null
              },
              {
                "color": "red",
                "value": 80
              }
            ]
          },
          "unit": "reqps"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 8,
        "w": 12,
        "x": 0,
        "y": 0
      },
      "id": 2,
      "options": {
        "tooltip": {
          "mode": "single"
        },
        "legend": {
          "calcs": [],
          "displayMode": "list",
          "placement": "bottom"
        }
      },
      "pluginVersion": "8.0.0",
      "targets": [
        {
          "expr": "sum(rate(http_requests_total[5m])) by (service)",
          "legendFormat": "{{service}}",
          "refId": "A"
        }
      ],
      "title": "Request Rate by Service",
      "type": "timeseries"
    }
  ],
  "schemaVersion": 30,
  "style": "dark",
  "tags": ["platform", "overview"],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "Three Horizons Platform Overview",
  "uid": "platform-overview",
  "version": 0
}
```

### AlertManager Configuration

```yaml
# monitoring/alertmanager/config.yaml
global:
  resolve_timeout: 5m
  slack_api_url: '${SLACK_WEBHOOK_URL}'
  pagerduty_url: 'https://events.pagerduty.com/v2/enqueue'

route:
  group_by: ['alertname', 'cluster', 'service', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  routes:
  # Critical alerts go to PagerDuty
  - match:
      severity: critical
    receiver: pagerduty
    continue: true
  
  # Platform alerts
  - match:
      team: platform
    receiver: platform-slack
    routes:
    - match:
        severity: warning
      receiver: platform-slack-warnings
  
  # Business alerts
  - match_re:
      alertname: '^(LowOrderRate|PaymentFailure|HighCartAbandonment)$'
    receiver: business-slack

receivers:
- name: 'default'
  slack_configs:
  - channel: '#alerts'
    title: 'Alert: {{ .GroupLabels.alertname }}'
    text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
    send_resolved: true

- name: 'pagerduty'
  pagerduty_configs:
  - service_key: '${PAGERDUTY_SERVICE_KEY}'
    description: '{{ .GroupLabels.alertname }}: {{ .CommonAnnotations.description }}'
    client: 'Three Horizons Platform'
    client_url: 'https://grafana.demo.threehorizons.io'
    details:
      severity: '{{ .GroupLabels.severity }}'
      environment: '{{ .GroupLabels.environment }}'
      service: '{{ .GroupLabels.service }}'

- name: 'platform-slack'
  slack_configs:
  - channel: '#platform-alerts'
    title: '{{ .GroupLabels.severity | toUpper }}: {{ .GroupLabels.alertname }}'
    text: '{{ .CommonAnnotations.description }}'
    color: '{{ if eq .GroupLabels.severity "critical" }}danger{{ else if eq .GroupLabels.severity "warning" }}warning{{ else }}good{{ end }}'
    actions:
    - type: button
      text: 'View in Grafana'
      url: '{{ .CommonAnnotations.grafana_url }}'
    - type: button
      text: 'Runbook'
      url: '{{ .CommonAnnotations.runbook_url }}'

- name: 'platform-slack-warnings'
  slack_configs:
  - channel: '#platform-warnings'
    title: 'Warning: {{ .GroupLabels.alertname }}'
    send_resolved: false

- name: 'business-slack'
  slack_configs:
  - channel: '#business-alerts'
    title: 'Business Alert: {{ .GroupLabels.alertname }}'
    text: '{{ .CommonAnnotations.description }}'

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'cluster', 'service']
```

## 🌐 Ingress & Networking {#ingress-networking}

### NGINX Ingress Configuration

```yaml
# ingress/nginx-values.yaml
controller:
  kind: Deployment
  replicaCount: 3
  
  image:
    registry: registry.k8s.io
    image: ingress-nginx/controller
    tag: "v1.9.4"
  
  config:
    # Security headers
    add-headers: "ingress-nginx/custom-headers"
    force-ssl-redirect: "true"
    ssl-protocols: "TLSv1.2 TLSv1.3"
    ssl-ciphers: "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
    
    # Performance
    use-gzip: "true"
    gzip-level: "6"
    gzip-types: "application/atom+xml application/javascript application/x-javascript application/json application/rss+xml application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/svg+xml image/x-icon text/css text/javascript text/plain text/x-component"
    
    # Rate limiting
    limit-rate: "100"
    limit-rate-after: "10m"
    limit-req-status-code: "429"
    
    # Proxy settings
    proxy-body-size: "10m"
    proxy-connect-timeout: "60"
    proxy-send-timeout: "60"
    proxy-read-timeout: "60"
    proxy-next-upstream: "error timeout http_502"
    proxy-next-upstream-tries: "3"
    
    # Logging
    log-format-escape-json: "true"
    log-format-upstream: '{"time": "$time_iso8601", "remote_addr": "$remote_addr", "x_forwarded_for": "$proxy_add_x_forwarded_for", "request_id": "$req_id", "remote_user": "$remote_user", "bytes_sent": $bytes_sent, "request_time": $request_time, "status": $status, "vhost": "$host", "request_proto": "$server_protocol", "path": "$uri", "request_query": "$args", "request_length": $request_length, "duration": $request_time, "method": "$request_method", "http_referrer": "$http_referer", "http_user_agent": "$http_user_agent"}'
  
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "false"
      service.beta.kubernetes.io/azure-dns-label-name: "threehorizons-ingress"
  
  resources:
    limits:
      cpu: 1000m
      memory: 1024Mi
    requests:
      cpu: 100m
      memory: 256Mi
  
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10
    targetCPUUtilizationPercentage: 80
    targetMemoryUtilizationPercentage: 80
  
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      additionalLabels:
        release: prometheus-stack
  
  podSecurityPolicy:
    enabled: true
  
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - ingress-nginx
        topologyKey: kubernetes.io/hostname

defaultBackend:
  enabled: true
  image:
    registry: registry.k8s.io
    image: defaultbackend-amd64
    tag: "1.5"
  
  replicaCount: 2
```

### Network Policies

```yaml
# k8s/base/common/networkpolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-nginx
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-gateway
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: api-gateway
    ports:
    - protocol: TCP
      port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus-scraping
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: prometheus
    ports:
    - protocol: TCP
      port: 8080
    - protocol: TCP
      port: 3000
```

## 🔐 Security Configs {#security-configs}

### Pod Security Policy

```yaml
# k8s/base/common/podsecuritypolicy.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: 'runtime/default'
    apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    seccomp.security.alpha.kubernetes.io/defaultProfileName: 'runtime/default'
    apparmor.security.beta.kubernetes.io/defaultProfileName: 'runtime/default'
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
    - 'downwardAPI'
    - 'persistentVolumeClaim'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  supplementalGroups:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
```

### RBAC Configuration

```yaml
# k8s/base/common/rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: application-sa
  annotations:
    azure.workload.identity/client-id: "${WORKLOAD_IDENTITY_CLIENT_ID}"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: application-role
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: application-rolebinding
subjects:
- kind: ServiceAccount
  name: application-sa
roleRef:
  kind: Role
  name: application-role
  apiGroup: rbac.authorization.k8s.io
```

### Secrets Management

```yaml
# k8s/base/common/sealed-secret.yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: application-secrets
spec:
  encryptedData:
    DATABASE_URL: AgBvqM5Zr1DK8... # Encrypted value
    JWT_SECRET: AgCJKw8TqPZX9... # Encrypted value
    STRIPE_API_KEY: AgDLMn9UrQAY7... # Encrypted value
  template:
    metadata:
      name: application-secrets
    type: Opaque
```

---

## 🎯 Próximos Passos

Com todos os arquivos de configuração prontos:

1. Personalize os valores para seu ambiente
2. Execute os scripts de automação
3. Valide as configurações
4. Faça deploy das aplicações

---

**📝 Checklist de Configurações**

- [ ] Helm charts configurados
- [ ] Kubernetes manifests prontos
- [ ] Dockerfiles otimizados
- [ ] Configurações de aplicação
- [ ] GitOps configurado
- [ ] Monitoramento configurado
- [ ] Ingress e networking
- [ ] Segurança implementada