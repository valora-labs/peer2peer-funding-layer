// SPDX-License-Identifier: Apache-2.0
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Address} from '@openzeppelin/contracts/utils/Address.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {Constants} from './Constants.sol';

contract SwapHandler {
  using SafeERC20 for IERC20;
  using Address for address;
  using Address for address payable;
  using Strings for string;

  error UnauthorizedCaller();
  error InsufficientAmount();

  address public immutable DEPLOYER;

  constructor() {
    DEPLOYER = msg.sender;
  }

  // Enable native tokens reception
  receive() external payable {}

  function swap(
    address recipient, // Original msg.sender performing the swap
    string calldata fromNetworkId,
    IERC20 fromToken,
    uint256 fromAmount, // Excluding the fee
    string calldata toNetworkId,
    IERC20 toToken,
    address target,
    bytes calldata data,
    address payable feeWallet,
    uint256 fee
  ) external payable {
    if (msg.sender != DEPLOYER) {
      revert UnauthorizedCaller();
    }

    uint256 value = msg.value;
    if (fromToken != Constants.NATIVE_TOKEN) {
      // Take the fee
      _transfer(fromToken, fee, feeWallet);
      // Allow the target to spend fromToken
      fromToken.forceApprove(target, fromAmount);
    } else {
      if (value < fromAmount + fee) {
        revert InsufficientAmount();
      }
      // Take the fee
      payable(feeWallet).sendValue(fee);
      value -= fee;
    }

    // Do the swap via the target contract
    target.functionCallWithValue(data, value);

    // Transfer remaining balance of fromToken to the recipient
    if (fromToken != Constants.NATIVE_TOKEN) {
      _transfer(fromToken, fromToken.balanceOf(address(this)), recipient);
    }

    // Transfer remaining balance of toToken to the recipient
    if (toToken != Constants.NATIVE_TOKEN) {
      if (toNetworkId.equal(fromNetworkId)) {
        _transfer(toToken, toToken.balanceOf(address(this)), recipient);
      }
    }

    // If there are unused native tokens, transfer to the recipient
    uint256 nativeBalance = address(this).balance;
    if (nativeBalance > 0) {
      payable(recipient).sendValue(nativeBalance);
    }
  }

  function _transfer(IERC20 token, uint256 amount, address recipient) internal {
    if (amount > 0) {
      token.safeTransfer(recipient, amount);
    }
  }
}