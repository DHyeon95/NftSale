// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import './ERC721/ERC721.sol';
import './IERC5484.sol';

// OpenZeppelin Contracts (v5.0.0)
// OwnerOnly : 소각권리가 Owner 있는것 가정.

abstract contract ERC5484 is ERC721, IERC5484 {

    mapping(uint256 => BurnAuth) private burnAuthState;

    /// @notice check burn authorization of the token id
    /// @dev BurnAuth invalid, reverted
    /// @param tokenId The ID of the token
    /// @param spender _msgSender()
    modifier _checkBurnAuth(uint tokenId, address spender) virtual {
        require(burnAuthState[tokenId] != BurnAuth.Neither, 'Invaild burn state');
        require(spender == _ownerOf(tokenId), 'Invaild User');
        _;
    }

    /// @notice Issued token
    /// @dev Mints using the _safeMint embedded in 721, sets burnAuth. Emits the Issued event.
    /// @param to The receiver
    /// @param tokenId The ID of the token
    function _mintSBT(address to, uint256 tokenId, BurnAuth state) internal virtual {
        _safeMint(to, tokenId, '');
        burnAuthState[tokenId] = state ;
        emit Issued(msg.sender, to, tokenId, state);
    }

    function _burnSBT(uint tokenId) internal virtual _checkBurnAuth(tokenId, _msgSender()) {
        _burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721) returns (bool) {
        return interfaceId == type(IERC5484).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function burnAuth(uint256 tokenId) public view override returns (BurnAuth) {
        _requireOwned(tokenId);
        return burnAuthState[tokenId];
    }

    function transferFrom(address, address, uint256) public override {
        revert('Transfer is not allowed');
    }
}