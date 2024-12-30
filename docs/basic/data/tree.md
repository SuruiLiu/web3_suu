# 数据结构与算法 - 第2周：树结构

## 树的基本概念解释

### B树和B+树
B树和B+树都是多路搜索树，主要用于数据库和文件系统中的索引。

#### B树特点：
- 所有叶子节点都在同一层
- 每个节点可以存储多个关键字
- 节点的关键字从小到大排序
- 每个关键字对应一个子树
- 所有节点（包括内部节点）都可以存储数据

#### B+树特点：
- 只有叶子节点存储数据
- 叶子节点通过链表连接
- 内部节点只存储索引
- 更适合范围查询
- 常用于数据库索引

**应用场景**：
- B树：适合随机查询
- B+树：适合范围查询和顺序访问

### 前缀树（Trie树）
前缀树是一种特殊的树形数据结构，主要用于字符串的快速检索。

#### 特点：
- 根节点不包含字符
- 从根节点到某一节点的路径上的字符连接起来，为该节点对应的字符串
- 每个节点的所有子节点包含的字符都不相同

**应用场景**：
- 自动补全
- 拼写检查
- 字符串搜索
- IP路由表查找

### 并查集（Union-Find）
并查集是一种树形数据结构，用于处理一些不相交集合的合并及查询问题。

#### 特点：
- 支持两种操作：合并（Union）和查找（Find）
- 可以快速判断两个元素是否属于同一集合
- 使用路径压缩和按秩合并来优化性能

**应用场景**：
- 网络连接问题
- 社交网络中的朋友圈
- 最小生成树算法
- 判断图中的环

### 表达式树
表达式树是一种用于表示数学表达式的二叉树。

#### 特点：
- 叶子节点是操作数
- 内部节点是运算符
- 可以方便地进行表达式求值
- 支持中缀、前缀、后缀表达式的转换

**应用场景**：
- 计算器实现
- 编译器表达式求值
- 数学表达式处理

### 决策树
决策树是一种用于决策过程的树形结构。

#### 特点：
- 每个内部节点表示一个判断条件
- 每个叶子节点表示一个决策结果
- 从根到叶的路径表示决策规则

**应用场景**：
- 机器学习分类算法
- 游戏AI决策
- 专家系统

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

#### B树实现
```javascript
class BTreeNode {
    constructor(isLeaf = true, t) {
        this.isLeaf = isLeaf;
        this.t = t;              // 最小度数
        this.keys = [];          // 关键字数组
        this.children = [];      // 子节点数组
        this.n = 0;             // 当前关键字数量
    }
}

class BTree {
    constructor(t) {
        this.root = null;
        this.t = t;  // 最小度数
    }
    
    // 分裂子节点
    splitChild(parent, index, child) {
        const newNode = new BTreeNode(child.isLeaf, this.t);
        newNode.n = this.t - 1;
        
        // 复制后半部分的关键字到新节点
        for (let j = 0; j < this.t - 1; j++) {
            newNode.keys[j] = child.keys[j + this.t];
        }
        
        // 如果不是叶子节点，复制后半部分的子节点
        if (!child.isLeaf) {
            for (let j = 0; j < this.t; j++) {
                newNode.children[j] = child.children[j + this.t];
            }
        }
        
        child.n = this.t - 1;
        
        // 在父节点中插入新的子节点
        for (let j = parent.n; j >= index + 1; j--) {
            parent.children[j + 1] = parent.children[j];
        }
        
        parent.children[index + 1] = newNode;
        
        // 在父节点中插入中间的关键字
        for (let j = parent.n - 1; j >= index; j--) {
            parent.keys[j + 1] = parent.keys[j];
        }
        
        parent.keys[index] = child.keys[this.t - 1];
        parent.n = parent.n + 1;
    }
    
    // 插入关键字
    insert(k) {
        if (!this.root) {
            this.root = new BTreeNode(true, this.t);
            this.root.keys[0] = k;
            this.root.n = 1;
            return;
        }
        
        if (this.root.n === 2 * this.t - 1) {
            const newRoot = new BTreeNode(false, this.t);
            newRoot.children[0] = this.root;
            this.splitChild(newRoot, 0, this.root);
            this.root = newRoot;
            this.insertNonFull(this.root, k);
        } else {
            this.insertNonFull(this.root, k);
        }
    }
}
```

