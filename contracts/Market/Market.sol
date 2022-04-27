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
    address AddrERC721 = 0x0fC5025C764cE34df352757e82f7B5c4Df39A836;
    address AddrERC20 = 0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c;
    struct Product{
        uint256 ProductTokenId;
        address ProductOwner;
        uint256 ProductDollar;
    }
    Product[] private ProductList;
    function setOnProductList(uint256 _tokenId, uint256 _dollar) internal{
        Product memory temp;
        temp.ProductTokenId = _tokenId;
        temp.ProductOwner = msg.sender;
        temp.ProductDollar = _dollar;
        ProductList.push(temp);
    }
    function deleteProductList(uint256 _index) internal{
        uint256 Arraylength = ProductList.length;
        require(Arraylength > _index, "Out of bounds!!!");
        ProductList[_index].ProductTokenId =  ProductList[Arraylength-1].ProductTokenId;
        ProductList[_index].ProductOwner =  ProductList[Arraylength-1].ProductOwner; 
        ProductList[_index].ProductDollar =  ProductList[Arraylength-1].ProductDollar;
        ProductList.pop(); 
    }
    function getOnProductList(uint256 _tokenId) internal view returns(uint256){
        for(uint256 i = 0; i < ProductList.length; i++){
            if(ProductList[i].ProductTokenId == _tokenId)
                return ProductList[i].ProductDollar;
        }
        revert("Not found the _tokenId");
    }
    function getOnProductListOwner(uint256 _tokenId) internal view returns(address){
        for(uint256 i = 0; i < ProductList.length; i++){
            if(ProductList[i].ProductTokenId == _tokenId)
                return ProductList[i].ProductOwner;
        }
        revert("Not found the _tokenId");
    }
    function getOnProductListNumber(uint256 _tokenId) internal view returns(uint256){
        for(uint256 i = 0; i < ProductList.length; i++){
            if(ProductList[i].ProductTokenId == _tokenId)
                return i;
        }
        revert("Not found the _tokenId");
    }
    function itemsList() external view returns(Product[] memory){
        return ProductList;
    }
    function appendItems(uint256 _tokenId, uint256 _dollar) external{
        _ERC721(AddrERC721).transferFrom(msg.sender, address(this), _tokenId);
        setOnProductList(_tokenId, _dollar);
    }
    function deleteItems(uint256 _tokenId) external{
        uint256 index = getOnProductListNumber(_tokenId);
        require(getOnProductListOwner(_tokenId) == msg.sender, "You aren't the owner!!!");
        _ERC721(AddrERC721).transferFrom(address(this), msg.sender, _tokenId);
        deleteProductList(index);
    }
    function purchaseItems(uint256 _tokenId) external{
        uint256 cost = getOnProductList(_tokenId);
        _ERC20(AddrERC20).transferFrom(msg.sender, address(this), cost);
        _ERC721(AddrERC721).transferFrom(address(this), msg.sender, _tokenId);
        address seller = getOnProductListOwner(_tokenId);
        _ERC20(AddrERC20).transfer(seller, cost);
        uint256 index = getOnProductListNumber(_tokenId);
       deleteProductList(index);
    }
}