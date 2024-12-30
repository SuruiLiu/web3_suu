# JavaScript 快速入门 - 算法编程常用语法

## 1. 基本数据类型
```javascript
// 数字
let num = 42;
let float = 3.14;

// 字符串
let str = "Hello";
let str2 = 'World';
let template = `${str} ${str2}`; // 模板字符串

// 布尔
let bool = true;

// 空值
let n = null;
let u = undefined;
```

## 2. 数组操作（最常用）
```javascript
// 创建数组
let arr = [1, 2, 3];
let arr2 = new Array(3).fill(0); // [0,0,0]

// 数组基本操作
arr.push(4);      // 尾部添加: [1,2,3,4]
arr.pop();        // 尾部删除并返回: [1,2,3]
arr.unshift(0);   // 头部添加: [0,1,2,3]
arr.shift();      // 头部删除并返回: [1,2,3]

// 数组切片
arr.slice(1, 3);  // 返回新数组 [2,3]

// 数组修改
arr.splice(1, 1); // 从索引1开始删除1个元素

// 常用数组方法
arr.length;       // 数组长度
arr.indexOf(2);   // 查找元素位置
arr.includes(2);  // 检查是否包含元素

// 数组遍历
arr.forEach(item => console.log(item));
arr.map(item => item * 2);        // 返回新数组
arr.filter(item => item > 2);     // 过滤
arr.reduce((sum, item) => sum + item, 0); // 累加
```

## 3. 对象操作
```javascript
// 创建对象
let obj = {
    name: "John",
    age: 30
};

// 访问属性
obj.name;         // 点号访问
obj['name'];      // 方括号访问

// 检查属性
'name' in obj;    // true
obj.hasOwnProperty('name'); // true

// 获取所有键或值
Object.keys(obj);   // ['name', 'age']
Object.values(obj); // ['John', 30]
```

## 4. Map 和 Set
```javascript
// Map（键值对集合）
let map = new Map();
map.set('key', 'value');
map.get('key');        // 'value'
map.has('key');        // true
map.delete('key');
map.size;              // 获取大小

// Set（唯一值集合）
let set = new Set([1, 2, 2, 3]);
set.add(4);           // 添加元素
set.has(4);           // true
set.delete(4);        // 删除元素
set.size;             // 获取大小
```

## 5. 循环和条件
```javascript
// for 循环
for (let i = 0; i < arr.length; i++) {
    // 使用 arr[i]
}

// for...of 循环（推荐用于数组）
for (let item of arr) {
    // 使用 item
}

// for...in 循环（用于对象）
for (let key in obj) {
    // 使用 obj[key]
}

// while 循环
while (condition) {
    // 代码
}

// if 条件
if (condition) {
    // 代码
} else if (condition2) {
    // 代码
} else {
    // 代码
}
```

## 6. 函数
```javascript
// 普通函数
function add(a, b) {
    return a + b;
}

// 箭头函数
const add = (a, b) => a + b;

// 带默认参数的函数
function greet(name = "Guest") {
    return `Hello ${name}`;
}
```

## 7. 常用算法技巧
```javascript
// 1. 初始化固定大小的数组
const arr = new Array(n).fill(0);

// 2. 2D数组初始化
const matrix = Array(m).fill().map(() => Array(n).fill(0));

// 3. 获取最大/最小值
Math.max(...arr);
Math.min(...arr);

// 4. 数字操作
Math.floor(3.7);  // 3 向下取整
Math.ceil(3.2);   // 4 向上取整
Math.round(3.5);  // 4 四舍五入
Math.trunc(3.7);  // 3 截断小数部分

// 5. 字符串转数字
parseInt("42");    // 字符串转整数
parseFloat("3.14"); // 字符串转浮点数
Number("42");      // 字符串转数字

// 6. 数组排序
arr.sort((a, b) => a - b);  // 升序
arr.sort((a, b) => b - a);  // 降序
```

## 8. 常用正则表达式
```javascript
// 检查字符串是否包含数字
/\d/.test("abc123");  // true

// 替换字符串
"hello".replace(/l/g, "w");  // "hewwo"
```

## 9. 类（在实现数据结构时常用）
```javascript
class ListNode {
    constructor(val = 0, next = null) {
        this.val = val;
        this.next = next;
    }
}

class Queue {
    constructor() {
        this.items = [];
    }

    enqueue(element) {
        this.items.push(element);
    }

    dequeue() {
        return this.items.shift();
    }
}
```

## 注意事项
1. JavaScript 中数组可以动态改变大小
2. 对象和数组都是引用类型
3. Map 的键可以是任何类型，而对象的键只能是字符串或 Symbol
4. 使用 === 进行严格相等比较
5. 注意处理边界情况和空值检查

---

这些是在算法题中最常用的 JavaScript 语法。建议：
1. 重点掌握数组的操作方法
2. 熟悉 Map 和 Set 的使用
3. 理解引用类型和值类型的区别
4. 多练习不同的循环方式
