#!/usr/bin/env python3

import subprocess
import json
import re

def parse_gas_report():
    """Parse Forge gas report and analyze"""
    
    result = subprocess.run(
        ['forge', 'test', '--gas-report'],
        cwd='./contracts',
        capture_output=True,
        text=True
    )
    
    # Extract gas report from output
    output = result.stdout
    
    # Parse gas data
    tests = {}
    
    # Look for test function gas lines
    pattern = r'(\w+)\s+\d+\s+(\d+)'
    
    for match in re.finditer(pattern, output):
        func_name, gas = match.groups()
        tests[func_name] = int(gas)
    
    # Categorize by severity
    print("📊 Gas Report Analysis\n")
    print("=" * 60)
    
    critical = []  # > 500k
    high = []      # 100k - 500k
    medium = []    # 50k - 100k
    low = []       # < 50k
    
    for func, gas in sorted(tests.items(), key=lambda x: x[1], reverse=True):
        if gas > 500000:
            critical.append((func, gas))
        elif gas > 100000:
            high.append((func, gas))
        elif gas > 50000:
            medium.append((func, gas))
        else:
            low.append((func, gas))
    
    if critical:
        print("\n🔴 CRITICAL (> 500k gas):")
        for func, gas in critical:
            print(f"   {func}: {gas:,} gas")
    
    if high:
        print("\n🟠 HIGH (100k - 500k gas):")
        for func, gas in high[:5]:  # Top 5
            print(f"   {func}: {gas:,} gas")
        if len(high) > 5:
            print(f"   ... and {len(high) - 5} more")
    
    print("\n" + "=" * 60)
    print(f"Total functions analyzed: {len(tests)}")
    
    # Optimization suggestions
    print("\n💡 Optimization Tips:")
    print("   • Use ERC721A for batch minting")
    print("   • Pack storage variables")
    print("   • Use assembly for hot paths")
    print("   • Consider CREATE2 for deployment")
    
if __name__ == '__main__':
    parse_gas_report()
