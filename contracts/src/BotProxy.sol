// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BotProxy
 * @dev EIP-1167 minimal proxy wrapper for trading bot instances
 * 
 * Minimal proxy bytecode (~45 bytes) that delegates all calls to implementation
 * while maintaining state at the proxy address
 */

contract BotProxy {
    // Implementation slot for proxy pattern
    bytes32 internal constant IMPLEMENTATION_SLOT = 
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    constructor(address _implementation) {
        _setImplementation(_implementation);
    }
    
    fallback() external payable {
        address impl = _implementation();
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            returndatacopy(ptr, 0, returndatasize())
            switch result
            case 0 { revert(ptr, returndatasize()) }
            default { return(ptr, returndatasize()) }
        }
    }
    
    receive() external payable {}
    
    function _setImplementation(address _impl) internal {
        require(_impl.code.length > 0, "Invalid implementation");
        assembly {
            sstore(IMPLEMENTATION_SLOT, _impl)
        }
    }
    
    function _implementation() internal view returns (address impl) {
        assembly {
            impl := sload(IMPLEMENTATION_SLOT)
        }
    }
}
