//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;



import "./TRC20.sol";
import "./TRC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple TRC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `TRC20` functions.
 */
contract YXJL is TRC20, TRC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public TRC20Detailed("USLX", "USLX", 6) {
        _mint(msg.sender, 60000000000000000 * (10 ** uint256(decimals())));
    }
}
