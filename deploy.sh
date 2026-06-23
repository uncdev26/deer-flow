#!/usr/bin/env bash
# deploy.sh — Deploy DeerFlow to Railway via CLI
#
# Prerequisites:
#   1. Install: curl -fsSL agents.railway.com | sh
#   2. Login:   railway login
#   3. Link:    railway link  (select your project)
#
# Usage:
#   ./deploy.sh              # Show setup instructions
#   ./deploy.sh backend      # Deploy backend service
#   ./deploy.sh frontend     # Deploy frontend service
#   ./deploy.sh all          # Deploy both services

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[deploy]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC} $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; }

check_deps() {
    if ! command -v railway &>/dev/null; then
        err "Railway CLI not found. Install: curl -fsSL agents.railway.com | sh"
        exit 1
    fi
    if ! railway whoami &>/dev/null; then
        err "Not logged in. Run: railway login"
        exit 1
    fi
    log "Logged in as: $(railway whoami 2>/dev/null)"
}

deploy_backend() {
    log "Deploying backend..."
    railway up --service deerflow-backend
    log "Backend deployed."
}

deploy_frontend() {
    log "Deploying frontend..."
    railway up --service deerflow-frontend
    log "Frontend deployed."
}

show_setup() {
    cat <<'EOF'

  DeerFlow Railway — Setup Instructions
  ======================================

  1. In Railway dashboard, create 2 services from this repo:

     Service 1: deerflow-backend
       Root Directory: /backend
       Railway reads backend/railway.json automatically

     Service 2: deerflow-frontend
       Root Directory: /frontend
       Railway reads frontend/railway.json automatically

  2. Set environment variables:

     Backend:
       MIMO_API_KEY=***   GATEWAY_CORS_ORIGINS=https://your-frontend.up.railway.app

     Frontend:
       NEXT_PUBLIC_BACKEND_BASE_URL=https://your-backend.up.railway.app
       NEXT_PUBLIC_LANGGRAPH_BASE_URL=https://your-backend.up.railway.app/api
       DEER_FLOW_INTERNAL_GATEWAY_BASE_URL=https://your-backend.up.railway.app

  3. Generate domains for both services

  4. Deploy: ./deploy.sh all

EOF
}

check_deps

case "${1:-setup}" in
    setup)    show_setup ;;
    backend)  deploy_backend ;;
    frontend) deploy_frontend ;;
    all)      deploy_backend; deploy_frontend; log "Done!" ;;
    *)        echo "Usage: $0 [setup|backend|frontend|all]"; exit 1 ;;
esac