#### B+树实现
```javascript
class BPlusTreeNode {
    constructor(isLeaf = true) {
        this.isLeaf = isLeaf;
        this.keys = [];
        this.children = [];
        this.next = null;      // 叶子节点链表
    }
}

class BPlusTree {
    constructor(order) {
        this.root = new BPlusTreeNode();
        this.order = order;    // B+树的阶数
    }
    
    // 查找关键字
    search(key) {
        let node = this.root;
        
        while (!node.isLeaf) {
            let i = 0;
            while (i < node.keys.length && key >= node.keys[i]) {
                i++;
            }
            node = node.children[i];
        }
        
        // 在叶子节点中查找
        for (let i = 0; i < node.keys.length; i++) {
            if (node.keys[i] === key) {
                return node.children[i];  // 返回对应的数据
            }
        }
        
        return null;
    }
    
    // 范围查询
    rangeSearch(start, end) {
        let node = this.root;
        let result = [];
        
        // 找到起始叶子节点
        while (!node.isLeaf) {
            let i = 0;
            while (i < node.keys.length && start >= node.keys[i]) {
                i++;
            }
            node = node.children[i];
        }
        
        // 收集范围内的数据
        while (node) {
            for (let i = 0; i < node.keys.length; i++) {
                if (node.keys[i] >= start && node.keys[i] <= end) {
                    result.push(node.children[i]);
                }
                if (node.keys[i] > end) {
                    return result;
                }
            }
            node = node.next;
        }
        
        return result;
    }
}
```

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

## 7. 树的应用场景

### 7.1 表达式树
```javascript
class ExpressionNode {
    constructor(val) {
        this.val = val;
        this.left = null;
        this.right = null;
    }
}

class ExpressionTree {
    constructor() {
        this.root = null;
    }
    
    // 构建表达式树
    buildFromPostfix(postfix) {
        const stack = [];
        const operators = new Set(['+', '-', '*', '/']);
        
        for (const token of postfix) {
            const node = new ExpressionNode(token);
            
            if (operators.has(token)) {
                node.right = stack.pop();
                node.left = stack.pop();
            }
            
            stack.push(node);
        }
        
        this.root = stack.pop();
    }
    
    // 计算表达式结果
    evaluate(node = this.root) {
        if (!node) return 0;
        
        if (!isNaN(node.val)) return parseFloat(node.val);
        
        const left = this.evaluate(node.left);
        const right = this.evaluate(node.right);
        
        switch (node.val) {
            case '+': return left + right;
            case '-': return left - right;
            case '*': return left * right;
            case '/': return left / right;
        }
    }
}
```

### 7.2 决策树
```javascript
class DecisionNode {
    constructor(condition, trueAction, falseAction) {
        this.condition = condition;
        this.trueNode = null;
        this.falseNode = null;
        this.trueAction = trueAction;
        this.falseAction = falseAction;
    }
}

class DecisionTree {
    constructor() {
        this.root = null;
    }
    
    // 执行决策
    makeDecision(data) {
        let current = this.root;
        
        while (current) {
            if (current.condition(data)) {
                if (current.trueNode) {
                    current = current.trueNode;
                } else {
                    return current.trueAction;
                }
            } else {
                if (current.falseNode) {
                    current = current.falseNode;
                } else {
                    return current.falseAction;
                }
            }
        }
    }
}
```

## 8. 总结与最佳实践

### 8.1 树的选择指南
1. **二叉搜索树**：适用于需要快速查找、插入、删除的场景
2. **AVL树**：需要严格平衡的场景
3. **红黑树**：需要自平衡但允许部分不平衡的场景
4. **B树/B+树**：适用于磁盘存储和数据库索引
5. **Trie树**：适用于字符串前缀匹配和搜索
6. **并查集**：适用于动态连通性问题

### 8.2 常见问题解决方案
1. **树的遍历**：根据需求选择合适的遍历方式
   - 需要按顺序处理节点：中序遍历
   - 需要复制/序列化树：前序遍历
   - 需要删除树：后序遍历
   - 需要逐层处理：层序遍历

2. **树的构建**：
   - 从数组构建：使用递归或迭代
   - 从遍历序列构建：利用遍历特性
   - 动态构建：注意平衡性

