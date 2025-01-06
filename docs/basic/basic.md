## 第2周：计算机组成原理基础

### 1. 计算机系统概述

#### 1.1 计算机发展历史
- **第一代**：电子管计算机（1946-1957）
- **第二代**：晶体管计算机（1958-1964）
- **第三代**：集成电路计算机（1965-1971）
- **第四代**：大规模集成电路计算机（1972至今）

#### 1.2 冯·诺依曼体系结构
五大基本组成部分：
1. **运算器**：执行算术运算和逻辑运算
2. **控制器**：控制程序的执行
3. **存储器**：存储程序和数据
4. **输入设备**：接收外部输入
5. **输出设备**：输出处理结果

### 2. CPU的基本组成和工作原理

#### 2.1 CPU的基本组成
1. **运算器**
   - ALU（算术逻辑单元）
   - 累加器（AC）
   - 数据缓冲寄存器（DR）
   - 状态寄存器（PSW）

2. **控制器**
   - 程序计数器（PC）
   - 指令寄存器（IR）
   - 指令译码器（ID）
   - 时序控制器

#### 2.2 CPU工作原理
1. **指令周期**：
```
取指令 → 分析指令 → 执行指令
```

2. **指令执行过程**：
```javascript
class CPU {
    constructor() {
        this.PC = 0;      // 程序计数器
        this.IR = null;   // 指令寄存器
        this.AC = 0;      // 累加器
        this.memory = []; // 内存
    }
    
    // 执行一个指令周期
    executeInstructionCycle() {
        // 1. 取指令
        this.IR = this.memory[this.PC];
        this.PC++;
        
        // 2. 分析指令
        const {opcode, operand} = this.decodeInstruction(this.IR);
        
        // 3. 执行指令
        this.executeInstruction(opcode, operand);
    }
}
```

### 3. 存储系统

#### 3.1 存储层次结构
```
寄存器 → 缓存 → 主存 → 外存
(速度快，容量小) → (速度慢，容量大)
```

#### 3.2 主存储器
1. **基本概念**：
   - 存储单元：最小寻址单位
   - 存储字：一次存取的二进制位数
   - 存储容量：总存储位数

2. **存储器分类**：
   - RAM：随机访问存储器
   - ROM：只读存储器
   - Cache：高速缓存

### 4. 总线系统

#### 4.1 总线的基本概念
1. **定义**：连接各个部件的公共通信线路
2. **分类**：
   - 数据总线：传输数据
   - 地址总线：传输地址
   - 控制总线：传输控制信号

#### 4.2 总线结构
```
+-------------+        +-------------+
|    CPU      |        |    内存     |
+-------------+        +-------------+
       ↑↓                    ↑↓
==================================== 系统总线
       ↑↓                    ↑↓
+-------------+        +-------------+
|   I/O接口   |        |  其他设备   |
+-------------+        +-------------+
```

### 5. 输入输出系统

#### 5.1 I/O接口的基本功能
1. **地址译码**：识别设备地址
2. **数据缓冲**：暂存输入输出数据
3. **控制和状态**：管理设备状态
4. **数据格式转换**：处理数据格式

#### 5.2 I/O方式
1. **程序查询方式**
2. **中断方式**
3. **DMA方式**

```javascript
// 中断处理示例
class InterruptHandler {
    handleInterrupt(deviceID) {
        // 1. 保存现场
        this.saveContext();
        
        // 2. 识别中断源
        const handler = this.getInterruptHandler(deviceID);
        
        // 3. 处理中断
        handler.process();
        
        // 4. 恢复现场
        this.restoreContext();
    }
}
```

### 6. 实践要点
1. 理解计算机的基本组成和工作原理
2. 掌握CPU的结构和指令执行过程
3. 了解存储系统的层次结构
4. 理解总线系统的工作机制
5. 掌握基本的I/O控制方式

### 7. 经典问题
1. CPU性能计算
2. 存储系统访问时间分析
3. 总线带宽计算
4. 中断响应时间分析 