// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
// import "@maticnetwork/pos-portal/contracts/tunnel/BaseChildTunnel.sol";
import "../polygon/tunnel/BaseChildTunnel.sol";
import "./L2_PolygonBridge.sol";

contract L2_PolygonMessengerProxy is BaseChildTunnel, ReentrancyGuard {

    address public l2Bridge;
    address public polygonMessenger;
    address public xDomainMessageSender;

    address constant public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    modifier onlyL2Bridge {
        require(msg.sender == l2Bridge, "L2_PLGN_MSG: Sender must be the L2 Bridge");
        _;
    }

    constructor(
        address _l2Bridge,
        address _polygonMessenger
    ) public {
        l2Bridge = _l2Bridge;
        polygonMessenger = _polygonMessenger;
        xDomainMessageSender = DEAD_ADDRESS;
    }

    function sendCrossDomainMessage(bytes memory message) external onlyL2Bridge {
        _sendMessageToRoot(message);
    }

    function _processMessageFromRoot(bytes memory data) internal override nonReentrant {
        (address sender, bytes memory message) = abi.decode(data, (address, bytes));
        xDomainMessageSender = sender;
        (bool success,) = l2Bridge.call(message);
        require(success, "L2_PLGN_MSG: Failed to proxy message");
        xDomainMessageSender = DEAD_ADDRESS;
    }
}