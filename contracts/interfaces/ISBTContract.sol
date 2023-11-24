pragma solidity ^0.8.20;

interface ISBTContract {
    function getTotalSupply() external view returns(uint);
    function getSeller() external view returns(address);
    function setSeller(address _seller) external;
    function testMint(address to) external;
    function testBurn(uint256 tokenId) external;
}