// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface _ERC721{
    function approve(address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function createNFT(address player) external;
}

interface _ERC20{
    function transferFrom(address from, address to, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
}
contract Market{
    address addrERC20;
    address addrERC721;
    constructor(address _addrERC20, address _addrERC721){
        addrERC20 = _addrERC20;
        addrERC721 = _addrERC721;
    }
    struct Product{
        uint256 productTokenId;
        address productOwner;
        uint256 productPrice;
    }
    Product[] private productList;
    mapping (address => Product[]) private productListOfOwner;
    function _getIndexFromProductListOfOwner(uint256 _productTokenId) internal view returns(uint256 _index){
        Product[] memory temp = productListOfOwner[msg.sender];
        for(uint256 i = 0; i < temp.length; i++){
            if(_productTokenId == temp[i].productTokenId){
                return i;
            }
        }
    }
    function _appendProduct(uint256 _tokenId, uint256 _price) internal{
        Product memory temp;
        temp.productTokenId = _tokenId;
        temp.productOwner = msg.sender;
        temp.productPrice = _price;
        productList.push(temp);
        productListOfOwner[msg.sender].push(temp);
    }
    function _deleteProduct(uint256 _index) internal{
        uint256 arraylength = productList.length;
        require(arraylength > _index, "Out of bounds!!!");
        uint256 mappingIndex = _getIndexFromProductListOfOwner(productList[_index].productTokenId);
        productListOfOwner[msg.sender][mappingIndex] = productListOfOwner[msg.sender][productListOfOwner[msg.sender].length - 1];
        productListOfOwner[msg.sender].pop();
        productList[_index] =  productList[arraylength-1];
        productList.pop(); 
    }
    function _getIndexFromProduct(uint256 _tokenId) internal view returns(uint256){
        Product[] memory temp = productList;
        for(uint256 i = 0; i < temp.length; i++){
            if(temp[i].productTokenId == _tokenId)
                return i;
        }
        revert("Not found the _tokenId");
    }
    function getProductList() external view returns(Product[] memory){
        return productList;
    }
    function getProductListFromOwner() external view returns(Product[] memory){
        return productListOfOwner[msg.sender];
    }
    function listProduct(uint256 _tokenId, uint256 _price) external{
        _ERC721(addrERC721).transferFrom(msg.sender, address(this), _tokenId);
        _appendProduct(_tokenId, _price);
    }
    function unlistProduct(uint256 _tokenId) external{
        uint256 index = _getIndexFromProduct(_tokenId);
        require(productList[index].productOwner == msg.sender, "You aren't the owner!!!");
        _ERC721(addrERC721).transferFrom(address(this), msg.sender, _tokenId);
        _deleteProduct(index);
    }
    function purchaseProduct(uint256 _tokenId) external{ 
        uint256 index = _getIndexFromProduct(_tokenId);
        Product memory temp = productList[index];
        _ERC20(addrERC20).transferFrom(msg.sender, address(this), temp.productPrice);
        _ERC721(addrERC721).transferFrom(address(this), msg.sender, _tokenId);
        _ERC20(addrERC20).transfer(temp.productOwner, temp.productPrice);
        _deleteProduct(index);
    }
}