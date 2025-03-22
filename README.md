# FreshMart - Online Supermarket Store

A modern, responsive online supermarket store built with React, TypeScript, and Tailwind CSS, featuring a complete CI/CD pipeline with GitHub Actions, Argo CD, and Kubernetes deployment.

## 📋 Table of Contents

1. [Features](#features)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Local Development](#local-development)
5. [CI/CD Pipeline](#cicd-pipeline)
6. [GitOps with Argo CD](#gitops-with-argo-cd)
7. [Security](#security)
8. [Contributing](#contributing)

## ✨ Features

- 🛒 Shopping cart functionality
- 🔍 Search products
- 📱 Fully responsive design
- 🎯 Category-based shopping
- ⚡ Fast and optimized performance
- 🛍️ Featured products showcase
- 🚀 Automated CI/CD pipeline
- 🔄 GitOps with Argo CD
- 🔒 Security scanning with Trivy
- 🎮 Kubernetes-ready deployment

## 🛠️ Tech Stack

- **Frontend:**
  - React 18
  - TypeScript
  - Tailwind CSS
  - Vite
  - Lucide React (icons)

- **Testing:**
  - Vitest
  - React Testing Library

- **CI/CD:**
  - GitHub Actions
  - Docker
  - Trivy (Security Scanner)
  - GitHub Container Registry (ghcr.io)
  - Argo CD
  - Argo CD Image Updater

- **Deployment:**
  - Kubernetes
  - NGINX

## 📁 Project Structure

```
freshmart/
├── .github/
│   └── workflows/        # GitHub Actions workflow definitions
├── k8s/                  # Kubernetes and Argo CD manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── namespace.yaml
│   ├── application.yaml  # Argo CD application
│   └── image-updater.yaml # Argo CD Image Updater config
├── src/
│   ├── components/       # React components
│   ├── assets/          # Static assets
│   ├── styles/          # CSS styles
│   └── types/           # TypeScript type definitions
├── Dockerfile           # Docker image definition
└── README.md           # Project documentation
```

[Previous sections unchanged until CI/CD Pipeline]

## 🚀 CI/CD Pipeline

Our CI/CD pipeline combines GitHub Actions for CI and Argo CD for CD:

1. **GitHub Actions (CI):**
   - Unit Testing
   - Static Code Analysis
   - Docker Build
   - Security Scanning
   - Container Registry Push

2. **Argo CD (CD):**
   - Automated Deployment
   - GitOps Workflow
   - Image Updates
   - Deployment Synchronization

## 🔄 GitOps with Argo CD

### Prerequisites

1. **Install Argo CD:**
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Install Argo CD Image Updater:**
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
   ```

3. **Access Argo CD UI:**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
   - Get initial password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### Setting up Continuous Delivery

1. **Configure GitHub Container Registry Access:**
   ```bash
   kubectl create secret docker-registry ghcr-credentials \
     -n argocd \
     --docker-server=ghcr.io \
     --docker-username=GITHUB_USERNAME \
     --docker-password=GITHUB_TOKEN
   ```

2. **Apply Argo CD Configuration:**
   ```bash
   # Apply application configuration
   kubectl apply -f k8s/application.yaml

   # Apply image updater configuration
   kubectl apply -f k8s/image-updater.yaml
   kubectl apply -f k8s/image-updater-config.yaml
   ```

3. **Verify Setup:**
   - Check application status in Argo CD UI
   - Verify image updater logs:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater
   ```

### How It Works

1. **Continuous Integration:**
   - GitHub Actions builds and tests the code
   - On success, pushes new image to GitHub Container Registry

2. **Continuous Delivery:**
   - Argo CD monitors the Git repository
   - Automatically syncs Kubernetes manifests
   - Image Updater checks for new images
   - Updates deployment when new images are available

3. **Automated Rollback:**
   - Argo CD detects drift
   - Automatically reverts unauthorized changes
   - Maintains desired state from Git

[Previous sections remain unchanged]