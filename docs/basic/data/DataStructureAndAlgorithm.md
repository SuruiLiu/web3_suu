# 数据结构与算法 - 第1周：基础数据结构

## 数组与链表

### 数组(Array)
#### 1. 基本概念
- **定义**: 一段连续的内存空间，存储相同类型的数据
- **特点**:
  - 随机访问，O(1)时间复杂度
  - 插入删除需要移动元素，O(n)时间复杂度
  - 空间连续，可能造成空间浪费

#### 2. 基本操作及实现
```javascript
// 数组的基本操作实现 (JavaScript版本)
class ArrayList {
    constructor() {
        this.array = [];
    }
    
    // 在指定位置插入元素
    insert(element, index) {
        if (index < 0 || index > this.array.length) {
            return false;
        }
        
        // 从后向前移动元素
        for (let i = this.array.length; i > index; i--) {
            this.array[i] = this.array[i - 1];
        }
        
        this.array[index] = element;
        return true;
    }
    
    // 删除指定位置的元素
    delete(index) {
        if (index < 0 || index >= this.array.length) {
            return false;
        }
        
        // 从前向后移动元素
        for (let i = index; i < this.array.length - 1; i++) {
            this.array[i] = this.array[i + 1];
        }
        
        this.array.length--;
        return true;
    }
    
    // 获取指定位置的元素
    get(index) {
        if (index < 0 || index >= this.array.length) {
            return undefined;
        }
        return this.array[index];
    }
}

// 使用示例
const list = new ArrayList();
list.insert(1, 0);  // [1]
list.insert(2, 1);  // [1, 2]
list.insert(3, 1);  // [1, 3, 2]
list.delete(1);     // [1, 2]
```

