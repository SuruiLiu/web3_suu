# Java并发编程学习指南

## 第一章：并发编程基础

### 1. 什么是并发编程？

并发编程是让程序同时执行多个任务的编程方式。就像一个人同时做多件事：一边听音乐，一边写代码，一边下载文件。

#### 1.1 为什么需要并发编程？
1. **提高性能**：充分利用多核CPU
2. **提高响应性**：不会因为一个耗时任务阻塞整个程序
3. **资源共享**：多个任务共享系统资源

### 2. 线程基础

#### 2.1 什么是线程？
```java
public class ThreadBasics {
    public static void main(String[] args) {
        // 1. 继承Thread类创建线程
        class MyThread extends Thread {
            @Override
            public void run() {
                System.out.println("Thread running: " + Thread.currentThread().getName());
            }
        }
        
        // 2. 实现Runnable接口创建线程
        Runnable myRunnable = () -> {
            System.out.println("Runnable running: " + Thread.currentThread().getName());
        };

        // 启动线程
        MyThread thread1 = new MyThread();
        Thread thread2 = new Thread(myRunnable);

        thread1.start(); // 不要直接调用run()方法
        thread2.start();
    }
}
```

#### 2.2 线程的生命周期
```java
public class ThreadLifecycle {
    public void demonstrateLifecycle() {
        Thread thread = new Thread(() -> {
            try {
                // NEW -> RUNNABLE
                System.out.println("Thread is running");
                
                // RUNNABLE -> TIMED_WAITING
                Thread.sleep(1000);
                
                // TIMED_WAITING -> RUNNABLE
                System.out.println("Thread woke up");
                
                // RUNNABLE -> TERMINATED
                System.out.println("Thread is finishing");
            } catch (InterruptedException e) {
                // RUNNABLE -> TERMINATED (被中断)
                System.out.println("Thread was interrupted");
            }
        });

        // 线程状态：NEW
        System.out.println("Thread state: " + thread.getState());
        
        thread.start();
        // 线程状态：RUNNABLE
        System.out.println("Thread state: " + thread.getState());
    }
}
```

### 3. 线程安全问题

#### 3.1 什么是线程安全？
```java
public class ThreadSafetyExample {
    // 线程不安全的计数器
    public class UnsafeCounter {
        private int count = 0;
        
        public void increment() {
            count++; // 非原子操作
        }
        
        public int getCount() {
            return count;
        }
    }
    
    // 线程安全的计数器
    public class SafeCounter {
        private AtomicInteger count = new AtomicInteger(0);
        
        public void increment() {
            count.incrementAndGet(); // 原子操作
        }
        
        public int getCount() {
            return count.get();
        }
    }

    public void demonstrate() {
        UnsafeCounter unsafeCounter = new UnsafeCounter();
        SafeCounter safeCounter = new SafeCounter();
        
        // 创建多个线程同时增加计数
        Runnable incrementTask = () -> {
            for (int i = 0; i < 1000; i++) {
                unsafeCounter.increment();
                safeCounter.increment();
            }
        };
        
        // 启动10个线程
        Thread[] threads = new Thread[10];
        for (int i = 0; i < 10; i++) {
            threads[i] = new Thread(incrementTask);
            threads[i].start();
        }
        
        // 等待所有线程完成
        for (Thread thread : threads) {
            try {
                thread.join();
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
        
        // 输出结果
        System.out.println("Unsafe counter: " + unsafeCounter.getCount()); // 可能小于10000
        System.out.println("Safe counter: " + safeCounter.getCount());     // 一定等于10000
    }
}
```

#### 3.2 synchronized关键字
```java
public class SynchronizedExample {
    private int count = 0;
    private final Object lock = new Object();
    
    // 1. 同步方法
    public synchronized void increment() {
        count++;
    }
    
    // 2. 同步代码块
    public void incrementBlock() {
        synchronized (lock) {
            count++;
        }
    }
    
    // 3. 静态同步方法
    public static synchronized void staticMethod() {
        System.out.println("This is synchronized on class level");
    }

    // 实际应用示例
    public class BankAccount {
        private double balance;
        
        public synchronized void deposit(double amount) {
            if (amount > 0) {
                double newBalance = balance + amount;
                // 模拟网络延迟
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                balance = newBalance;
            }
        }
        
        public synchronized void withdraw(double amount) {
            if (amount > 0 && balance >= amount) {
                double newBalance = balance - amount;
                // 模拟网络延迟
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
                balance = newBalance;
            }
        }
        
        public synchronized double getBalance() {
            return balance;
        }
    }
}
```

#### 3.3 synchronized和对象锁深入理解

