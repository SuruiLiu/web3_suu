# 分布式系统学习路径

## 第一阶段：Java基础（4-6周）

### 第1-2周：面向对象编程
1. **面向对象基础**
   - 类与对象
   - 继承与多态
   - 接口与抽象类
   - 封装与访问控制

2. **Java核心机制**
   - 异常处理
   - 反射机制
   - 泛型
   - 注解

### 第3-4周：Java集合框架
1. **集合基础**
   - List、Set、Map接口
   - ArrayList/LinkedList
   - HashMap/TreeMap
   - 集合工具类

2. **实践项目**
```java
// 1. 自定义ArrayList实现
public class MyArrayList<E> {
    private Object[] elements;
    private int size;
    
    public boolean add(E element) {
        ensureCapacity();
        elements[size++] = element;
        return true;
    }
    
    public E get(int index) {
        checkIndex(index);
        return (E) elements[index];
    }
}

// 2. 实现简单的LRU缓存
public class LRUCache<K, V> {
    private LinkedHashMap<K, V> cache;
    private final int capacity;
    
    public LRUCache(int capacity) {
        this.capacity = capacity;
        this.cache = new LinkedHashMap<K, V>(capacity, 0.75f, true) {
            protected boolean removeEldestEntry(Map.Entry eldest) {
                return size() > capacity;
            }
        };
    }
}
```

## 第二阶段：并发编程（6-8周）

### 第1-3周：线程基础
1. **线程基本概念**
   - 线程的生命周期
   - 线程的创建和启动
   - 线程的中断和结束

2. **线程同步**
   - synchronized关键字
   - volatile关键字
   - wait/notify机制

### 第4-6周：并发工具
1. **并发集合**
   - ConcurrentHashMap
   - BlockingQueue
   - CopyOnWriteArrayList

2. **线程池**
   - ThreadPoolExecutor
   - 常用线程池类型
   - 线程池参数调优

3. **实践项目**
```java
// 1. 生产者-消费者模型
public class ProducerConsumer {
    private BlockingQueue<String> queue;
    
    class Producer implements Runnable {
        public void run() {
            while (true) {
                String data = produceData();
                queue.put(data);
            }
        }
    }
    
    class Consumer implements Runnable {
        public void run() {
            while (true) {
                String data = queue.take();
                processData(data);
            }
        }
    }
}

// 2. 自定义线程池
public class CustomThreadPool {
    private BlockingQueue<Runnable> workQueue;
    private List<WorkerThread> threads;
    
    public void execute(Runnable task) {
        if (threads.size() < corePoolSize) {
            addWorker(task);
        } else {
            workQueue.offer(task);
        }
    }
}
```

## 第三阶段：计算机网络（4-6周）

### 第1-2周：网络基础
1. **网络模型**
   - OSI七层模型
   - TCP/IP四层模型
   - 各层协议详解

2. **TCP/IP协议**
   - TCP三次握手和四次挥手
   - TCP流量控制
   - TCP拥塞控制

### 第3-4周：应用层协议
1. **HTTP协议**
   - HTTP请求/响应
   - HTTP方法
   - HTTP状态码
   - HTTPS原理

2. **实践项目**
```java
// 1. 实现简单的HTTP服务器
public class SimpleHttpServer {
    public void start(int port) throws IOException {
        ServerSocket serverSocket = new ServerSocket(port);
        while (true) {
            Socket client = serverSocket.accept();
            handleRequest(client);
        }
    }
    
    private void handleRequest(Socket client) {
        // 解析HTTP请求
        // 处理请求
        // 返回响应
    }
}

// 2. HTTP客户端实现
public class HttpClient {
    public Response get(String url) throws IOException {
        URL obj = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) obj.openConnection();
        conn.setRequestMethod("GET");
        return handleResponse(conn);
    }
}
```

## 第四阶段：操作系统（4-6周）

### 第1-2周：进程和线程
1. **进程管理**
   - 进程状态转换
   - 进程调度算法
   - 进程间通信

2. **内存管理**
   - 内存分配策略
   - 虚拟内存
   - 页面置换算法

### 第3-4周：文件系统
1. **文件管理**
   - 文件组织
   - 文件访问方法
   - 目录结构

2. **实践项目**
```java
// 1. 进程通信示例
public class ProcessCommunication {
    public void createPipe() throws IOException {
        PipedInputStream pis = new PipedInputStream();
        PipedOutputStream pos = new PipedOutputStream(pis);
        
        new Thread(() -> {
            try {
                pos.write("Hello".getBytes());
            } catch (IOException e) {
                e.printStackTrace();
            }
        }).start();
    }
}

// 2. 文件系统操作
public class FileSystemOperations {
    public void copyDirectory(String src, String dest) throws IOException {
        Files.walk(Paths.get(src))
            .forEach(source -> {
                Path destination = Paths.get(dest, source.toString()
                    .substring(src.length()));
                try {
                    Files.copy(source, destination);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            });
    }
}
```

## 第五阶段：数据库（6-8周）

### 第1-3周：关系型数据库
1. **SQL基础**
   - DDL/DML/DCL
   - 事务和ACID特性
   - 索引原理和优化

2. **MySQL实践**
   - 表设计
   - 查询优化
   - 事务控制

### 第4-6周：NoSQL数据库
1. **Redis**
   - 数据类型
   - 持久化机制
   - 分布式特性

2. **实践项目**
```java
// 1. 数据库连接池
public class ConnectionPool {
    private LinkedList<Connection> pool;
    private static final int INITIAL_SIZE = 10;
    
    public synchronized Connection getConnection() {
        if (pool.isEmpty()) {
            createNewConnection();
        }
        return pool.removeFirst();
    }
}

// 2. Redis缓存实现
public class RedisCache {
    private RedisTemplate redisTemplate;
    
    public void set(String key, Object value, long timeout) {
        redisTemplate.opsForValue().set(key, value, timeout, TimeUnit.SECONDS);
    }
}
```

## 学习建议

1. **基础先行**
   - 先掌握Java基础和并发编程
   - 这是学习分布式系统的基石

2. **循序渐进**
   - 网络和操作系统知识是理解分布式系统的关键
   - 数据库知识为分布式存储打基础

3. **实践结合**
   - 每个阶段都要有对应的代码实践
   - 尝试实现一些小型项目

4. **推荐资源**
   - 《Java核心技术》
   - 《Java并发编程实战》
   - 《计算机网络：自顶向下方法》
   - 《现代操作系统》
   - 《MySQL技术内幕》

完成这些基础学习后，你就可以开始学习分布式系统了。需要我详细解释某个部分吗？ 