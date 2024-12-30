# 数据结构与算法 - 第5周：高级算法专题

## 1. 字符串算法

### 1.1 KMP算法
用于字符串匹配的高效算法。

```javascript
class KMP {
    // 构建部分匹配表
    static buildPMT(pattern) {
        const pmt = [0];
        let len = 0;
        let i = 1;
        
        while (i < pattern.length) {
            if (pattern[i] === pattern[len]) {
                len++;
                pmt[i] = len;
                i++;
            } else {
                if (len > 0) {
                    len = pmt[len - 1];
                } else {
                    pmt[i] = 0;
                    i++;
                }
            }
        }
        
        return pmt;
    }
    
    // KMP搜索
    static search(text, pattern) {
        const pmt = this.buildPMT(pattern);
        const matches = [];
        let i = 0;  // text指针
        let j = 0;  // pattern指针
        
        while (i < text.length) {
            if (text[i] === pattern[j]) {
                i++;
                j++;
            }
            
            if (j === pattern.length) {
                matches.push(i - j);
                j = pmt[j - 1];
            } else if (i < text.length && text[i] !== pattern[j]) {
                if (j > 0) {
                    j = pmt[j - 1];
                } else {
                    i++;
                }
            }
        }
        
        return matches;
    }
}
```

### 1.2 字符串哈希
用于快速字符串比较和查找。

```javascript
class StringHash {
    constructor(str) {
        this.str = str;
        this.base = 131;
        this.mod = 1e9 + 7;
        this.hash = this.calculateHash();
    }
    
    calculateHash() {
        let hash = 0;
        for (let i = 0; i < this.str.length; i++) {
            hash = (hash * this.base + this.str.charCodeAt(i)) % this.mod;
        }
        return hash;
    }
    
    // 子串哈希值
    substringHash(start, end) {
        let hash = 0;
        for (let i = start; i < end; i++) {
            hash = (hash * this.base + this.str.charCodeAt(i)) % this.mod;
        }
        return hash;
    }
}
```

## 2. 高级数据结构

### 2.1 跳表（Skip List）
一种可以用来代替平衡树的数据结构。

```javascript
class SkipListNode {
    constructor(value, level) {
        this.value = value;
        this.forward = new Array(level + 1).fill(null);
    }
}

class SkipList {
    constructor() {
        this.maxLevel = 16;
        this.head = new SkipListNode(-Infinity, this.maxLevel);
        this.level = 0;
    }
    
    randomLevel() {
        let level = 0;
        while (Math.random() < 0.5 && level < this.maxLevel) {
            level++;
        }
        return level;
    }
    
    insert(value) {
        const update = new Array(this.maxLevel + 1).fill(null);
        let current = this.head;
        
        // 从最高层开始查找
        for (let i = this.level; i >= 0; i--) {
            while (current.forward[i] && current.forward[i].value < value) {
                current = current.forward[i];
            }
            update[i] = current;
        }
        
        const level = this.randomLevel();
        if (level > this.level) {
            for (let i = this.level + 1; i <= level; i++) {
                update[i] = this.head;
            }
            this.level = level;
        }
        
        const newNode = new SkipListNode(value, level);
        for (let i = 0; i <= level; i++) {
            newNode.forward[i] = update[i].forward[i];
            update[i].forward[i] = newNode;
        }
    }
}
```

### 2.2 树状数组（Binary Indexed Tree）
用于高效处理数组前缀和的数据结构。

```javascript
class BIT {
    constructor(n) {
        this.tree = new Array(n + 1).fill(0);
    }
    
    // 更新操作
    update(index, delta) {
        while (index < this.tree.length) {
            this.tree[index] += delta;
            index += index & -index;  // 获取下一个需要更新的位置
        }
    }
    
    // 查询前缀和
    query(index) {
        let sum = 0;
        while (index > 0) {
            sum += this.tree[index];
            index -= index & -index;  // 获取前一个需要查询的位置
        }
        return sum;
    }
    
    // 区间查询
    rangeQuery(left, right) {
        return this.query(right) - this.query(left - 1);
    }
}
```

## 3. 高级算法技巧

### 3.1 双指针技巧
用于解决数组、链表等线性结构的问题。

```javascript
class TwoPointers {
    // 寻找数组中的两数之和
    static findTwoSum(arr, target) {
        let left = 0;
        let right = arr.length - 1;
        
        while (left < right) {
            const sum = arr[left] + arr[right];
            if (sum === target) {
                return [left, right];
            } else if (sum < target) {
                left++;
            } else {
                right--;
            }
        }
        
        return null;
    }
    
    // 判断回文字符串
    static isPalindrome(str) {
        let left = 0;
        let right = str.length - 1;
        
        while (left < right) {
            if (str[left] !== str[right]) {
                return false;
            }
            left++;
            right--;
        }
        
        return true;
    }
}
```

### 3.2 滑动窗口
处理子数组或子字符串问题的通用方法。

```javascript
class SlidingWindow {
    // 找出最长无重复字符子串
    static longestSubstring(str) {
        const seen = new Map();
        let start = 0;
        let maxLength = 0;
        
        for (let end = 0; end < str.length; end++) {
            if (seen.has(str[end])) {
                start = Math.max(start, seen.get(str[end]) + 1);
            }
            seen.set(str[end], end);
            maxLength = Math.max(maxLength, end - start + 1);
        }
        
        return maxLength;
    }
    
    // 固定大小窗口的最大和
    static maxSumSubarray(arr, k) {
        let sum = 0;
        let maxSum = 0;
        
        // 初始窗口
        for (let i = 0; i < k; i++) {
            sum += arr[i];
        }
        maxSum = sum;
        
        // 滑动窗口
        for (let i = k; i < arr.length; i++) {
            sum = sum - arr[i - k] + arr[i];
            maxSum = Math.max(maxSum, sum);
        }
        
        return maxSum;
    }
}
```

## 4. 高级应用场景

### 4.1 数据压缩
```javascript
class Compression {
    // 游程编码
    static runLengthEncode(str) {
        let result = '';
        let count = 1;
        
        for (let i = 1; i <= str.length; i++) {
            if (i === str.length || str[i] !== str[i-1]) {
                result += str[i-1] + count;
                count = 1;
            } else {
                count++;
            }
        }
        
        return result;
    }
    
    // Huffman编码（简化版）
    static huffmanEncode(str) {
        // 计算频率
        const freq = new Map();
        for (const char of str) {
            freq.set(char, (freq.get(char) || 0) + 1);
        }
        
        // 构建Huffman树（简化版）
        const codes = new Map();
        // ... 构建Huffman树的代码 ...
        
        return codes;
    }
}
```

## 5. 算法优化技巧

### 5.1 性能优化
1. **时间优化**
   - 使用合适的数据结构
   - 避免重复计算
   - 空间换时间

2. **空间优化**
   - 原地算法
   - 变量复用
   - 位运算优化

### 5.2 代码质量
1. **可读性**
   - 清晰的变量命名
   - 适当的注释
   - 模块化设计

2. **可维护性**
   - 单一职责原则
   - 错误处理
   - 边界条件检查

## 6. 练习题推荐
1. [最小覆盖子串](https://leetcode.cn/problems/minimum-window-substring/) - 滑动窗口
2. [接雨水](https://leetcode.cn/problems/trapping-rain-water/) - 双指针
3. [LRU缓存](https://leetcode.cn/problems/lru-cache/) - 高级数据结构
4. [字符串匹配](https://leetcode.cn/problems/implement-strstr/) - KMP算法 