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
        uint256 ProductTokenId;
        address ProductOwner;
        uint256 ProductPrice;
    }
    Product[] private ProductList;
    function appendProduct(uint256 _tokenId, uint256 _dollar) internal{
        Product memory temp;
        temp.ProductTokenId = _tokenId;
        temp.ProductOwner = msg.sender;
        temp.ProductPrice = _dollar;
        ProductList.push(temp);
    }
    function deleteProduct(uint256 _index) internal{
        uint256 Arraylength = ProductList.length;
        require(Arraylength > _index, "Out of bounds!!!");
        ProductList[_index].ProductTokenId =  ProductList[Arraylength-1].ProductTokenId;
        ProductList[_index].ProductOwner =  ProductList[Arraylength-1].ProductOwner; 
        ProductList[_index].ProductPrice =  ProductList[Arraylength-1].ProductPrice;
        ProductList.pop(); 
    }
    function getIndexOfProduct(uint256 _tokenId) internal view returns(uint256){
        Product[] memory temp = ProductList;
        for(uint256 i = 0; i < temp.length; i++){
            if(temp[i].ProductTokenId == _tokenId)
                return i;
        }
        revert("Not found the _tokenId");
    }
    function itemsList() external view returns(Product[] memory){
        return ProductList;
    }
    function appendItems(uint256 _tokenId, uint256 _dollar) external{
        _ERC721(addrERC721).transferFrom(msg.sender, address(this), _tokenId);
        appendProduct(_tokenId, _dollar);
    }
    function deleteItems(uint256 _tokenId) external{
        Product[] memory temp = ProductList;
        uint256 index = getIndexOfProduct(_tokenId);
        require(temp[index].ProductOwner == msg.sender, "You aren't the owner!!!");
        _ERC721(addrERC721).transferFrom(address(this), msg.sender, _tokenId);
        deleteProduct(index);
    }
    function purchaseItems(uint256 _tokenId) external{
        Product[] memory temp = ProductList;
        uint256 index = getIndexOfProduct(_tokenId);
        _ERC20(addrERC20).transferFrom(msg.sender, address(this), temp[index].ProductPrice);
        _ERC721(addrERC721).transferFrom(address(this), msg.sender, _tokenId);
        _ERC20(addrERC20).transfer(temp[index].ProductOwner, temp[index].ProductPrice);
        deleteProduct(index);
    }
}