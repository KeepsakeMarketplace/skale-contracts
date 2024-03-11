
pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED
interface StargateIERC{
    //20&223
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    //721
    function mint(address account, uint256 tokenId, bytes calldata data) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    //1155
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function mint(address _to, uint256 _id, uint256 _value) external;
    function mint(address _to, uint256[] calldata _ids, uint256[] calldata _values) external;
}
