# 数据结构与算法 - 第2周：树结构

## 1. 树的基本概念
- **定义**: 由节点和边组成的分层数据结构
- **特点**:
  - 有一个根节点
  - 每个节点可以有多个子节点
  - 没有环路
  - 任意两个节点间有且仅有一条路径

## 2. 二叉树的实现与遍历
```javascript
// 二叉树节点定义
class TreeNode {
    constructor(val) {
        this.val = val;
        this.left = null;
        this.right = null;
    }
}

// 二叉树基本操作
class BinaryTree {
    constructor() {
        this.root = null;
    }
    
    // 四种遍历方式
    // 1. 前序遍历
    preorder(node = this.root) {
        if (!node) return [];
        return [node.val, ...this.preorder(node.left), ...this.preorder(node.right)];
    }
    
    // 2. 中序遍历
    inorder(node = this.root) {
        if (!node) return [];
        return [...this.inorder(node.left), node.val, ...this.inorder(node.right)];
    }
    
    // 3. 后序遍历
    postorder(node = this.root) {
        if (!node) return [];
        return [...this.postorder(node.left), ...this.postorder(node.right), node.val];
    }
    
    // 4. 层序遍历
    levelOrder() {
        if (!this.root) return [];
        
        const result = [];
        const queue = [this.root];
        
        while (queue.length) {
            const level = [];
            const levelSize = queue.length;
            
            for (let i = 0; i < levelSize; i++) {
                const node = queue.shift();
                level.push(node.val);
                
                if (node.left) queue.push(node.left);
                if (node.right) queue.push(node.right);
            }
            
            result.push(level);
        }
        
        return result;
    }
}
```

## 3. 二叉搜索树(BST)
```javascript
class BST {
    constructor() {
        this.root = null;
    }
    
    // 插入节点
    insert(val) {
        const newNode = new TreeNode(val);
        
        if (!this.root) {
            this.root = newNode;
            return;
        }
        
        let current = this.root;
        while (true) {
            if (val < current.val) {
                if (!current.left) {
                    current.left = newNode;
                    return;
                }
                current = current.left;
            } else {
                if (!current.right) {
                    current.right = newNode;
                    return;
                }
                current = current.right;
            }
        }
    }
    
    // 查找节点
    search(val) {
        let current = this.root;
        
        while (current) {
            if (val === current.val) return true;
            if (val < current.val) current = current.left;
            else current = current.right;
        }
        
        return false;
    }
}
```

## 4. 经典问题

### 4.1 验证二叉搜索树
```javascript
function isValidBST(root) {
    function validate(node, min, max) {
        if (!node) return true;
        
        if (node.val <= min || node.val >= max) {
            return false;
        }
        
        return validate(node.left, min, node.val) && 
               validate(node.right, node.val, max);
    }
    
    return validate(root, -Infinity, Infinity);
}
```

### 4.2 最近公共祖先
```javascript
function lowestCommonAncestor(root, p, q) {
    if (!root || root === p || root === q) return root;
    
    const left = lowestCommonAncestor(root.left, p, q);
    const right = lowestCommonAncestor(root.right, p, q);
    
    if (!left) return right;  // p和q都在右子树
    if (!right) return left;  // p和q都在左子树
    return root;              // p和q分别在左右子树
}
```

### 4.3 路径和
```javascript
function hasPathSum(root, targetSum) {
    if (!root) return false;
    
    if (!root.left && !root.right) {
        return root.val === targetSum;
    }
    
    return hasPathSum(root.left, targetSum - root.val) ||
           hasPathSum(root.right, targetSum - root.val);
}
```

## 5. 高级树结构

### 5.1 B树和B+树
[这里可以放B树和B+树的详细实现，之前已经写过了]

### 5.2 Trie树（前缀树）
```javascript
class TrieNode {
    constructor() {
        this.children = {};
        this.isEndOfWord = false;
    }
}

class Trie {
    constructor() {
        this.root = new TrieNode();
    }
    
    insert(word) {
        let current = this.root;
        for (const char of word) {
            if (!current.children[char]) {
                current.children[char] = new TrieNode();
            }
            current = current.children[char];
        }
        current.isEndOfWord = true;
    }
    
    search(word) {
        const node = this._searchNode(word);
        return node !== null && node.isEndOfWord;
    }
    
    startsWith(prefix) {
        return this._searchNode(prefix) !== null;
    }
}
```

### 5.3 并查集
```javascript
class UnionFind {
    constructor(size) {
        this.parent = new Array(size);
        this.rank = new Array(size);
        
        for (let i = 0; i < size; i++) {
            this.parent[i] = i;
            this.rank[i] = 0;
        }
    }
    
    find(x) {
        if (this.parent[x] !== x) {
            this.parent[x] = this.find(this.parent[x]);
        }
        return this.parent[x];
    }
    
    union(x, y) {
        let rootX = this.find(x);
        let rootY = this.find(y);
        
        if (rootX !== rootY) {
            if (this.rank[rootX] < this.rank[rootY]) {
                [rootX, rootY] = [rootY, rootX];
            }
            this.parent[rootY] = rootX;
            if (this.rank[rootX] === this.rank[rootY]) {
                this.rank[rootX]++;
            }
        }
    }
}
```

## 6. 实践项目：文件系统目录结构
[这里可以放文件系统目录结构的实现，之前已经写过了]

## 学习建议
1. 掌握树的基本概念和遍历方式
2. 理解二叉搜索树的特性和基本操作
3. 熟练掌握树的常见算法问题
4. 了解高级树结构的应用场景
5. 多做练习，特别是递归相关的问题 