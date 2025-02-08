repo:https://github.com/Cyfrin/2025-01-pieces-protocol

首先看框架：
├── src
│   ├── TokenDivider.sol
│   └── token
│       └── ERC20ToGenerateNftFraccion.sol

看功能：
一个marketplace用户能够买nft的碎片并且交易
拥有某一nft所有碎片的用户能够声明锁住这个nft

ERC20ToGenerateNftFraccion：：
标准ERC20

TokenDivider：
divideNft(address nftAddress, uint256 tokenId, uint256 amount)把NFT传进来生成对应的erc20，但是先mint给了这个contract再转给user
claimNft(address nftAddress)这里只要balance>=mint的erc20，就能burn然后把nft转给自己
transferErcTokens(address nftAddress,address to, uint256 amount)把erc20转给别人
sellErc20(address nftPegged, uint256 price,uint256 amount)创建售卖erc20的订单
buyOrder(uint256 orderIndex, address seller)买erc20


vulnerabilities：
H:
1. uint256 fee = order.price / 100;
        uint256 sellerFee = fee / 2;这个计算是不对的，order的价格如果小于100那么fee就是0
2. transferErcTokens(address nftAddress,address to, uint256 amount)好像有被抢跑的可能 Invalid
3. mint(address _to, uint256 _amount) public这个public肯定是巨大bug
4. 如果故意或意外把erc20传给这个contract就能造成stuck和Dos，这个NFT也就不能被claim不能取出来了
5. mapping(address nft => ERC20Info) nftToErc20Info;如果同一系列的nft不同id，那就乱套了，因为这里没有区分不同id的办法
6. 比较有争议的一个bug，就是没办法取消sell，因为没有办法撤回和修改price
7. 抢跑问题
- 1. Array-Based Order Tracking (基于数组的订单追踪)
描述：
s_userToSellOrders[seller] 是一个存储卖家出售订单的数组。
当卖家创建一个新订单时，它被直接 追加到数组末尾。
当某个订单被买家购买时，合约通过以下操作删除该订单：
用数组中最后一个元素覆盖要删除的订单位置。
调用 .pop() 来移除最后一个重复的订单。
问题：
这种操作可能 改变订单的顺序。例如，假设数组 [orderA, orderB, orderC] 中 orderB 被购买，那么合约会将 orderC 移动到 orderB 的位置，结果变成 [orderA, orderC]。
- 2. Front-Running Attack (抢先交易攻击)
场景：
假设 index=0 上的订单以 1 ETH 出售 10 份代币。
index=1 上的订单只出售 1 份代币，但价格同样是 1 ETH（即价格明显不合理）。
攻击过程：
买家发送交易请求购买 index=0 的订单。
卖家 抢先交易（Front-Running）：
在同一个区块中，卖家自己通过另一笔交易购买 index=0 的订单。
数组删除操作触发，将 index=1 的无价值订单移动到 index=0。
结果：买家的交易虽然成功，但由于订单索引变化，买家实际买到的不是原本的订单，而是价格不合理的“垃圾订单”（1 个代币卖 1 ETH）。

M：
1. 没有授权minterc20的NFT能够直接发送到这个contract，然后就被锁住了，拿不出来了

L：
1. uint256 fee = order.price / 100;
        uint256 sellerFee = fee / 2;这个计算是不对的，order的价格如果小于100那么fee就是0
2. buyorder没有处理好还钱的问题，如果支付少了买不了，支付多了又没有归还多余钱财的机制
