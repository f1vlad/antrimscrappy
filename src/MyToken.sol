// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/releases/download/v4.9.0/openzeppelin-contracts-4.9.0.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";




contract ANTRIMSCRAPPY2 is ERC20 {
    address[] public holders;
    mapping(address => bool) private isHolder;
    uint256 public constant REWARD_PERCENT = 1;

    constructor(uint256 initialSupply) ERC20("ANTRIMSCRAPPY2", "SCRAPPY2") {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
        _addHolder(msg.sender);
    }

    function _addHolder(address account) internal {
        if (!isHolder[account]) {
            isHolder[account] = true;
            holders.push(account);
        }
    }

    function _randomHolder() internal view returns (address) {
        require(holders.length > 0, "No holders yet");
        uint256 index = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao))
        ) % holders.length;
        return holders[index];
    }

    function _afterTokenTransfer(address from, address to, uint256 amount) internal override {
        super._afterTokenTransfer(from, to, amount);

        // Track new holders
        if (to != address(0)) {
            _addHolder(to);
        }

        // Skip minting reward on mint (from == 0x0)
        if (from == address(0) || holders.length == 0) return;

        uint256 reward = (totalSupply() * REWARD_PERCENT) / 100;
        address lucky = _randomHolder();

        _mint(lucky, reward);
        _addHolder(lucky);
    }
}
