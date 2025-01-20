记录一些基本步骤：
首先确定scope，确定function大致（参考minimal-onboarding-questions）
静态工具：
cloc： npm install -g cloc
cloc ./src/ 
统计代码数量的

finding layout
### [S-#] TITLE (Root Cause + Impact)

**Description:** 

**Impact:** 

**Proof of Concept:**

**Recommended Mitigation:** 

eg.
## Relevant GitHub Links

<https://github.com/Cyfrin/2025-01-pieces-protocol/blob/4ef5e96fced27334f2a62e388a8a377f97a7f8cb/src/token/ERC20ToGenerateNftFraccion.sol#L15-L17>

## Summary

In the `ERC20ToGenerateNftFraccion.sol` contract, the `mint` function lacks access control mechanisms, allowing any user to call the function and mint arbitrary amounts of tokens. This constitutes a severe security vulnerability.

## Vulnerability Details

The `mint` function:

* Can be called by any external account (`public`).
* Lacks any permission checks (e.g., `onlyOwner` modifier).
* Allows minting of arbitrary amounts of tokens.

This behavior contradicts the business logic of the `TokenDivider.sol` contract, as only the `TokenDivider` contract should have the authority to mint tokens.

## Impact

This vulnerability has catastrophic consequences:

1. **Unrestricted Token Minting:** Attackers can mint unlimited tokens.
2. **Economic Model Breakdown:** The economic model of NFT fractionation is completely compromised.

#### Proof of Concept (PoC):

The exploit can be demonstrated as follows:

```solidity
function testMintingExploit() public {
    // Assume the ERC20ToGenerateNftFraccion contract is deployed
    ERC20ToGenerateNftFraccion token = new ERC20ToGenerateNftFraccion("Test", "TST");
    
    // Any user can mint tokens
    address attacker = address(0x1);
    vm.prank(attacker);
    token.mint(attacker, 1000000 ether);
    
    // Verify the attacker successfully received tokens
    assertEq(token.balanceOf(attacker), 1000000 ether);
}
```

## Tools Used

Manual Review

## Recommendations

Restrict minting permissions so that only the `TokenDivider` contract can mint tokens:

```solidity
contract ERC20ToGenerateNftFraccion is ERC20, ERC20Burnable {
    address public immutable tokenDivider;

    constructor(string memory _name, string memory _symbol, address _tokenDivider) ERC20(_name, _symbol) {
        tokenDivider = _tokenDivider;
    }

    function mint(address _to, uint256 _amount) public {
        require(msg.sender == tokenDivider, "Only TokenDivider can mint");
        _mint(_to, _amount);
    }
}
```