3. **树的修改**：
   - 保持平衡性
   - 正确处理节点连接
   - 考虑边界情况

### 8.3 性能优化建议
1. 选择合适的树结构
2. 合理使用递归和迭代
3. 注意内存使用
4. 适当的平衡维护
5. 缓存常用数据

## 学习建议
1. 掌握树的基本概念和遍历方式
2. 理解不同树结构的特点和应用场景
3. 多练习递归和迭代的实现方式
4. 注意边界条件的处理
5. 学会分析时间和空间复杂度
6. 结合实际应用场景选择合适的树结构 

## 树的详细解释与实例

### 1. B树和B+树详解

#### B树（B-tree）
B树是一种自平衡的搜索树，允许每个节点存储多个键值。

**特点示例**：
```
           [10, 20]
          /    |    \
    [5,8]   [15]   [30,35]
```

**实际应用**：
1. 文件系统：
```
/home
  ├── user1
  │   ├── docs
  │   └── photos
  └── user2
      └── downloads
```

2. 数据库索引：
```sql
CREATE INDEX idx_name ON users(name);
-- 会创建一个B树索引结构
```

#### B+树
B+树是B树的变种，所有数据都存储在叶子节点。

**结构示例**：
```
           [10, 20]           // 索引节点
          /    |    \
    [5,8] [15,18] [25,30]    // 叶子节点（数据）
    ↔      ↔       ↔         // 叶子节点链表
```

**使用场景**：
```sql
-- 范围查询效率高
SELECT * FROM users 
WHERE age BETWEEN 20 AND 30;
```

### 2. 前缀树（Trie）详解

**结构示例**：
存储 "cat", "car", "dog" 的前缀树：
```
       root
      /    \
     c      d
    /        \
   a          o
  / \          \
 t   r          g
(*) (*)        (*)
```

**实际应用示例**：
```javascript
// 自动补全功能
const trie = new Trie();
trie.insert("cat");
trie.insert("car");
trie.insert("card");

// 输入"ca"时可以提示：
// - cat
// - car
// - card
```

### 3. 并查集（Union-Find）详解

**场景示例**：社交网络中的朋友关系
```javascript
// 初始状态：每个人是独立的集合
A B C D E

// 添加朋友关系
union(A, B)  // A-B
union(C, D)  // C-D
union(B, C)  // A-B-C-D

// 现在的结构
    A
    |
    B
    |
    C
    |
    D    E
```

**实际应用**：
```javascript
// 判断两个人是否是朋友
const uf = new UnionFind(5);  // 5个人
uf.union(0, 1);  // 0和1是朋友
uf.union(1, 2);  // 1和2是朋友

console.log(uf.find(0) === uf.find(2));  // true，0和2是朋友
console.log(uf.find(0) === uf.find(4));  // false，0和4不是朋友
```

### 4. 表达式树详解

**示例**：表达式 "3 + 4 * 2" 的树结构
```
     +
    / \
   3   *
      / \
     4   2
```

**计算过程**：
```javascript
// 后序遍历计算
4 * 2 = 8
3 + 8 = 11
```

### 5. 决策树详解

**实例**：简单的游戏AI决策
```
                是否有敌人？
                /          \
               是          否
              /            \
        血量>50%？        寻找资源
        /        \
    攻击        逃跑
```

**代码示例**：
```javascript
const gameAI = new DecisionTree();
gameAI.root = new DecisionNode(
    (state) => state.hasEnemy,
    (state) => state.health > 50 
        ? "attack" 
        : "retreat",
    "searchResources"
);

// 使用
const action = gameAI.makeDecision({
    hasEnemy: true,
    health: 75
}); // 返回 "attack"
```

### 6. 各种树的对比

| 树类型 | 查找时间 | 插入时间 | 主要应用 | 特点 |
|-------|---------|---------|---------|------|
| 二叉搜索树 | O(h) | O(h) | 基础搜索 | 简单但可能不平衡 |
| B树 | O(log n) | O(log n) | 文件系统 | 多路搜索，适合磁盘 |
| B+树 | O(log n) | O(log n) | 数据库索引 | 顺序访问快 |
| Trie | O(m) | O(m) | 字符串查找 | m为字符串长度 |
| 红黑树 | O(log n) | O(log n) | 系统应用 | 自平衡 |

[原文内容继续...] 