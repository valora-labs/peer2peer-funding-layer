// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {ECDSA} from '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import {MessageHashUtils} from '@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol';

error AlreadyClaimed();
error InvalidSignature();
error InvalidSender();
error InvalidIndexOrBeneficiary();
error InvalidAmount();

using ECDSA for bytes32;
using MessageHashUtils for bytes32;

contract WalletJumpstartHack {
  struct ERC20Claim {
    IERC20 token;
    address depositor;
    uint256 amount;
    bool claimed;
  }

  struct ERC721Claim {
    IERC721 token;
    address depositor;
    uint256 tokenId;
    bool claimed;
  }

  mapping(address => address) public referrer;
  mapping(address => ERC20Claim[]) public erc20Claims;
  mapping(address => ERC721Claim[]) public erc721Claims;

  event ERC20Deposited(
    address indexed depositor,
    address indexed beneficiary,
    IERC20 indexed token,
    uint256 amount,
    uint256 index
  );
  event ERC721Deposited(
    address indexed depositor,
    address indexed beneficiary,
    IERC721 indexed token,
    uint256 tokenId,
    uint256 index
  );
  event ERC20Claimed(
    address indexed beneficiary,
    address sentTo,
    IERC20 indexed token,
    uint256 amount
  );
  event ERC721Claimed(
    address indexed beneficiary,
    address sentTo,
    IERC721 indexed token,
    uint256 tokenId
  );
  event ERC20Reclaimed(
    address indexed beneficiary,
    address sentTo,
    IERC20 indexed token,
    uint256 amount
  );
  event ERC721Reclaimed(
    address indexed beneficiary,
    address sentTo,
    IERC721 indexed token,
    uint256 tokenId
  );

  function depositERC20(
    address beneficiary,
    IERC20 token,
    uint256 amount
  ) external {
    if (amount == 0) {
      revert InvalidAmount();
    }
    token.transferFrom(msg.sender, address(this), amount);
    erc20Claims[beneficiary].push(ERC20Claim(token, msg.sender, amount, false));
    emit ERC20Deposited(
      msg.sender,
      beneficiary,
      token,
      amount,
      erc20Claims[beneficiary].length - 1
    );
  }

  function depositERC721(
    address beneficiary,
    IERC721 token,
    uint256 tokenId
  ) external {
    token.transferFrom(msg.sender, address(this), tokenId);
    erc721Claims[beneficiary].push(
      ERC721Claim(token, msg.sender, tokenId, false)
    );
    emit ERC721Deposited(
      msg.sender,
      beneficiary,
      token,
      tokenId,
      erc721Claims[beneficiary].length - 1
    );
  }

  function claimERC20(
    uint256 index,
    address beneficiary,
    bytes memory signature,
    address sendTo
  ) external {
    if (index >= erc20Claims[beneficiary].length) {
      revert InvalidIndexOrBeneficiary();
    }

    ERC20Claim storage claim = erc20Claims[beneficiary][index];
    if (claim.claimed) {
      revert AlreadyClaimed();
    }

    bytes32 hash = keccak256(abi.encodePacked(beneficiary, sendTo, index));
    address signer = hash.toEthSignedMessageHash().recover(signature);
    if (beneficiary != signer) {
      revert InvalidSignature();
    }

    claim.claimed = true;
    claim.token.transfer(sendTo, claim.amount);
    if (referrer[sendTo] == address(0)) {
      referrer[sendTo] = claim.depositor;
    }
    emit ERC20Claimed(beneficiary, sendTo, claim.token, claim.amount);
  }

  function claimERC721(
    uint256 index,
    address beneficiary,
    bytes memory signature,
    address sendTo
  ) external {
    if (index >= erc721Claims[beneficiary].length) {
      revert InvalidIndexOrBeneficiary();
    }

    ERC721Claim storage claim = erc721Claims[beneficiary][index];
    if (claim.claimed) {
      revert AlreadyClaimed();
    }

    bytes32 hash = keccak256(abi.encodePacked(beneficiary, sendTo, index));
    address signer = hash.toEthSignedMessageHash().recover(signature);
    if (beneficiary != signer) {
      revert InvalidSignature();
    }

    claim.claimed = true;
    claim.token.transferFrom(address(this), sendTo, claim.tokenId);
    emit ERC721Claimed(beneficiary, sendTo, claim.token, claim.tokenId);
  }

  function reclaimERC20(address beneficiary, uint256 index) external {
    if (index >= erc20Claims[beneficiary].length) {
      revert InvalidIndexOrBeneficiary();
    }

    ERC20Claim storage claim = erc20Claims[beneficiary][index];
    if (claim.depositor != msg.sender) {
      revert InvalidSender();
    }

    if (claim.claimed) {
      revert AlreadyClaimed();
    }

    claim.claimed = true;
    claim.token.transfer(claim.depositor, claim.amount);
    emit ERC20Reclaimed(
      beneficiary,
      claim.depositor,
      claim.token,
      claim.amount
    );
  }

  function reclaimERC721(address beneficiary, uint256 index) external {
    if (index >= erc721Claims[beneficiary].length) {
      revert InvalidIndexOrBeneficiary();
    }

    ERC721Claim storage claim = erc721Claims[beneficiary][index];
    if (claim.depositor != msg.sender) {
      revert InvalidSender();
    }

    if (claim.claimed) {
      revert AlreadyClaimed();
    }

    claim.claimed = true;
    claim.token.transferFrom(address(this), claim.depositor, claim.tokenId);
    emit ERC721Reclaimed(
      beneficiary,
      claim.depositor,
      claim.token,
      claim.tokenId
    );
  }
}