##### 为什么使用对象作为锁？
1. **对象锁的本质**：
   - 每个Java对象都有一个内置的锁（monitor）
   - 使用对象自身作为锁可以避免创建额外的锁对象
   - 确保了对相关资源的访问同步

2. **最佳实践**：
   - 使用final对象作为锁，防止锁对象被修改
   - 选择与受保护资源紧密相关的对象作为锁
   - 避免使用String或包装类型作为锁对象

##### 线程池中的任务数量与线程数量
1. **线程数量**：
   - 表示同时执行任务的工作线程数
   - 通常根据CPU核心数设置
   - 过多的线程会增加线程切换开销
   - 建议设置为：CPU核心数 + 1

2. **任务队列容量**：
   - 等待执行的任务的最大数量
   - 防止内存溢出
   - 可以根据系统资源和业务需求设置
   - 任务队列满时需要有拒绝策略

##### 为什么需要工作线程？
1. **资源利用**：
   - 避免频繁创建和销毁线程
   - 复用线程执行多个任务
   - 控制系统中的线程数量

2. **性能优化**：
   - 减少线程创建的开销
   - 提高任务执行效率
   - 更好的系统资源管理

3. **生命周期管理**：
   - 统一管理线程的创建和销毁
   - 支持优雅关闭
   - 便于监控和维护

### 4. 线程通信

#### 4.1 wait/notify机制
```java
public class WaitNotifyExample {
    public class MessageQueue {
        private final LinkedList<String> queue = new LinkedList<>();
        private final int capacity;
        
        public MessageQueue(int capacity) {
            this.capacity = capacity;
        }
        
        public synchronized void put(String message) throws InterruptedException {
            while (queue.size() >= capacity) {
                // 队列满了，等待消费者消费
                wait();
            }
            
            queue.add(message);
            System.out.println("Added: " + message);
            // 通知消费者
            notify();
        }
        
        public synchronized String take() throws InterruptedException {
            while (queue.isEmpty()) {
                // 队列空了，等待生产者生产
                wait();
            }
            
            String message = queue.remove();
            System.out.println("Removed: " + message);
            // 通知生产者
            notify();
            return message;
        }
    }

    // 使用示例
    public void demonstrate() {
        MessageQueue queue = new MessageQueue(5);
        
        // 生产者线程
        Thread producer = new Thread(() -> {
            try {
                for (int i = 0; i < 10; i++) {
                    queue.put("Message " + i);
                    Thread.sleep(100);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        
        // 消费者线程
        Thread consumer = new Thread(() -> {
            try {
                for (int i = 0; i < 10; i++) {
                    queue.take();
                    Thread.sleep(200);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        
        producer.start();
        consumer.start();
    }
}
```

### 5. 练习题

#### 5.1 基础练习：实现一个线程安全的计数器
```java
// 练习：实现一个线程安全的计数器，要求：
// 1. 支持增加和减少操作
// 2. 支持获取当前值
// 3. 确保线程安全
// 4. 提供重置功能

public class Exercise1 {
    // 请实现这个类
    public class Counter {
        // TODO: 添加必要的字段和方法
    }
}
```

#### 5.2 进阶练习：实现一个简单的线程池
```java
// 练习：实现一个简单的线程池，要求：
// 1. 固定数量的工作线程
// 2. 任务队列
// 3. 支持提交任务
// 4. 支持关闭线程池

public class Exercise2 {
    // 请实现这个类
    public class SimpleThreadPool {
        // TODO: 添加必要的字段和方法
    }
}
```

## 第二章：线程池和并发工具类

### 1. 线程池详解

#### 1.1 线程池的核心参数
```java
public class ThreadPoolExecutorExample {
    public void explainParameters() {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            2,                      // 核心线程数
            4,                      // 最大线程数
            60L,                    // 空闲线程存活时间
            TimeUnit.SECONDS,       // 时间单位
            new LinkedBlockingQueue<>(100),  // 工作队列
            Executors.defaultThreadFactory(),// 线程工厂
            new ThreadPoolExecutor.CallerRunsPolicy() // 拒绝策略
        );
    }
}
```

#### 1.2 常用线程池类型
```java
public class CommonThreadPools {
    // 1. 固定大小的线程池
    ExecutorService fixedPool = Executors.newFixedThreadPool(5);
    
    // 2. 缓存线程池
    ExecutorService cachedPool = Executors.newCachedThreadPool();
    
    // 3. 单线程池
    ExecutorService singlePool = Executors.newSingleThreadExecutor();
    
    // 4. 调度线程池
    ScheduledExecutorService scheduledPool = Executors.newScheduledThreadPool(2);
}
```

