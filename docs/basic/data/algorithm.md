# 数据结构与算法 - 第4周：算法设计与分析

## 1. 基础算法思想

### 1.1 排序算法

#### 1.1.1 冒泡排序
```javascript
function bubbleSort(arr) {
    const n = arr.length;
    for (let i = 0; i < n - 1; i++) {
        for (let j = 0; j < n - i - 1; j++) {
            if (arr[j] > arr[j + 1]) {
                [arr[j], arr[j + 1]] = [arr[j + 1], arr[j]];
            }
        }
    }
    return arr;
}
```

**特点**：
- 时间复杂度：O(n²)
- 空间复杂度：O(1)
- 稳定排序
- 原地排序

#### 1.1.2 快速排序
```javascript
function quickSort(arr, left = 0, right = arr.length - 1) {
    if (left < right) {
        const pivotIndex = partition(arr, left, right);
        quickSort(arr, left, pivotIndex - 1);
        quickSort(arr, pivotIndex + 1, right);
    }
    return arr;
}

function partition(arr, left, right) {
    const pivot = arr[right];
    let i = left - 1;
    
    for (let j = left; j < right; j++) {
        if (arr[j] <= pivot) {
            i++;
            [arr[i], arr[j]] = [arr[j], arr[i]];
        }
    }
    
    [arr[i + 1], arr[right]] = [arr[right], arr[i + 1]];
    return i + 1;
}
```

**特点**：
- 时间复杂度：平均 O(n log n)，最坏 O(n²)
- 空间复杂度：O(log n)
- 不稳定排序
- 原地排序

#### 1.1.3 归并排序
```javascript
function mergeSort(arr) {
    if (arr.length <= 1) return arr;
    
    const mid = Math.floor(arr.length / 2);
    const left = mergeSort(arr.slice(0, mid));
    const right = mergeSort(arr.slice(mid));
    
    return merge(left, right);
}

function merge(left, right) {
    const result = [];
    let i = 0, j = 0;
    
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            result.push(left[i++]);
        } else {
            result.push(right[j++]);
        }
    }
    
    return result.concat(left.slice(i)).concat(right.slice(j));
}
```

**特点**：
- 时间复杂度：O(n log n)
- 空间复杂度：O(n)
- 稳定排序
- 非原地排序

### 1.2 查找算法

#### 1.2.1 二分查找
```javascript
function binarySearch(arr, target) {
    let left = 0;
    let right = arr.length - 1;
    
    while (left <= right) {
        const mid = Math.floor((left + right) / 2);
        
        if (arr[mid] === target) {
            return mid;
        } else if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
    
    return -1;
}
```

**特点**：
- 时间复杂度：O(log n)
- 空间复杂度：O(1)
- 要求数组有序

#### 1.2.2 哈希表查找
```javascript
class HashTable {
    constructor() {
        this.table = new Map();
    }
    
    put(key, value) {
        this.table.set(this.hash(key), value);
    }
    
    get(key) {
        return this.table.get(this.hash(key));
    }
    
    hash(key) {
        let total = 0;
        for (let i = 0; i < key.length; i++) {
            total += key.charCodeAt(i);
        }
        return total % 37;  // 简单的哈希函数
    }
}
```

**特点**：
- 时间复杂度：平均 O(1)，最坏 O(n)
- 空间复杂度：O(n)
- 需要额外空间

## 2. 高级算法思想

### 2.1 分治法
将大问题分解为小问题，解决小问题后合并结果。

**示例：最大子数组和**
```javascript
function maxSubArray(arr) {
    function divideAndConquer(left, right) {
        if (left === right) return arr[left];
        
        const mid = Math.floor((left + right) / 2);
        const leftMax = divideAndConquer(left, mid);
        const rightMax = divideAndConquer(mid + 1, right);
        
        // 计算跨越中点的最大和
        let leftSum = 0, rightSum = 0;
        let sum = 0;
        
        for (let i = mid; i >= left; i--) {
            sum += arr[i];
            leftSum = Math.max(leftSum, sum);
        }
        
        sum = 0;
        for (let i = mid + 1; i <= right; i++) {
            sum += arr[i];
            rightSum = Math.max(rightSum, sum);
        }
        
        return Math.max(leftMax, rightMax, leftSum + rightSum);
    }
    
    return divideAndConquer(0, arr.length - 1);
}
```

### 2.2 动态规划
通过将复杂问题分解为子问题，并存储子问题的解来避免重复计算。

#### 2.2.1 斐波那契数列
```javascript
// 传统递归方法（效率低）
function fibRecursive(n) {
    if (n <= 1) return n;
    return fibRecursive(n - 1) + fibRecursive(n - 2);
}

// 动态规划方法
function fibDP(n) {
    if (n <= 1) return n;
    
    const dp = new Array(n + 1);
    dp[0] = 0;
    dp[1] = 1;
    
    for (let i = 2; i <= n; i++) {
        dp[i] = dp[i - 1] + dp[i - 2];
    }
    
    return dp[n];
}

// 空间优化版本
function fibOptimized(n) {
    if (n <= 1) return n;
    
    let prev2 = 0;
    let prev1 = 1;
    let current;
    
    for (let i = 2; i <= n; i++) {
        current = prev1 + prev2;
        prev2 = prev1;
        prev1 = current;
    }
    
    return current;
}
```

