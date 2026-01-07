#!/bin/bash

# Run all tests for the NFT Trading Bot System
# Usage: ./test-all.sh

set -e

echo "🧪 Running all tests..."

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

FAILED=0

# 1. Smart Contract Tests
echo -e "${BLUE}Testing Smart Contracts...${NC}"
cd contracts
if forge test --gas-report; then
  echo -e "${GREEN}✅ Smart contract tests passed${NC}"
else
  echo -e "${RED}❌ Smart contract tests failed${NC}"
  FAILED=1
fi
cd ..

# 2. Frontend Tests
echo -e "${BLUE}Testing Frontend...${NC}"
cd frontend
if npm run test; then
  echo -e "${GREEN}✅ Frontend tests passed${NC}"
else
  echo -e "${RED}❌ Frontend tests failed${NC}"
  FAILED=1
fi
cd ..

# 3. Backend Tests
echo -e "${BLUE}Testing Backend...${NC}"
cd backend
if npm run test; then
  echo -e "${GREEN}✅ Backend tests passed${NC}"
else
  echo -e "${RED}❌ Backend tests failed${NC}"
  FAILED=1
fi
cd ..

# 4. Subgraph Codegen & Build
echo -e "${BLUE}Building Subgraph...${NC}"
cd subgraph
if npm run codegen && npm run build; then
  echo -e "${GREEN}✅ Subgraph build passed${NC}"
else
  echo -e "${RED}❌ Subgraph build failed${NC}"
  FAILED=1
fi
cd ..

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}🎉 All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}❌ Some tests failed${NC}"
  exit 1
fi
