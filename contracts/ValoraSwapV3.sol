// SPDX-License-Identifier: Apache-2.0
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {Pausable} from '@openzeppelin/contracts/utils/Pausable.sol';
import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Ownable2Step} from '@openzeppelin/contracts/access/Ownable2Step.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Constants} from './Constants.sol';
import {SwapHandler} from './SwapHandler.sol';

contract ValoraSwapV3 is Pausable, Ownable2Step {
  using SafeERC20 for IERC20;

  address payable public immutable FEE_WALLET;
  SwapHandler public immutable SWAP_HANDLER;

  event SwapFromReferral(
    uint256 fee,
    address referrer
  );

  constructor(
    address initialOwner,
    address payable feeWallet
  ) Ownable(initialOwner) {
    FEE_WALLET = feeWallet;
    SWAP_HANDLER = new SwapHandler();
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  function swap(
    string calldata fromNetworkId,
    IERC20 fromToken,
    uint256 fromAmount, // Excluding the fee
    string calldata toNetworkId,
    IERC20 toToken,
    address target,
    bytes calldata data,
    uint256 fee,
    address referrer
  ) external payable whenNotPaused {
    if (fromToken != Constants.NATIVE_TOKEN) {
      fromToken.safeTransferFrom(
        msg.sender,
        address(SWAP_HANDLER),
        fromAmount + fee
      );
    }

    // Swap via the handler contract
    SWAP_HANDLER.swap{value: msg.value}(
      msg.sender,
      fromNetworkId,
      fromToken,
      fromAmount,
      toNetworkId,
      toToken,
      target,
      data,
      FEE_WALLET,
      fee
    );
    emit SwapFromReferral(fee, referrer);
  }
}