#### 2.2.2 背包问题
```javascript
function knapsack(values, weights, capacity) {
    const n = values.length;
    const dp = Array(n + 1).fill().map(() => Array(capacity + 1).fill(0));
    
    for (let i = 1; i <= n; i++) {
        for (let w = 0; w <= capacity; w++) {
            if (weights[i-1] <= w) {
                dp[i][w] = Math.max(
                    dp[i-1][w],
                    dp[i-1][w-weights[i-1]] + values[i-1]
                );
            } else {
                dp[i][w] = dp[i-1][w];
            }
        }
    }
    
    return dp[n][capacity];
}
```

### 2.3 贪心算法
在每一步选择中都采取当前状态下最好的选择。

#### 2.3.1 找零钱问题
```javascript
function makeChange(amount, coins) {
    coins.sort((a, b) => b - a);  // 从大到小排序
    const result = [];
    let remaining = amount;
    
    for (const coin of coins) {
        while (remaining >= coin) {
            result.push(coin);
            remaining -= coin;
        }
    }
    
    return result;
}

// 使用示例
console.log(makeChange(67, [25, 10, 5, 1]));  // [25, 25, 10, 5, 1, 1]
```

### 2.4 回溯法
通过尝试所有可能的解决方案来找到问题的解。

#### 2.4.1 N皇后问题
```javascript
function solveNQueens(n) {
    const board = Array(n).fill().map(() => Array(n).fill('.'));
    const result = [];
    
    function isValid(row, col) {
        // 检查列
        for (let i = 0; i < row; i++) {
            if (board[i][col] === 'Q') return false;
        }
        
        // 检查左上对角线
        for (let i = row - 1, j = col - 1; i >= 0 && j >= 0; i--, j--) {
            if (board[i][j] === 'Q') return false;
        }
        
        // 检查右上对角线
        for (let i = row - 1, j = col + 1; i >= 0 && j < n; i--, j++) {
            if (board[i][j] === 'Q') return false;
        }
        
        return true;
    }
    
    function backtrack(row) {
        if (row === n) {
            result.push(board.map(row => row.join('')));
            return;
        }
        
        for (let col = 0; col < n; col++) {
            if (isValid(row, col)) {
                board[row][col] = 'Q';
                backtrack(row + 1);
                board[row][col] = '.';
            }
        }
    }
    
    backtrack(0);
    return result;
}
```

## 3. 实际应用示例

### 3.1 路径规划
```javascript
class PathPlanner {
    // A*算法实现
    static astar(grid, start, end) {
        const openSet = new PriorityQueue();
        const closedSet = new Set();
        const cameFrom = new Map();
        const gScore = new Map();
        const fScore = new Map();
        
        openSet.enqueue(start, 0);
        gScore.set(start, 0);
        fScore.set(start, this.heuristic(start, end));
        
        while (!openSet.isEmpty()) {
            const current = openSet.dequeue();
            
            if (current === end) {
                return this.reconstructPath(cameFrom, current);
            }
            
            closedSet.add(current);
            
            for (const neighbor of this.getNeighbors(current, grid)) {
                if (closedSet.has(neighbor)) continue;
                
                const tentativeGScore = gScore.get(current) + 1;
                
                if (!gScore.has(neighbor) || tentativeGScore < gScore.get(neighbor)) {
                    cameFrom.set(neighbor, current);
                    gScore.set(neighbor, tentativeGScore);
                    fScore.set(neighbor, gScore.get(neighbor) + this.heuristic(neighbor, end));
                    
                    if (!openSet.contains(neighbor)) {
                        openSet.enqueue(neighbor, fScore.get(neighbor));
                    }
                }
            }
        }
        
        return null;  // 没有找到路径
    }
}
```

### 3.2 图像处理
```javascript
class ImageProcessor {
    // 图像边缘检测
    static detectEdges(image) {
        const sobelX = [
            [-1, 0, 1],
            [-2, 0, 2],
            [-1, 0, 1]
        ];
        
        const sobelY = [
            [-1, -2, -1],
            [0, 0, 0],
            [1, 2, 1]
        ];
        
        return this.applyKernel(image, sobelX, sobelY);
    }
    
    // 图像模糊
    static blur(image, kernelSize = 3) {
        const kernel = Array(kernelSize).fill().map(() => 
            Array(kernelSize).fill(1 / (kernelSize * kernelSize))
        );
        
        return this.applyKernel(image, kernel);
    }
}
```

## 4. 性能优化建议

### 4.1 算法选择
| 场景 | 推荐算法 | 原因 |
|-----|---------|------|
| 小数据量排序 | 插入排序 | 常数因子小 |
| 大数据量排序 | 快速排序 | 平均性能最好 |
| 稳定性要求 | 归并排序 | 保证稳定性 |
| 外部排序 | 归并排序 | 适合磁盘操作 |

### 4.2 优化技巧
1. **空间-时间权衡**
   - 使用缓存存储中间结果
   - 预计算常用值
   - 使用合适的数据结构

2. **算法改进**
   - 使用更好的算法
   - 优化内部循环
   - 减少函数调用

3. **代码优化**
   - 避免不必要的对象创建
   - 使用适当的数据类型
   - 减少内存分配

## 5. 练习题推荐
1. [最长递增子序列](https://leetcode.cn/problems/longest-increasing-subsequence/) - 动态规划
2. [零钱兑换](https://leetcode.cn/problems/coin-change/) - 动态规划
3. [组合总和](https://leetcode.cn/problems/combination-sum/) - 回溯法
4. [合并区间](https://leetcode.cn/problems/merge-intervals/) - 贪心算法 