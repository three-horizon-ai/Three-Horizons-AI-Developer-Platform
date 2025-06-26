import React from 'react';

const COLORS = { 
  RED: '#B54369', 
  PURPLE: '#4D44AB', 
  BLUE: '#1B67B2', 
  BLACK: '#202020', 
  GREEN: '#568C1C', 
  ORANGE: '#C77F1A',
  AZURE_BLUE: '#0078D4',
  OPENSHIFT_RED: '#EE0000',
  GITHUB_PURPLE: '#6E5494',
  LIGHT_GREY: '#F8F8F8',
  MEDIUM_GREY: '#E0E0E0',
  DARK_GREY: '#666666',
  HIGHLIGHT_BLUE: '#2188ff',
  HIGHLIGHT_YELLOW: '#f9c513',
  HIGHLIGHT_PURPLE: '#6f42c1',
  SHIFT_LEFT_GREEN: '#10B981'
};

const ThreeHorizonsSecurityArchitecture = () => {
  return (
    <div className="flex justify-center min-h-screen antialiased relative bg-gray-50">
      <div className="w-full max-w-7xl p-4">
        <h1 className="text-3xl font-bold text-center mb-8 text-gray-800">
          Three Horizons AI Platform - Security Architecture & Flow
        </h1>
        
        {/* SVG Architecture Diagram */}
        <div className="w-full mb-8 bg-white rounded-lg shadow-lg p-4">
          <svg width="100%" height="1400" viewBox="0 0 1600 1400" xmlns="http://www.w3.org/2000/svg">
            {/* Background */}
            <rect width="1600" height="1400" fill="#ffffff" />
            
            {/* Title */}
            <text x="800" y="40" fontFamily="Arial, sans-serif" fontSize="32" textAnchor="middle" fontWeight="bold">
              Three Horizons AI Platform - Security Architecture
            </text>
            <text x="800" y="70" fontFamily="Arial, sans-serif" fontSize="20" textAnchor="middle" fill="#666">
              Shift-Left Security & Zero Trust Implementation
            </text>
            
            {/* Shift-Left Security Banner */}
            <g id="shift-left-banner">
              <rect x="100" y="100" width="1400" height="80" rx="10" fill={COLORS.SHIFT_LEFT_GREEN} opacity="0.1" stroke={COLORS.SHIFT_LEFT_GREEN} strokeWidth="2" />
              <text x="800" y="130" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                SHIFT-LEFT SECURITY APPROACH
              </text>
              <text x="800" y="155" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fill="#666">
                Security integrated from the earliest stages of development through production
              </text>
              
              {/* Shift-Left Flow Arrow */}
              <path d="M 150,140 L 1450,140" stroke={COLORS.SHIFT_LEFT_GREEN} strokeWidth="4" markerEnd="url(#shift-arrow)" opacity="0.5" />
              <text x="250" y="165" fontFamily="Arial, sans-serif" fontSize="14" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">DEV</text>
              <text x="600" y="165" fontFamily="Arial, sans-serif" fontSize="14" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">BUILD</text>
              <text x="950" y="165" fontFamily="Arial, sans-serif" fontSize="14" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">DEPLOY</text>
              <text x="1300" y="165" fontFamily="Arial, sans-serif" fontSize="14" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">OPERATE</text>
            </g>
            
            {/* Zero Trust Badge */}
            <g id="zero-trust-badge">
              <rect x="600" y="200" width="400" height="50" rx="25" fill="#333333" />
              <text x="800" y="230" fontFamily="Arial, sans-serif" fontSize="20" textAnchor="middle" fontWeight="bold" fill="white">
                Zero Trust Security Model
              </text>
            </g>
            
            {/* Platform Components - Properly Spaced */}
            <g id="main-components">
              {/* Azure AI Foundry */}
              <rect x="200" y="280" width="200" height="80" rx="15" fill={COLORS.AZURE_BLUE} />
              <text x="300" y="310" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">Azure AI</text>
              <text x="300" y="335" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">Foundry</text>
              
              {/* RHDH */}
              <rect x="500" y="280" width="200" height="80" rx="15" fill={COLORS.OPENSHIFT_RED} />
              <text x="600" y="310" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">Red Hat</text>
              <text x="600" y="335" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">Developer Hub</text>
              
              {/* GitHub Enterprise */}
              <rect x="800" y="280" width="200" height="80" rx="15" fill={COLORS.GITHUB_PURPLE} />
              <text x="900" y="310" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">GitHub</text>
              <text x="900" y="335" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">Enterprise</text>
              
              {/* Azure DevBox */}
              <rect x="1100" y="280" width="200" height="80" rx="15" fill="#1a73e8" />
              <text x="1200" y="310" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">Azure</text>
              <text x="1200" y="335" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill="white">DevBox</text>
            </g>
            
            {/* Defense-in-Depth Layers with Better Spacing */}
            <g id="defense-layers">
              {/* Identity Layer */}
              <rect x="100" y="420" width="1400" height="180" rx="15" fill="#e6f7ff" stroke={COLORS.AZURE_BLUE} strokeWidth="3" />
              <text x="800" y="455" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Identity and Access Management
              </text>
              
              {/* Network Layer */}
              <rect x="100" y="620" width="1400" height="180" rx="15" fill="#fff4e6" stroke={COLORS.ORANGE} strokeWidth="3" />
              <text x="800" y="655" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                Network Security
              </text>
              
              {/* Platform Layer */}
              <rect x="100" y="820" width="1400" height="180" rx="15" fill="#f0eeff" stroke={COLORS.PURPLE} strokeWidth="3" />
              <text x="800" y="855" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold" fill={COLORS.PURPLE}>
                Platform Security
              </text>
              
              {/* Data Layer */}
              <rect x="100" y="1020" width="1400" height="180" rx="15" fill="#f0fff0" stroke={COLORS.GREEN} strokeWidth="3" />
              <text x="800" y="1055" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Data Security
              </text>
              
              {/* Monitoring Layer */}
              <rect x="100" y="1220" width="1400" height="180" rx="15" fill="#fff0f0" stroke={COLORS.RED} strokeWidth="3" />
              <text x="800" y="1255" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold" fill={COLORS.RED}>
                Monitoring and Auditing
              </text>
            </g>
            
            {/* Identity Layer Components - Properly Spaced */}
            <g id="identity-components">
              <rect x="150" y="490" width="280" height="80" rx="12" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="2" />
              <text x="290" y="515" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Microsoft Entra ID
              </text>
              <text x="290" y="535" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Enterprise Identity Provider</text>
              <text x="290" y="555" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: DevBox Auth
              </text>
              
              <rect x="480" y="490" width="280" height="80" rx="12" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="2" />
              <text x="620" y="515" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Managed Identities
              </text>
              <text x="620" y="535" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Service Authentication</text>
              <text x="620" y="555" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Local Testing
              </text>
              
              <rect x="810" y="490" width="280" height="80" rx="12" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="2" />
              <text x="950" y="515" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Workload Identity
              </text>
              <text x="950" y="535" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Kubernetes Authentication</text>
              <text x="950" y="555" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Pod Identity
              </text>
              
              <rect x="1140" y="490" width="280" height="80" rx="12" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="2" />
              <text x="1280" y="515" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Multi-Factor Auth
              </text>
              <text x="1280" y="535" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Conditional Access</text>
              <text x="1280" y="555" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: IDE Integration
              </text>
            </g>
            
            {/* Network Layer Components - Properly Spaced */}
            <g id="network-components">
              <rect x="150" y="690" width="280" height="80" rx="12" fill="white" stroke={COLORS.ORANGE} strokeWidth="2" />
              <text x="290" y="715" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                NSGs / Azure Firewall
              </text>
              <text x="290" y="735" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Network Filtering</text>
              <text x="290" y="755" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Dev Network Isolation
              </text>
              
              <rect x="480" y="690" width="280" height="80" rx="12" fill="white" stroke={COLORS.ORANGE} strokeWidth="2" />
              <text x="620" y="715" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                Private Endpoints
              </text>
              <text x="620" y="735" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Service Isolation</text>
              <text x="620" y="755" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Local Service Mesh
              </text>
              
              <rect x="810" y="690" width="280" height="80" rx="12" fill="white" stroke={COLORS.ORANGE} strokeWidth="2" />
              <text x="950" y="715" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                Network Policies
              </text>
              <text x="950" y="735" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Kubernetes Network</text>
              <text x="950" y="755" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Policy Testing
              </text>
              
              <rect x="1140" y="690" width="280" height="80" rx="12" fill="white" stroke={COLORS.ORANGE} strokeWidth="2" />
              <text x="1280" y="715" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                TLS/mTLS Encryption
              </text>
              <text x="1280" y="735" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">End-to-End Security</text>
              <text x="1280" y="755" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Cert Management
              </text>
            </g>
            
            {/* Platform Layer Components - Properly Spaced */}
            <g id="platform-components">
              <rect x="150" y="890" width="280" height="80" rx="12" fill="white" stroke={COLORS.PURPLE} strokeWidth="2" />
              <text x="290" y="915" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.PURPLE}>
                AKS/ARO Security
              </text>
              <text x="290" y="935" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Container Platform</text>
              <text x="290" y="955" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Local K8s Testing
              </text>
              
              <rect x="480" y="890" width="280" height="80" rx="12" fill="white" stroke={COLORS.PURPLE} strokeWidth="2" />
              <text x="620" y="915" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.PURPLE}>
                Kubernetes RBAC
              </text>
              <text x="620" y="935" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Pod Security Standards</text>
              <text x="620" y="955" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: RBAC Templates
              </text>
              
              <rect x="810" y="890" width="280" height="80" rx="12" fill="white" stroke={COLORS.PURPLE} strokeWidth="2" />
              <text x="950" y="915" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.PURPLE}>
                GitHub Advanced Security
              </text>
              <text x="950" y="935" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">AI-powered Code Analysis</text>
              <text x="950" y="955" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: IDE Scanning
              </text>
              
              <rect x="1140" y="890" width="280" height="80" rx="12" fill="white" stroke={COLORS.PURPLE} strokeWidth="2" />
              <text x="1280" y="915" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.PURPLE}>
                OPA/Gatekeeper
              </text>
              <text x="1280" y="935" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Policy as Code</text>
              <text x="1280" y="955" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Policy Validation
              </text>
            </g>
            
            {/* Data Layer Components - Properly Spaced */}
            <g id="data-components">
              <rect x="150" y="1090" width="280" height="80" rx="12" fill="white" stroke={COLORS.GREEN} strokeWidth="2" />
              <text x="290" y="1115" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Azure Key Vault
              </text>
              <text x="290" y="1135" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Secrets & Certificates</text>
              <text x="290" y="1155" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Dev Secrets
              </text>
              
              <rect x="480" y="1090" width="280" height="80" rx="12" fill="white" stroke={COLORS.GREEN} strokeWidth="2" />
              <text x="620" y="1115" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Encrypted Storage
              </text>
              <text x="620" y="1135" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Data at Rest</text>
              <text x="620" y="1155" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Encryption SDK
              </text>
              
              <rect x="810" y="1090" width="280" height="80" rx="12" fill="white" stroke={COLORS.GREEN} strokeWidth="2" />
              <text x="950" y="1115" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Container Registry
              </text>
              <text x="950" y="1135" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Image Vulnerability Scanning</text>
              <text x="950" y="1155" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Build Scanning
              </text>
              
              <rect x="1140" y="1090" width="280" height="80" rx="12" fill="white" stroke={COLORS.GREEN} strokeWidth="2" />
              <text x="1280" y="1115" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Data Classification
              </text>
              <text x="1280" y="1135" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Microsoft Purview</text>
              <text x="1280" y="1155" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Data Labeling
              </text>
            </g>
            
            {/* Monitoring Layer Components - Properly Spaced */}
            <g id="monitoring-components">
              <rect x="150" y="1290" width="280" height="80" rx="12" fill="white" stroke={COLORS.RED} strokeWidth="2" />
              <text x="290" y="1315" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.RED}>
                Azure Monitor
              </text>
              <text x="290" y="1335" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Log Analytics & KQL</text>
              <text x="290" y="1355" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Dev Telemetry
              </text>
              
              <rect x="480" y="1290" width="280" height="80" rx="12" fill="white" stroke={COLORS.RED} strokeWidth="2" />
              <text x="620" y="1315" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.RED}>
                Prometheus/Grafana
              </text>
              <text x="620" y="1335" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Metrics & Alerts</text>
              <text x="620" y="1355" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Local Dashboards
              </text>
              
              <rect x="810" y="1290" width="280" height="80" rx="12" fill="white" stroke={COLORS.RED} strokeWidth="2" />
              <text x="950" y="1315" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.RED}>
                Microsoft Defender
              </text>
              <text x="950" y="1335" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">Cloud Security Posture</text>
              <text x="950" y="1355" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Security Alerts
              </text>
              
              <rect x="1140" y="1290" width="280" height="80" rx="12" fill="white" stroke={COLORS.RED} strokeWidth="2" />
              <text x="1280" y="1315" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold" fill={COLORS.RED}>
                Microsoft Sentinel
              </text>
              <text x="1280" y="1335" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fill="#666">SIEM/SOAR Operations</text>
              <text x="1280" y="1355" fontFamily="Arial, sans-serif" fontSize="11" textAnchor="middle" fill={COLORS.SHIFT_LEFT_GREEN} fontWeight="bold">
                Shift-Left: Threat Modeling
              </text>
            </g>
            
            {/* Connecting arrows from platform components */}
            <g id="connecting-arrows" stroke="#999999" strokeWidth="2" fill="#999999" strokeDasharray="5,5">
              {/* From platform components to layers */}
              <path d="M 300,360 L 300,420" markerEnd="url(#arrowhead)" />
              <path d="M 600,360 L 600,420" markerEnd="url(#arrowhead)" />
              <path d="M 900,360 L 900,420" markerEnd="url(#arrowhead)" />
              <path d="M 1200,360 L 1200,420" markerEnd="url(#arrowhead)" />
              
              {/* Between layers */}
              <path d="M 800,600 L 800,620" markerEnd="url(#arrowhead)" />
              <path d="M 800,800 L 800,820" markerEnd="url(#arrowhead)" />
              <path d="M 800,1000 L 800,1020" markerEnd="url(#arrowhead)" />
              <path d="M 800,1200 L 800,1220" markerEnd="url(#arrowhead)" />
            </g>
            
            {/* Arrow marker definition */}
            <defs>
              <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
                <polygon points="0 0, 10 3.5, 0 7" fill="#999999" />
              </marker>
              <marker id="shift-arrow" markerWidth="15" markerHeight="10" refX="14" refY="5" orient="auto">
                <polygon points="0 0, 15 5, 0 10" fill={COLORS.SHIFT_LEFT_GREEN} />
              </marker>
            </defs>
            
            {/* Legend - Updated Position */}
            <g id="legend">
              <rect x="1350" y="380" width="220" height="160" rx="8" fill="white" stroke="#333333" strokeWidth="1" opacity="0.95" />
              <text x="1460" y="405" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle" fontWeight="bold">Security Layers</text>
              
              <circle cx="1370" cy="425" r="7" fill={COLORS.AZURE_BLUE} />
              <text x="1385" y="430" fontFamily="Arial, sans-serif" fontSize="12">Identity & Access</text>
              
              <circle cx="1370" cy="450" r="7" fill={COLORS.ORANGE} />
              <text x="1385" y="455" fontFamily="Arial, sans-serif" fontSize="12">Network Security</text>
              
              <circle cx="1370" cy="475" r="7" fill={COLORS.PURPLE} />
              <text x="1385" y="480" fontFamily="Arial, sans-serif" fontSize="12">Platform Security</text>
              
              <circle cx="1370" cy="500" r="7" fill={COLORS.GREEN} />
              <text x="1385" y="505" fontFamily="Arial, sans-serif" fontSize="12">Data Security</text>
              
              <circle cx="1370" cy="525" r="7" fill={COLORS.RED} />
              <text x="1385" y="530" fontFamily="Arial, sans-serif" fontSize="12">Monitoring</text>
            </g>
            
            {/* Compliance Labels - Better Positioned */}
            <g id="compliance">
              <text x="50" y="250" fontFamily="Arial, sans-serif" fontSize="14" fontWeight="bold" fill="#333">Compliance Standards:</text>
              
              <rect x="200" y="235" width="90" height="30" rx="15" fill={COLORS.HIGHLIGHT_YELLOW} />
              <text x="245" y="254" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fontWeight="bold">PCI DSS</text>
              
              <rect x="300" y="235" width="90" height="30" rx="15" fill={COLORS.HIGHLIGHT_BLUE} />
              <text x="345" y="254" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fontWeight="bold" fill="white">HIPAA</text>
              
              <rect x="400" y="235" width="90" height="30" rx="15" fill={COLORS.HIGHLIGHT_PURPLE} />
              <text x="445" y="254" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fontWeight="bold" fill="white">SOC2</text>
              
              <rect x="500" y="235" width="90" height="30" rx="15" fill="#28a745" />
              <text x="545" y="254" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle" fontWeight="bold" fill="white">GDPR</text>
            </g>
            
            {/* Security Boundaries */}
            <g id="security-boundaries">
              <rect x="80" y="400" width="1440" height="1000" rx="20" fill="none" stroke="#333333" strokeWidth="4" strokeDasharray="10,5" />
              <text x="800" y="390" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill="#333">
                Enterprise Security Perimeter
              </text>
            </g>
          </svg>
        </div>
        
        <p className="text-center text-gray-600 mb-8">
          <strong>Figure 1</strong>: Three Horizons AI Platform Security Architecture - Defense-in-Depth Implementation with Shift-Left Approach
        </p>
        
        {/* Shift-Left Security Flow Diagram */}
        <div className="w-full mb-8 bg-white rounded-lg shadow-lg p-4">
          <h2 className="text-2xl font-bold mb-4 text-gray-800">Shift-Left Security Flow</h2>
          
          <svg width="100%" height="800" viewBox="0 0 1200 800" xmlns="http://www.w3.org/2000/svg">
            <rect width="1200" height="800" fill="#ffffff" />
            
            {/* Title */}
            <text x="600" y="30" fontFamily="Arial, sans-serif" fontSize="24" textAnchor="middle" fontWeight="bold">
              Shift-Left Security: Developer-First Approach
            </text>
            
            {/* Development Phases */}
            <g id="phases">
              {/* Phase Labels */}
              <text x="150" y="80" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                DEVELOP
              </text>
              <text x="400" y="80" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                BUILD
              </text>
              <text x="650" y="80" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                TEST
              </text>
              <text x="900" y="80" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                DEPLOY
              </text>
              <text x="1100" y="80" fontFamily="Arial, sans-serif" fontSize="18" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                OPERATE
              </text>
              
              {/* Phase Flow */}
              <path d="M 50,100 L 1150,100" stroke={COLORS.SHIFT_LEFT_GREEN} strokeWidth="4" markerEnd="url(#flow-arrow)" />
            </g>
            
            {/* Security Activities per Phase */}
            <g id="security-activities">
              {/* Develop Phase */}
              <rect x="50" y="140" width="200" height="300" rx="10" fill="#f0f9ff" stroke={COLORS.AZURE_BLUE} strokeWidth="2" />
              <text x="150" y="165" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Dev Security
              </text>
              
              <rect x="70" y="180" width="160" height="40" rx="5" fill="white" stroke={COLORS.GITHUB_PURPLE} strokeWidth="1" />
              <text x="150" y="200" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">GitHub Copilot</text>
              <text x="150" y="212" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">AI Code Review</text>
              
              <rect x="70" y="230" width="160" height="40" rx="5" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="1" />
              <text x="150" y="250" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Azure DevBox</text>
              <text x="150" y="262" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Secure IDE</text>
              
              <rect x="70" y="280" width="160" height="40" rx="5" fill="white" stroke={COLORS.GREEN} strokeWidth="1" />
              <text x="150" y="300" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Secret Scanning</text>
              <text x="150" y="312" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Pre-commit Hooks</text>
              
              <rect x="70" y="330" width="160" height="40" rx="5" fill="white" stroke={COLORS.PURPLE} strokeWidth="1" />
              <text x="150" y="350" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">SAST/IDE</text>
              <text x="150" y="362" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Real-time Analysis</text>
              
              <rect x="70" y="380" width="160" height="40" rx="5" fill="white" stroke={COLORS.ORANGE} strokeWidth="1" />
              <text x="150" y="400" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Policy Validation</text>
              <text x="150" y="412" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">OPA Testing</text>
              
              {/* Build Phase */}
              <rect x="300" y="140" width="200" height="300" rx="10" fill="#fff4e6" stroke={COLORS.ORANGE} strokeWidth="2" />
              <text x="400" y="165" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                Build Security
              </text>
              
              <rect x="320" y="180" width="160" height="40" rx="5" fill="white" stroke={COLORS.GITHUB_PURPLE} strokeWidth="1" />
              <text x="400" y="200" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">GitHub Actions</text>
              <text x="400" y="212" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Security Gates</text>
              
              <rect x="320" y="230" width="160" height="40" rx="5" fill="white" stroke={COLORS.GREEN} strokeWidth="1" />
              <text x="400" y="250" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Dependency Scan</text>
              <text x="400" y="262" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Supply Chain</text>
              
              <rect x="320" y="280" width="160" height="40" rx="5" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="1" />
              <text x="400" y="300" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Container Scan</text>
              <text x="400" y="312" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Image Security</text>
              
              <rect x="320" y="330" width="160" height="40" rx="5" fill="white" stroke={COLORS.PURPLE} strokeWidth="1" />
              <text x="400" y="350" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Code Signing</text>
              <text x="400" y="362" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Integrity Check</text>
              
              <rect x="320" y="380" width="160" height="40" rx="5" fill="white" stroke={COLORS.RED} strokeWidth="1" />
              <text x="400" y="400" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Build Attestation</text>
              <text x="400" y="412" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">SBOM Generation</text>
              
              {/* Test Phase */}
              <rect x="550" y="140" width="200" height="300" rx="10" fill="#f0fff0" stroke={COLORS.GREEN} strokeWidth="2" />
              <text x="650" y="165" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Test Security
              </text>
              
              <rect x="570" y="180" width="160" height="40" rx="5" fill="white" stroke={COLORS.PURPLE} strokeWidth="1" />
              <text x="650" y="200" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">DAST Testing</text>
              <text x="650" y="212" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Dynamic Analysis</text>
              
              <rect x="570" y="230" width="160" height="40" rx="5" fill="white" stroke={COLORS.RED} strokeWidth="1" />
              <text x="650" y="250" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Penetration Test</text>
              <text x="650" y="262" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">AI-Assisted</text>
              
              <rect x="570" y="280" width="160" height="40" rx="5" fill="white" stroke={COLORS.ORANGE} strokeWidth="1" />
              <text x="650" y="300" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Compliance Check</text>
              <text x="650" y="312" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Policy Validation</text>
              
              <rect x="570" y="330" width="160" height="40" rx="5" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="1" />
              <text x="650" y="350" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Security Posture</text>
              <text x="650" y="362" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Risk Assessment</text>
              
              <rect x="570" y="380" width="160" height="40" rx="5" fill="white" stroke={COLORS.GREEN} strokeWidth="1" />
              <text x="650" y="400" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Chaos Testing</text>
              <text x="650" y="412" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Resilience Check</text>
              
              {/* Deploy Phase */}
              <rect x="800" y="140" width="200" height="300" rx="10" fill="#f0eeff" stroke={COLORS.PURPLE} strokeWidth="2" />
              <text x="900" y="165" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.PURPLE}>
                Deploy Security
              </text>
              
              <rect x="820" y="180" width="160" height="40" rx="5" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="1" />
              <text x="900" y="200" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">AKS/ARO Deploy</text>
              <text x="900" y="212" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Secure Clusters</text>
              
              <rect x="820" y="230" width="160" height="40" rx="5" fill="white" stroke={COLORS.PURPLE} strokeWidth="1" />
              <text x="900" y="250" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Admission Control</text>
              <text x="900" y="262" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Gatekeeper/OPA</text>
              
              <rect x="820" y="280" width="160" height="40" rx="5" fill="white" stroke={COLORS.ORANGE} strokeWidth="1" />
              <text x="900" y="300" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Network Policies</text>
              <text x="900" y="312" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Zero Trust</text>
              
              <rect x="820" y="330" width="160" height="40" rx="5" fill="white" stroke={COLORS.GREEN} strokeWidth="1" />
              <text x="900" y="350" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Secret Injection</text>
              <text x="900" y="362" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Key Vault CSI</text>
              
              <rect x="820" y="380" width="160" height="40" rx="5" fill="white" stroke={COLORS.RED} strokeWidth="1" />
              <text x="900" y="400" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Deployment Verify</text>
              <text x="900" y="412" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Security Baseline</text>
              
              {/* Operate Phase */}
              <rect x="1050" y="140" width="200" height="300" rx="10" fill="#fff0f0" stroke={COLORS.RED} strokeWidth="2" />
              <text x="1150" y="165" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.RED}>
                Runtime Security
              </text>
              
              <rect x="1070" y="180" width="160" height="40" rx="5" fill="white" stroke={COLORS.RED} strokeWidth="1" />
              <text x="1150" y="200" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Sentinel SIEM</text>
              <text x="1150" y="212" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">AI-Powered SOC</text>
              
              <rect x="1070" y="230" width="160" height="40" rx="5" fill="white" stroke={COLORS.PURPLE} strokeWidth="1" />
              <text x="1150" y="250" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Defender CSPM</text>
              <text x="1150" y="262" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Threat Protection</text>
              
              <rect x="1070" y="280" width="160" height="40" rx="5" fill="white" stroke={COLORS.ORANGE} strokeWidth="1" />
              <text x="1150" y="300" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Runtime Policies</text>
              <text x="1150" y="312" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Falco/Sysdig</text>
              
              <rect x="1070" y="330" width="160" height="40" rx="5" fill="white" stroke={COLORS.AZURE_BLUE} strokeWidth="1" />
              <text x="1150" y="350" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Incident Response</text>
              <text x="1150" y="362" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Automated SOAR</text>
              
              <rect x="1070" y="380" width="160" height="40" rx="5" fill="white" stroke={COLORS.GREEN} strokeWidth="1" />
              <text x="1150" y="400" fontFamily="Arial, sans-serif" fontSize="12" textAnchor="middle">Compliance Audit</text>
              <text x="1150" y="412" fontFamily="Arial, sans-serif" fontSize="10" textAnchor="middle" fill="#666">Continuous</text>
            </g>
            
            {/* Feedback Loop */}
            <g id="feedback-loop">
              <path d="M 1150,450 Q 1200,500 1150,550 Q 1100,600 600,600 Q 100,600 50,550 Q 0,500 50,450" 
                    fill="none" stroke={COLORS.SHIFT_LEFT_GREEN} strokeWidth="3" strokeDasharray="10,5" markerEnd="url(#flow-arrow)" />
              <text x="600" y="620" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.SHIFT_LEFT_GREEN}>
                Continuous Security Feedback Loop
              </text>
            </g>
            
            {/* Security Metrics */}
            <g id="metrics">
              <rect x="50" y="680" width="300" height="100" rx="10" fill="#e6f7ff" stroke={COLORS.AZURE_BLUE} strokeWidth="2" />
              <text x="200" y="705" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.AZURE_BLUE}>
                Security Metrics
              </text>
              <text x="200" y="730" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">90% Issues Found in Dev</text>
              <text x="200" y="750" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">75% Reduction in Prod Vulnerabilities</text>
              <text x="200" y="770" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">60% Faster Security Remediation</text>
              
              <rect x="400" y="680" width="300" height="100" rx="10" fill="#fff4e6" stroke={COLORS.ORANGE} strokeWidth="2" />
              <text x="550" y="705" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.ORANGE}>
                Cost Savings
              </text>
              <text x="550" y="730" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">10x Cheaper to Fix in Dev</text>
              <text x="550" y="750" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">50% Reduction in Security Debt</text>
              <text x="550" y="770" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">30% Less Security Incidents</text>
              
              <rect x="750" y="680" width="300" height="100" rx="10" fill="#f0fff0" stroke={COLORS.GREEN} strokeWidth="2" />
              <text x="900" y="705" fontFamily="Arial, sans-serif" fontSize="16" textAnchor="middle" fontWeight="bold" fill={COLORS.GREEN}>
                Developer Experience
              </text>
              <text x="900" y="730" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">Real-time Security Feedback</text>
              <text x="900" y="750" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">Integrated IDE Security</text>
              <text x="900" y="770" fontFamily="Arial, sans-serif" fontSize="14" textAnchor="middle">AI-Assisted Remediation</text>
            </g>
            
            {/* Arrow marker for flow diagram */}
            <defs>
              <marker id="flow-arrow" markerWidth="15" markerHeight="10" refX="14" refY="5" orient="auto">
                <polygon points="0 0, 15 5, 0 10" fill={COLORS.SHIFT_LEFT_GREEN} />
              </marker>
            </defs>
          </svg>
        </div>
        
        <p className="text-center text-gray-600 mb-8">
          <strong>Figure 2</strong>: Shift-Left Security Flow showing developer-first security integration across all phases
        </p>
        
        {/* Key Features Section */}
        <div className="mt-8 bg-gray-50 rounded-lg p-6">
          <h2 className="text-2xl font-bold mb-4 text-gray-800">Key Security Implementation Features</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="bg-white rounded-lg p-4 shadow">
              <h3 className="text-lg font-bold mb-2 text-blue-600">Zero Trust Architecture</h3>
              <ul className="list-disc list-inside text-gray-700">
                <li>Never Trust, Always Verify</li>
                <li>Least Privilege Access</li>
                <li>Continuous Verification</li>
                <li>Microsegmentation</li>
              </ul>
            </div>
            
            <div className="bg-white rounded-lg p-4 shadow">
              <h3 className="text-lg font-bold mb-2 text-green-600">Shift-Left Security</h3>
              <ul className="list-disc list-inside text-gray-700">
                <li>IDE Security Integration</li>
                <li>Pre-commit Security Hooks</li>
                <li>AI-Powered Code Review</li>
                <li>DevBox Secure Environments</li>
              </ul>
            </div>
            
            <div className="bg-white rounded-lg p-4 shadow">
              <h3 className="text-lg font-bold mb-2 text-purple-600">AI-Enhanced Security</h3>
              <ul className="list-disc list-inside text-gray-700">
                <li>GitHub Copilot Security</li>
                <li>Azure AI Threat Detection</li>
                <li>Automated Compliance</li>
                <li>Agentic Security Ops</li>
              </ul>
            </div>
            
            <div className="bg-white rounded-lg p-4 shadow">
              <h3 className="text-lg font-bold mb-2 text-orange-600">Compliance & Governance</h3>
              <ul className="list-disc list-inside text-gray-700">
                <li>Built-in Compliance Controls</li>
                <li>Comprehensive Audit Trails</li>
                <li>Policy as Code</li>
                <li>Responsible AI Governance</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ThreeHorizonsSecurityArchitecture;