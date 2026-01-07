#!/bin/bash

# Deploy all components of the NFT Trading Bot System
# Usage: ./deploy-all.sh [sepolia|mainnet]

set -e

NETWORK="${1:-sepolia}"

echo "🚀 Deploying NFT Trading Bot System to $NETWORK"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 1. Deploy Smart Contracts
echo -e "${BLUE}1️⃣  Deploying Smart Contracts...${NC}"
cd contracts
forge script script/DeployBotFactory.s.sol:DeployBotFactory \
  --rpc-url "$NETWORK" \
  --broadcast \
  --verify

echo -e "${GREEN}✅ Contracts deployed${NC}"
cd ..

# 2. Deploy Subgraph
echo -e "${BLUE}2️⃣  Deploying Subgraph...${NC}"
cd subgraph
npm run codegen
npm run build
npm run deploy -- studio

echo -e "${GREEN}✅ Subgraph deployed${NC}"
cd ..

# 3. Deploy Frontend
echo -e "${BLUE}3️⃣  Building and deploying Frontend...${NC}"
cd frontend
npm run build

# Deploy to Vercel
vercel deploy --prod

echo -e "${GREEN}✅ Frontend deployed${NC}"
cd ..

# 4. Deploy Backend
echo -e "${BLUE}4️⃣  Deploying Backend...${NC}"
cd backend
npm run build

# Deploy to your infrastructure (e.g., AWS, Railway, Fly.io)
# Example using Railway:
# railway up --detach

echo -e "${GREEN}✅ Backend deployed${NC}"
cd ..

echo -e "${GREEN}🎉 All components deployed successfully!${NC}"
