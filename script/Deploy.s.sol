// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "forge-std/Script.sol";
import "../src/CCTPDirectMessageTest.sol";

/**
 * @title Deploy
 * @dev Deployment script for CCTPDirectMessageTest contract
 * 
 * Usage:
 * forge script script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
 */
contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        CCTPDirectMessageTest testContract = new CCTPDirectMessageTest();
        
        console.log("CCTPDirectMessageTest deployed at:", address(testContract));
        
        vm.stopBroadcast();
    }
}