#### 3. 常见面试题
1. [两数之和](https://leetcode.cn/problems/two-sum/)
```javascript
function twoSum(nums, target) {
    const map = new Map();
    
    for (let i = 0; i < nums.length; i++) {
        const complement = target - nums[i];
        if (map.has(complement)) {
            return [map.get(complement), i];
        }
        map.set(nums[i], i);
    }
    
    return [];
}
```

### 链表(Linked List)
#### 1. 基本概念
- **定义**: 由节点组成的线性集合，每个节点存储数据和指向下一个节点的指针
- **类型**:
  - 单链表：每个节点只有一个后继指针
  - 双链表：每个节点有前驱和后继指针
  - 循环链表：最后一个节点指向第一个节点

#### 2. 基本操作及实现
```javascript
class ListNode {
    constructor(val) {
        this.val = val;
        this.next = null;
    }
}

class LinkedList {
    constructor() {
        this.head = null;
    }
    
    // 在头部插入节点
    insertAtHead(val) {
        const newNode = new ListNode(val);
        newNode.next = this.head;
        this.head = newNode;
    }
    
    // 在尾部插入节点
    insertAtTail(val) {
        const newNode = new ListNode(val);
        
        if (!this.head) {
            this.head = newNode;
            return;
        }
        
        let current = this.head;
        while (current.next) {
            current = current.next;
        }
        current.next = newNode;
    }
    
    // 删除指定值的节点
    delete(val) {
        if (!this.head) return;
        
        if (this.head.val === val) {
            this.head = this.head.next;
            return;
        }
        
        let current = this.head;
        while (current.next && current.next.val !== val) {
            current = current.next;
        }
        
        if (current.next) {
            current.next = current.next.next;
        }
    }
    
    // 打印链表
    print() {
        let values = [];
        let current = this.head;
        while (current) {
            values.push(current.val);
            current = current.next;
        }
        console.log(values.join(' -> '));
    }
}

// 使用示例
const list = new LinkedList();
list.insertAtTail(1);
list.insertAtTail(2);
list.insertAtTail(3);
list.print();  // 1 -> 2 -> 3
list.delete(2);
list.print();  // 1 -> 3
```

#### 3. 经典问题
1. **链表反转** [LeetCode 206](https://leetcode.cn/problems/reverse-linked-list/)
基本思想：
反转链表就是把每个节点的 next 指针指向它的前一个节点
但是如果直接改变 next 指针，我们就会丢失下一个节点的信息
所以需要一个临时变量来保存下一个节点的信息
```javascript
function reverseList(head) {
    let prev = null;
    let curr = head;
    
    while (curr) {
        const next = curr.next;  // 保存下一个节点
        curr.next = prev;        // 反转指针
        prev = curr;             // 移动prev
        curr = next;             // 移动curr
    }
    
    return prev;
}
```

2. **检测环** [LeetCode 142](https://leetcode.cn/problems/linked-list-cycle-ii/)
基本思想：
- 使用快慢指针（Floyd's Cycle Finding Algorithm）
- 快指针每次走两步，慢指针每次走一步
- 如果有环，快慢指针一定会在环内相遇
- 相遇后，让一个指针回到头节点，两个指针同速前进，再次相遇点就是环的入口
- 这是因为：从头节点到环入口的距离等于从相遇点到环入口的距离

代码实现：
```javascript
function detectCycle(head) {
    let slow = head;
    let fast = head;
    
    // 检测是否有环
    while (fast && fast.next) {
        slow = slow.next;
        fast = fast.next.next;
        if (slow === fast) {
            // 找到环的入口
            let ptr = head;
            while (ptr !== slow) {
                ptr = ptr.next;
                slow = slow.next;
            }
            return ptr;
        }
    }
    
    return null;
}
```

3. **最小栈** [LeetCode 155](https://leetcode.cn/problems/min-stack/)

基本思想：
- 使用辅助栈存储当前最小值
- 每次入栈时，同时更新最小值栈
- 出栈时同步处理两个栈

```javascript
class MinStack {
    constructor() {
        this.stack = [];
        this.minStack = []; // 辅助栈，存储最小值
    }
    
    push(val) {
        this.stack.push(val);
        if (this.minStack.length === 0 || val <= this.minStack[this.minStack.length - 1]) {
            this.minStack.push(val);
        }
    }
    
    pop() {
        if (this.stack.pop() === this.minStack[this.minStack.length - 1]) {
            this.minStack.pop();
        }
    }
    
    top() {
        return this.stack[this.stack.length - 1];
    }
    
    getMin() {
        return this.minStack[this.minStack.length - 1];
    }
}
```

4. **逆波兰表达式求值** [LeetCode 150](https://leetcode.cn/problems/evaluate-reverse-polish-notation/)

基本思想：
- 遇到数字入栈
- 遇到运算符，取出栈顶两个数字进行运算，结果入栈
- 最后栈中只剩一个数字，就是结果

```javascript
function evalRPN(tokens) {
    const stack = [];
    const operators = {
        '+': (a, b) => a + b,
        '-': (a, b) => a - b,
        '*': (a, b) => a * b,
        '/': (a, b) => Math.trunc(a / b)
    };
    
    for (const token of tokens) {
        if (operators[token]) {
            const b = stack.pop();
            const a = stack.pop();
            stack.push(operators[token](a, b));
        } else {
            stack.push(Number(token));
        }
    }
    
    return stack[0];
}
```

### 实践项目：LRU缓存
[LeetCode 146](https://leetcode.cn/problems/lru-cache/)

基本概念：
- LRU (Least Recently Used) 是一种缓存淘汰策略
- 当缓存满时，优先淘汰最久未使用的数据
- 每次访问数据时，将该数据移动到最新位置
- 实际应用：浏览器缓存、内存管理、数据库缓存等

基本思想：
- 使用哈希表实现 O(1) 的查找
- 使用有序数据结构记录访问顺序
- 每次访问数据时更新其位置
- 缓存满时删除最久未使用的数据

代码实现：
```javascript
class LRUCache {
    constructor(capacity) {
        this.capacity = capacity;
        this.cache = new Map();  // Map会保持插入顺序
    }
    
    get(key) {
        if (!this.cache.has(key)) return -1;
        
        const value = this.cache.get(key);
        this.cache.delete(key);    // 删除后重新插入，相当于移到最新位置
        this.cache.set(key, value);
        return value;
    }
    
    put(key, value) {
        if (this.cache.has(key)) {
            this.cache.delete(key);
        } else if (this.cache.size >= this.capacity) {
            // 删除最久未使用的数据（Map中的第一个元素）
            const firstKey = this.cache.keys().next().value;
            this.cache.delete(firstKey);
        }
        
        this.cache.set(key, value);
    }
}

// 使用示例
const cache = new LRUCache(2);
cache.put(1, 1);
cache.put(2, 2);
console.log(cache.get(1));  // 1
cache.put(3, 3);           // 删除 key 2
console.log(cache.get(2));  // -1
```

### 学习建议
1. 理解数组和链表的基本特性和适用场景
2. 掌握基本操作的时间复杂度
3. 多练习链表的指针操作
4. 使用画图辅助理解链表操作
5. 注意边界条件的处理

### 进阶学习
1. 跳表（Skip List）的实现原理
2. 循环链表的应用场景
3. XOR链表（节省空间的双向链表）
4. 链表在实际项目中的应用

---


### 栈(Stack)
#### 1. 基本概念
- **定义**: 后进先出(LIFO)的线性数据结构
- **特点**:
  - 只能在一端（栈顶）进行操作
  - 入栈(push)和出栈(pop)的时间复杂度为O(1)
  - 应用场景：函数调用栈、表达式求值、括号匹配

#### 2. 基本操作及实现
```javascript
class Stack {
    constructor() {
        this.items = [];
    }
    
    push(element) {
        this.items.push(element);
    }
    
    // 移除并返回栈顶元素
    pop() {
        if (this.isEmpty()) return undefined;
        return this.items.pop();
    }
    
    // 查看栈顶元素，但不移除
    peek() {
        if (this.isEmpty()) return undefined;
        return this.items[this.items.length - 1];
    }
    
    isEmpty() {
        return this.items.length === 0;
    }
    
    size() {
        return this.items.length;
    }
}
```

#### 3. 经典问题
1. **有效的括号** [LeetCode 20](https://leetcode.cn/problems/valid-parentheses/)

基本思想：
- 遇到左括号就入栈
- 遇到右括号就与栈顶的左括号匹配
- 如果匹配成功则出栈，失败则返回false
- 最后栈为空则说明所有括号都匹配成功

```javascript
function isValid(s) {
    const stack = [];
    const pairs = {
        ')': '(',
        ']': '[',
        '}': '{'
    };
    
    for (let char of s) {
        if (!pairs[char]) {
            // 左括号，入栈
            stack.push(char);
        } else if (stack.pop() !== pairs[char]) {
            // 右括号，检查是否匹配
            return false;
        }
    }
    
    return stack.length === 0;
}
```

2. **最小栈** [LeetCode 155](https://leetcode.cn/problems/min-stack/)

基本思想：
- 使用辅助栈存储当前最小值
- 每次入栈时，同时更新最小值栈
- 出栈时同步处理两个栈

```javascript
class MinStack {
    constructor() {
        this.stack = [];
        this.minStack = []; // 辅助栈，存储最小值
    }
    
    push(val) {
        this.stack.push(val);
        if (this.minStack.length === 0 || val <= this.minStack[this.minStack.length - 1]) {
            this.minStack.push(val);
        }
    }
    
    pop() {
        if (this.stack.pop() === this.minStack[this.minStack.length - 1]) {
            this.minStack.pop();
        }
    }
    
    top() {
        return this.stack[this.stack.length - 1];
    }
    
    getMin() {
        return this.minStack[this.minStack.length - 1];
    }
}
```

3. **逆波兰表达式求值** [LeetCode 150](https://leetcode.cn/problems/evaluate-reverse-polish-notation/)

基本思想：
- 逆波兰表达式是一种后缀表达式，运算符在操作数之后
- 遇到数字入栈
- 遇到运算符，取出栈顶两个数字进行运算，结果入栈
- 最后栈中只剩一个数字，就是结果
- 注意运算符的优先级和除法取整
- 使用Map存储运算符和对应的函数
- 使用Number()将字符串转换为数字
- 使用Math.trunc()进行除法取整
- 使用Map存储运算符和对应的函数
- 使用Number()将字符串转换为数字
- 使用Math.trunc()进行除法取整
- 使用Map存储运算符和对应的函数

```javascript
function evalRPN(tokens) {
    const stack = [];
    const operators = {
        '+': (a, b) => a + b,
        '-': (a, b) => a - b,
        '*': (a, b) => a * b,
        '/': (a, b) => Math.trunc(a / b)
    };
    
    for (const token of tokens) {
        if (operators[token]) {
            const b = stack.pop();
            const a = stack.pop();
            stack.push(operators[token](a, b));
        } else {
            stack.push(Number(token));
        }
    }
    
    return stack[0];
}
```

### 队列(Queue)
#### 1. 基本概念
- **定义**: 先进先出(FIFO)的线性数据结构
- **特点**:
  - 只能在一端（队尾）添加元素，在另一端（队首）删除元素
  - 入队(enqueue)和出队(dequeue)的时间复杂度为O(1)
  - 应用场景：任务队列、打印机队列、广度优先搜索

#### 2. 基本操作及实现
```javascript
class Queue {
    constructor() {
        this.items = [];
    }
    
    enqueue(element) {
        this.items.push(element);
    }
    
    dequeue() {
        if (this.isEmpty()) return undefined;
        return this.items.shift();
    }
    
    front() {
        if (this.isEmpty()) return undefined;
        return this.items[0];
    }
    
    isEmpty() {
        return this.items.length === 0;
    }
    
    size() {
        return this.items.length;
    }
}
```

#### 3. 经典问题
1. **滑动窗口最大值** [LeetCode 239](https://leetcode.cn/problems/sliding-window-maximum/)

基本思想：
- 使用双端队列维护一个单调递减队列
- 队列中存储的是元素的下标
- 队首始终是当前窗口中的最大值
- 移动窗口时，移除超出窗口范围的元素

```javascript
function maxSlidingWindow(nums, k) {
    const result = [];
    const deque = [];  // 存储下标
    
    for (let i = 0; i < nums.length; i++) {
        // 移除超出窗口范围的元素
        while (deque.length && deque[0] <= i - k) {
            deque.shift();
        }
        
        // 保持队列单调递减
        while (deque.length && nums[deque[deque.length - 1]] < nums[i]) {
            deque.pop();
        }
        
        deque.push(i);
        
        // 当窗口长度为k时，记录最大值
        if (i >= k - 1) {
            result.push(nums[deque[0]]);
        }
    }
    
    return result;
}
```

2. **用队列实现栈** [LeetCode 225](https://leetcode.cn/problems/implement-stack-using-queues/)

基本思想：
- 使用一个队列实现
- 每次push时，将新元素入队后，将前面的所有元素依次出队并重新入队
- 这样最后入队的元素就会在队首，实现了栈的后进先出

```javascript
class MyStack {
    constructor() {
        this.queue = [];
    }
    
    push(x) {
        this.queue.push(x);
        for (let i = 0; i < this.queue.length - 1; i++) {
            this.queue.push(this.queue.shift());
        }
    }
    
    pop() {
        return this.queue.shift();
    }
    
    top() {
        return this.queue[0];
    }
    
    empty() {
        return this.queue.length === 0;
    }
}
```

3. **浏览器历史记录管理**
- 使用两个栈实现前进和后退功能
- 一个栈存储后退历史，一个栈存储前进历史
- 新访问页面时清空前进历史

```javascript
class BrowserHistory {
    constructor(homepage) {
        this.backStack = [homepage];
        this.forwardStack = [];
    }
    
    visit(url) {
        this.backStack.push(url);
        this.forwardStack = []; // 清空前进历史
    }
    
    back() {
        if (this.backStack.length > 1) {
            this.forwardStack.push(this.backStack.pop());
            return this.backStack[this.backStack.length - 1];
        }
        return this.backStack[0];
    }
    
    forward() {
        if (this.forwardStack.length > 0) {
            const url = this.forwardStack.pop();
            this.backStack.push(url);
            return url;
        }
        return this.backStack[this.backStack.length - 1];
    }
}
```

4. **任务调度器**
- 使用队列实现任务的调度
- 支持任务优先级
- 支持任务取消和暂停

```javascript
class TaskScheduler {
    constructor() {
        this.taskQueue = [];
        this.running = false;
    }
    
    addTask(task, priority = 0) {
        this.taskQueue.push({ task, priority });
        this.taskQueue.sort((a, b) => b.priority - a.priority);
    }
    
    async start() {
        if (this.running) return;
        this.running = true;
        
        while (this.taskQueue.length > 0 && this.running) {
            const { task } = this.taskQueue.shift();
            await task();
        }
        
        this.running = false;
    }
    
    pause() {
        this.running = false;
    }
}
```

### 学习建议
1. 理解栈和队列的特性及其适用场景
2. 掌握基本操作的实现方法
3. 注意边界条件的处理
4. 灵活运用栈和队列解决实际问题

---


### 字符串(String)
#### 1. 基本概念
- **定义**: 由零个或多个字符组成的有限序列
- **特点**:
  - JavaScript中字符串是不可变的
  - 可以像数组一样按索引访问字符
  - 具有length属性
  - 支持Unicode字符集

#### 2. 基本操作及实现
```javascript
// 字符串基本操作
let str = "Hello World";

// 访问字符
str[0];                  // 'H'
str.charAt(0);          // 'H'

// 获取长度
str.length;             // 11

// 子串操作
str.substring(0, 5);    // "Hello"
str.slice(0, 5);        // "Hello"
str.substr(6, 5);       // "World"

// 查找
str.indexOf('o');       // 4
str.lastIndexOf('o');   // 7
str.includes('World');  // true

// 大小写转换
str.toLowerCase();      // "hello world"
str.toUpperCase();      // "HELLO WORLD"

// 去除空格
str.trim();            // 去除两端空格
str.trimStart();       // 去除开头空格
str.trimEnd();         // 去除结尾空格

// 分割和连接
str.split(' ');        // ["Hello", "World"]
['Hello', 'World'].join(' '); // "Hello World"
```

#### 3. 经典问题
1. **最长回文子串** [LeetCode 5](https://leetcode.cn/problems/longest-palindromic-substring/)

基本思想：
- 从每个位置向两边扩展，分别处理奇数和偶数长度的回文串
- 记录最长回文串的起始位置和长度
- 注意边界条件的处理

```javascript
function longestPalindrome(s) {
    let start = 0, maxLength = 1;
    
    // 辅助函数：从中心向两边扩展
    function expandAroundCenter(left, right) {
        while (left >= 0 && right < s.length && s[left] === s[right]) {
            const currentLength = right - left + 1;
            if (currentLength > maxLength) {
                start = left;
                maxLength = currentLength;
            }
            left--;
            right++;
        }
    }
    
    for (let i = 0; i < s.length; i++) {
        expandAroundCenter(i, i);     // 奇数长度
        expandAroundCenter(i, i + 1); // 偶数长度
    }
    
    return s.substring(start, start + maxLength);
}
```

2. **字符串匹配(KMP算法)** [LeetCode 28](https://leetcode.cn/problems/find-the-index-of-the-first-occurrence-in-a-string/)

基本思想：
- 构建部分匹配表(next数组)
- 利用已匹配的信息避免不必要的比较
- 当匹配失败时，通过next数组快速移动模式串

```javascript
function strStr(haystack, needle) {
    if (needle === '') return 0;
    
    // 构建next数组
    const next = [0];
    for (let i = 1, j = 0; i < needle.length; i++) {
        while (j > 0 && needle[i] !== needle[j]) {
            j = next[j - 1];
        }
        if (needle[i] === needle[j]) {
            j++;
        }
        next[i] = j;
    }
    
    // KMP搜索
    for (let i = 0, j = 0; i < haystack.length; i++) {
        while (j > 0 && haystack[i] !== needle[j]) {
            j = next[j - 1];
        }
        if (haystack[i] === needle[j]) {
            j++;
        }
        if (j === needle.length) {
            return i - j + 1;
        }
    }
    
    return -1;
}
```

### 实践项目：简单文本编辑器
```javascript
class TextEditor {
    constructor() {
        this.content = [];
        this.undoStack = [];
        this.redoStack = [];
    }
    
    // 插入文本
    insert(text) {
        this.undoStack.push([...this.content]);
        this.content.push(...text.split(''));
        this.redoStack = [];
    }
    
    // 删除文本
    delete(count) {
        this.undoStack.push([...this.content]);
        this.content.splice(-count, count);
        this.redoStack = [];
    }
    
    // 撤销
    undo() {
        if (this.undoStack.length > 0) {
            this.redoStack.push([...this.content]);
            this.content = this.undoStack.pop();
        }
    }
    
    // 重做
    redo() {
        if (this.redoStack.length > 0) {
            this.undoStack.push([...this.content]);
            this.content = this.redoStack.pop();
        }
    }
    
    // 获取当前文本
    getText() {
        return this.content.join('');
    }
}
```

### 学习建议
1. 熟练掌握字符串的基本操作方法
2. 理解字符串的不可变性
3. 注意字符串操作的边界条件
4. 学习常用的字符串算法（如KMP）

---

这是字符串的内容，需要补充或调整什么吗？接下来我们可以开始学习第二周的树结构。

# 数据结构与算法 - 第2周：树结构

## 树的基础

### 1. 树的基本概念
- **定义**: 由节点和边组成的分层数据结构
- **特点**:
  - 有一个根节点
  - 每个节点可以有多个子节点
  - 没有环路
  - 任意两个节点间有且仅有一条路径

### 2. 二叉树
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
    
    // 插入节点
    insert(val) {
        const newNode = new TreeNode(val);
        
        if (!this.root) {
            this.root = newNode;
            return;
        }
        
        const queue = [this.root];
        while (queue.length) {
            const node = queue.shift();
            
            if (!node.left) {
                node.left = newNode;
                return;
            }
            if (!node.right) {
                node.right = newNode;
                return;
            }
            
            queue.push(node.left);
            queue.push(node.right);
        }
    }
    
    // 三种遍历方式
    preorder(node = this.root) {
        if (!node) return [];
        return [node.val, ...this.preorder(node.left), ...this.preorder(node.right)];
    }
    
    inorder(node = this.root) {
        if (!node) return [];
        return [...this.inorder(node.left), node.val, ...this.inorder(node.right)];
    }
    
    postorder(node = this.root) {
        if (!node) return [];
        return [...this.postorder(node.left), ...this.postorder(node.right), node.val];
    }
    
    // 层序遍历
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

### 3. 二叉搜索树(BST)
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
    
    // 删除节点
    delete(val) {
        this.root = this._deleteNode(this.root, val);
    }
    
    _deleteNode(node, val) {
        if (!node) return null;
        
        if (val < node.val) {
            node.left = this._deleteNode(node.left, val);
        } else if (val > node.val) {
            node.right = this._deleteNode(node.right, val);
        } else {
            // 找到要删除的节点
            
            // 情况1：叶子节点
            if (!node.left && !node.right) {
                return null;
            }
            
            // 情况2：只有一个子节点
            if (!node.left) return node.right;
            if (!node.right) return node.left;
            
            // 情况3：有两个子节点
            const minNode = this._findMin(node.right);
            node.val = minNode.val;
            node.right = this._deleteNode(node.right, minNode.val);
        }
        
        return node;
    }
    
    _findMin(node) {
        while (node.left) {
            node = node.left;
        }
        return node;
    }
}
```

### 4. 经典问题
1. **验证二叉搜索树** [LeetCode 98](https://leetcode.cn/problems/validate-binary-search-tree/)
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

2. **二叉树的最大深度** [LeetCode 104](https://leetcode.cn/problems/maximum-depth-of-binary-tree/)
```javascript
function maxDepth(root) {
    if (!root) return 0;
    return Math.max(maxDepth(root.left), maxDepth(root.right)) + 1;
}
```

### 5. 平衡二叉树(AVL树)
```javascript
class AVLNode {
    constructor(val) {
        this.val = val;
        this.left = null;
        this.right = null;
        this.height = 1;  // 新节点高度为1
    }
}

class AVLTree {
    constructor() {
        this.root = null;
    }
    
    // 获取节点高度
    height(node) {
        return node ? node.height : 0;
    }
    
    // 获取平衡因子
    balanceFactor(node) {
        return node ? this.height(node.left) - this.height(node.right) : 0;
    }
    
    // 更新节点高度
    updateHeight(node) {
        node.height = Math.max(this.height(node.left), this.height(node.right)) + 1;
    }
    
    // 右旋转
    rightRotate(y) {
        const x = y.left;
        const T2 = x.right;
        
        x.right = y;
        y.left = T2;
        
        this.updateHeight(y);
        this.updateHeight(x);
        
        return x;
    }
    
    // 左旋转
    leftRotate(x) {
        const y = x.right;
        const T2 = y.left;
        
        y.left = x;
        x.right = T2;
        
        this.updateHeight(x);
        this.updateHeight(y);
        
        return y;
    }
    
    // 插入节点
    insert(val) {
        this.root = this._insert(this.root, val);
    }
    
    _insert(node, val) {
        // 1. 执行标准BST插入
        if (!node) return new AVLNode(val);
        
        if (val < node.val) {
            node.left = this._insert(node.left, val);
        } else {
            node.right = this._insert(node.right, val);
        }
        
        // 2. 更新高度
        this.updateHeight(node);
        
        // 3. 获取平衡因子
        const balance = this.balanceFactor(node);
        
        // 4. 如果不平衡，有四种情况
        
        // 左左情况
        if (balance > 1 && val < node.left.val) {
            return this.rightRotate(node);
        }
        
        // 右右情况
        if (balance < -1 && val > node.right.val) {
            return this.leftRotate(node);
        }
        
        // 左右情况
        if (balance > 1 && val > node.left.val) {
            node.left = this.leftRotate(node.left);
            return this.rightRotate(node);
        }
        
        // 右左情况
        if (balance < -1 && val < node.right.val) {
            node.right = this.rightRotate(node.right);
            return this.leftRotate(node);
        }
        
        return node;
    }
}
```

### 6. 红黑树
```javascript
const RED = true;
const BLACK = false;

class RBNode {
    constructor(val) {
        this.val = val;
        this.left = null;
        this.right = null;
        this.color = RED;  // 新节点默认为红色
        this.parent = null;
    }
}

class RedBlackTree {
    constructor() {
        this.root = null;
    }
    
    // 左旋转
    leftRotate(node) {
        const rightChild = node.right;
        
        node.right = rightChild.left;
        if (rightChild.left) {
            rightChild.left.parent = node;
        }
        
        rightChild.parent = node.parent;
        if (!node.parent) {
            this.root = rightChild;
        } else if (node === node.parent.left) {
            node.parent.left = rightChild;
        } else {
            node.parent.right = rightChild;
        }
        
        rightChild.left = node;
        node.parent = rightChild;
    }
    
    // 插入后修复红黑树性质
    fixInsert(node) {
        while (node.parent && node.parent.color === RED) {
            if (node.parent === node.parent.parent.left) {
                const uncle = node.parent.parent.right;
                
                if (uncle && uncle.color === RED) {
                    // 情况1：叔叔节点是红色
                    node.parent.color = BLACK;
                    uncle.color = BLACK;
                    node.parent.parent.color = RED;
                    node = node.parent.parent;
                } else {
                    if (node === node.parent.right) {
                        // 情况2：叔叔是黑色，当前节点是右子节点
                        node = node.parent;
                        this.leftRotate(node);
                    }
                    // 情况3：叔叔是黑色，当前节点是左子节点
                    node.parent.color = BLACK;
                    node.parent.parent.color = RED;
                    this.rightRotate(node.parent.parent);
                }
            } else {
                // 对称情况
                const uncle = node.parent.parent.left;
                // ... 类似上面的代码，左右对调
            }
        }
        this.root.color = BLACK;
    }
}
```

### 7. 树的高级应用

#### 7.1 前缀树(Trie)
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
    
    // 插入单词
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
    
    // 搜索单词
    search(word) {
        const node = this._searchNode(word);
        return node !== null && node.isEndOfWord;
    }
    
    // 判断是否有前缀
    startsWith(prefix) {
        return this._searchNode(prefix) !== null;
    }
    
    _searchNode(str) {
        let current = this.root;
        
        for (const char of str) {
            if (!current.children[char]) {
                return null;
            }
            current = current.children[char];
        }
        
        return current;
    }
}
```

#### 7.2 线段树
```javascript
class SegmentTree {
    constructor(arr) {
        this.arr = arr;
        this.tree = new Array(4 * arr.length);
        if (arr.length) this.build(0, 0, arr.length - 1);
    }
    
    // 构建线段树
    build(node, start, end) {
        if (start === end) {
            this.tree[node] = this.arr[start];
            return;
        }
        
        const mid = Math.floor((start + end) / 2);
        const leftNode = 2 * node + 1;
        const rightNode = 2 * node + 2;
        
        this.build(leftNode, start, mid);
        this.build(rightNode, mid + 1, end);
        
        this.tree[node] = this.tree[leftNode] + this.tree[rightNode];
    }
    
    // 区间查询
    query(node, start, end, left, right) {
        if (left > end || right < start) return 0;
        if (left <= start && right >= end) return this.tree[node];
        
        const mid = Math.floor((start + end) / 2);
        const leftSum = this.query(2 * node + 1, start, mid, left, right);
        const rightSum = this.query(2 * node + 2, mid + 1, end, left, right);
        
        return leftSum + rightSum;
    }
    
    // 单点更新
    update(node, start, end, index, val) {
        if (start === end) {
            this.arr[index] = val;
            this.tree[node] = val;
            return;
        }
        
        const mid = Math.floor((start + end) / 2);
        const leftNode = 2 * node + 1;
        const rightNode = 2 * node + 2;
        
        if (index <= mid) {
            this.update(leftNode, start, mid, index, val);
        } else {
            this.update(rightNode, mid + 1, end, index, val);
        }
        
        this.tree[node] = this.tree[leftNode] + this.tree[rightNode];
    }
}
```

### 8. B树和B+树
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
    
    // 在非满节点中插入关键字
    insertNonFull(node, k) {
        let i = node.n - 1;
        
        if (node.isLeaf) {
            // 在叶子节点中插入关键字
            while (i >= 0 && node.keys[i] > k) {
                node.keys[i + 1] = node.keys[i];
                i--;
            }
            
            node.keys[i + 1] = k;
            node.n = node.n + 1;
        } else {
            // 在内部节点中找到合适的子节点
            while (i >= 0 && node.keys[i] > k) {
                i--;
            }
            i++;
            
            if (node.children[i].n === 2 * this.t - 1) {
                this.splitChild(node, i, node.children[i]);
                if (k > node.keys[i]) {
                    i++;
                }
            }
            
            this.insertNonFull(node.children[i], k);
        }
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

### 9. 并查集
```javascript
class UnionFind {
    constructor(size) {
        this.parent = new Array(size);
        this.rank = new Array(size);
        
        // 初始化，每个元素的父节点是自己
        for (let i = 0; i < size; i++) {
            this.parent[i] = i;
            this.rank[i] = 0;
        }
    }
    
    // 查找元素所属的集合（路径压缩）
    find(x) {
        if (this.parent[x] !== x) {
            this.parent[x] = this.find(this.parent[x]);
        }
        return this.parent[x];
    }
    
    // 合并两个集合（按秩合并）
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
    
    // 判断两个元素是否属于同一个集合
    connected(x, y) {
        return this.find(x) === this.find(y);
    }
}
```

### 10. 实践项目：文件系统目录结构
```javascript
class FileNode {
    constructor(name, isDirectory = false) {
        this.name = name;
        this.isDirectory = isDirectory;
        this.children = new Map();  // 用于目录
        this.content = '';         // 用于文件
        this.parent = null;
    }
}

class FileSystem {
    constructor() {
        this.root = new FileNode('/', true);
        this.currentDir = this.root;
    }
    
    // 创建目录
    mkdir(path) {
        const parts = path.split('/').filter(Boolean);
        let current = this.root;
        
        for (const part of parts) {
            if (!current.children.has(part)) {
                const newDir = new FileNode(part, true);
                newDir.parent = current;
                current.children.set(part, newDir);
            }
            current = current.children.get(part);
        }
    }
    
    // 列出当前目录内容
    ls() {
        return Array.from(this.currentDir.children.keys()).sort();
    }
    
    // 切换目录
    cd(path) {
        if (path === '/') {
            this.currentDir = this.root;
            return;
        }
        
        if (path === '..') {
            if (this.currentDir.parent) {
                this.currentDir = this.currentDir.parent;
            }
            return;
        }
        
        const dir = this.currentDir.children.get(path);
        if (dir && dir.isDirectory) {
            this.currentDir = dir;
        }
    }
    
    // 创建文件
    touch(filename, content = '') {
        const file = new FileNode(filename);
        file.content = content;
        file.parent = this.currentDir;
        this.currentDir.children.set(filename, file);
    }
}

// 使用示例
const fs = new FileSystem();
fs.mkdir('/home/user');
fs.cd('/home');
fs.touch('test.txt', 'Hello, World!');
console.log(fs.ls());  // ['test.txt', 'user']
```

### 11. 最近公共祖先
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

### 12. 路径和
```javascript
function hasPathSum(root, targetSum) {
    if (!root) return false;
    
    // 叶子节点
    if (!root.left && !root.right) {
        return root.val === targetSum;
    }
    
    return hasPathSum(root.left, targetSum - root.val) ||
           hasPathSum(root.right, targetSum - root.val);
}
```

### 13. B树和B+树详细实现

#### 13.1 B树完整实现
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
    
    // 在非满节点中插入关键字
    insertNonFull(node, k) {
        let i = node.n - 1;
        
        if (node.isLeaf) {
            // 在叶子节点中插入关键字
            while (i >= 0 && node.keys[i] > k) {
                node.keys[i + 1] = node.keys[i];
                i--;
            }
            
            node.keys[i + 1] = k;
            node.n = node.n + 1;
        } else {
            // 在内部节点中找到合适的子节点
            while (i >= 0 && node.keys[i] > k) {
                i--;
            }
            i++;
            
            if (node.children[i].n === 2 * this.t - 1) {
                this.splitChild(node, i, node.children[i]);
                if (k > node.keys[i]) {
                    i++;
                }
            }
            
            this.insertNonFull(node.children[i], k);
        }
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

#### 13.2 B+树实现
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

### 14. B树和B+树的比较

#### 14.1 主要区别
1. **数据存储位置**：
   - B树：所有节点都存储数据
   - B+树：只有叶子节点存储数据

2. **节点结构**：
   - B树：每个节点包含键和数据
   - B+树：内部节点只包含键，叶子节点包含键和数据

3. **查询效率**：
   - B树：可能在非叶子节点就找到数据
   - B+树：总是要查询到叶子节点

4. **范围查询**：
   - B树：需要中序遍历
   - B+树：利用叶子节点链表，更高效

#### 14.2 应用场景
1. **B树适用于**：
   - 单条记录查询较多的场景
   - 数据量相对较小的场景
   - 内存存储的场景

2. **B+树适用于**：
   - 范围查询较多的场景
   - 数据量很大的场景
   - 磁盘存储（数据库索引）

[继续...]