#### 1.3 线程池的使用示例
```java
public class ThreadPoolUsage {
    private final ExecutorService executor = Executors.newFixedThreadPool(3);
    
    public void demonstrateUsage() {
        // 1. 提交Runnable任务
        executor.execute(() -> {
            System.out.println("执行Runnable任务");
        });
        
        // 2. 提交Callable任务
        Future<String> future = executor.submit(() -> {
            Thread.sleep(1000);
            return "Callable任务结果";
        });
        
        try {
            String result = future.get(); // 获取任务结果
            System.out.println(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // 3. 优雅关闭线程池
        executor.shutdown();
        try {
            if (!executor.awaitTermination(60, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
        }
    }
}
```

### 2. 并发工具类

#### 2.1 CountDownLatch（倒计时器）
```java
public class CountDownLatchExample {
    public void demonstrate() {
        CountDownLatch latch = new CountDownLatch(3); // 初始计数为3
        
        // 创建三个工作线程
        for (int i = 0; i < 3; i++) {
            final int taskId = i;
            new Thread(() -> {
                try {
                    Thread.sleep(1000);
                    System.out.println("任务" + taskId + "完成");
                    latch.countDown(); // 计数减1
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }).start();
        }
        
        try {
            latch.await(); // 等待所有任务完成
            System.out.println("所有任务已完成");
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

#### 2.2 CyclicBarrier（循环栅栏）
```java
public class CyclicBarrierExample {
    public void demonstrate() {
        CyclicBarrier barrier = new CyclicBarrier(3, () -> {
            // 所有线程到达栅栏时执行
            System.out.println("所有线程已就绪，开始下一轮");
        });
        
        for (int i = 0; i < 3; i++) {
            final int threadId = i;
            new Thread(() -> {
                try {
                    for (int round = 0; round < 3; round++) {
                        System.out.println("线程" + threadId + "准备完成");
                        barrier.await(); // 等待其他线程
                        System.out.println("线程" + threadId + "开始执行");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }).start();
        }
    }
}
```

#### 2.3 Semaphore（信号量）
```java
public class SemaphoreExample {
    public void demonstrate() {
        // 创建只允许3个线程同时访问的信号量
        Semaphore semaphore = new Semaphore(3);
        
        // 模拟10个线程访问资源
        for (int i = 0; i < 10; i++) {
            final int threadId = i;
            new Thread(() -> {
                try {
                    semaphore.acquire(); // 获取许可
                    System.out.println("线程" + threadId + "获得许可");
                    Thread.sleep(1000); // 模拟耗时操作
                    System.out.println("线程" + threadId + "释放许可");
                    semaphore.release(); // 释放许可
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }).start();
        }
    }
}
```

#### 2.4 CompletableFuture（异步编程）
```java
public class CompletableFutureExample {
    public void demonstrate() {
        // 1. 创建异步任务
        CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
            try {
                Thread.sleep(1000);
                return "异步任务结果";
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return "任务被中断";
            }
        });
        
        // 2. 添加回调
        future.thenAccept(result -> System.out.println("处理结果: " + result))
              .thenRun(() -> System.out.println("处理完成"));
        
        // 3. 组合多个异步任务
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> "Hello");
        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> "World");
        
        CompletableFuture<String> combined = future1.thenCombine(future2, 
            (result1, result2) -> result1 + " " + result2);
        
        combined.thenAccept(System.out::println);
    }
}
```

### 3. 练习题

#### 3.1 实现一个带有优先级的线程池
```java
// 练习：实现一个支持任务优先级的线程池，要求：
// 1. 任务可以设置优先级
// 2. 优先级高的任务优先执行
// 3. 支持动态调整线程池大小
// 4. 提供监控功能（当前运行任务数、已完成任务数等）

public class Exercise3 {
    // 请实现这个类
    public class PriorityThreadPool {
        // TODO: 添加必要的字段和方法
    }
}
```

#### 3.2 实现一个基于CompletableFuture的异步任务处理系统
```java
// 练习：实现一个异步任务处理系统，要求：
// 1. 支持提交多个异步任务
// 2. 可以设置任务超时时间
// 3. 支持任务取消
// 4. 提供任务执行状态查询
// 5. 支持任务结果的回调处理

public class Exercise4 {
    // 请实现这个类
    public class AsyncTaskProcessor {
        // TODO: 添加必要的字段和方法
    }
}
```

## 下一步学习建议
1. 完成上述练习题
2. 深入理解线程池的工作原理
3. 熟练使用各种并发工具类
4. 准备好学习下一章：并发集合和原子类

需要我详细解释某个概念或提供更多示例吗？ 