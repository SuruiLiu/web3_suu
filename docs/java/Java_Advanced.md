# Java进阶学习指南

## IOC原理解析

### 1. 什么是IOC
IOC（Inversion of Control，控制反转）是一种设计思想，它将传统上由程序代码直接操控的对象的调用权交给容器，通过容器来实现对象组件的装配和管理。

#### 1.1 传统方式 vs IOC方式
1. **传统方式**：
```java
public class UserService {
    // 直接在类内部创建依赖对象
    private UserRepository userRepository = new UserRepository();
}
```
存在的问题：
- 类与类之间耦合度高
- 难以更换实现
- 难以进行单元测试

2. **IOC方式**：
```java
public class UserService {
    // 不再自己创建，而是等待被注入
    @Autowired
    private UserRepository userRepository;
}
```
优点：
- 类与类之间解耦
- 容易更换实现
- 便于测试

### 2. IOC容器的作用

#### 2.1 核心功能
1. **对象管理**：
   - 创建和管理对象的生命周期
   - 管理对象之间的依赖关系

2. **依赖注入**：
   - 自动将依赖的对象注入到需要的地方
   - 支持多种注入方式（构造器注入、属性注入等）

#### 2.2 实现机制
1. **组件标记**：
```java
@Component  // 标记类需要被IOC容器管理
public class UserRepository {
    // ...
}
```

2. **依赖注入标记**：
```java
public class UserService {
    @Autowired  // 标记字段需要被注入
    private UserRepository userRepository;
}
```

3. **容器管理**：
```java
// 创建容器并使用
SimpleIOC ioc = new SimpleIOC();
ioc.scan("com.example.ioc");  // 扫描组件
UserService userService = (UserService) ioc.getBean("userService");  // 获取实例
```

### 3. 实际应用场景

#### 3.1 业务解耦
```java
// 可以轻松替换实现
@Component
public class MySQLUserRepository implements UserRepository {
    // MySQL实现
}

@Component
public class MongoUserRepository implements UserRepository {
    // MongoDB实现
}
```

#### 3.2 测试便利
```java
// 测试时可以轻松替换为mock对象
public class UserServiceTest {
    @Mock
    private UserRepository userRepository;
    
    @InjectMocks
    private UserService userService;
}
```

#### 3.3 配置灵活
```java
@Component("productionRepository")
public class ProductionUserRepository implements UserRepository {
    // 生产环境实现
}

@Component("testRepository")
public class TestUserRepository implements UserRepository {
    // 测试环境实现
}
```

### 4. IOC容器执行流程

1. **初始化**：
   - 创建IOC容器实例
   - 准备bean的容器和类定义映射

2. **扫描**：
   - 扫描指定包下的所有类
   - 识别带有@Component注解的类
   - 将类信息存储到容器中

3. **Bean创建和注入**：
   - 检查是否已存在实例
   - 创建新的实例（如果需要）
   - 查找@Autowired注解的字段
   - 递归创建和注入依赖

4. **使用**：
   - 通过容器获取所需的对象
   - 容器负责管理对象的整个生命周期

### 5. 为什么叫"控制反转"
- **传统方式**：类自己控制依赖对象的创建和生命周期
- **IOC方式**：类只声明需要什么，具体创建和注入由容器控制
- **本质**：将控制权从具体业务代码转移到了通用的容器中

这种设计方式的优势：
- 提高代码的可维护性
- 提高代码的可测试性
- 提高代码的可扩展性
- 降低代码的耦合度

## 一、设计模式

### 1. 创建型模式
#### 1.1 单例模式
```java
// 1. 懒汉式（线程不安全）
public class Singleton {
    private static Singleton instance;
    private Singleton() {}
    
    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}

// 2. 双重检查锁定
public class DoubleCheckSingleton {
    private volatile static DoubleCheckSingleton instance;
    private DoubleCheckSingleton() {}
    
    public static DoubleCheckSingleton getInstance() {
        if (instance == null) {
            synchronized (DoubleCheckSingleton.class) {
                if (instance == null) {
                    instance = new DoubleCheckSingleton();
                }
            }
        }
        return instance;
    }
}

// 3. 静态内部类
public class StaticSingleton {
    private StaticSingleton() {}
    
    private static class SingletonHolder {
        private static final StaticSingleton INSTANCE = new StaticSingleton();
    }
    
    public static StaticSingleton getInstance() {
        return SingletonHolder.INSTANCE;
    }
}
```

#### 1.2 工厂模式
```java
// 简单工厂
public class SimpleFactory {
    public static Product createProduct(String type) {
        switch (type) {
            case "A": return new ProductA();
            case "B": return new ProductB();
            default: throw new IllegalArgumentException("Unknown product type");
        }
    }
}

// 工厂方法
public interface Factory {
    Product createProduct();
}

public class FactoryA implements Factory {
    @Override
    public Product createProduct() {
        return new ProductA();
    }
}
```

#### 1.3 建造者模式
```java
public class User {
    private final String name;
    private final int age;
    private final String address;
    
    private User(Builder builder) {
        this.name = builder.name;
        this.age = builder.age;
        this.address = builder.address;
    }
    
    public static class Builder {
        private String name;
        private int age;
        private String address;
        
        public Builder name(String name) {
            this.name = name;
            return this;
        }
        
        public Builder age(int age) {
            this.age = age;
            return this;
        }
        
        public Builder address(String address) {
            this.address = address;
            return this;
        }
        
        public User build() {
            return new User(this);
        }
    }
}
```

### 2. 结构型模式
#### 2.1 代理模式
```java
// JDK动态代理
public class LoggingHandler implements InvocationHandler {
    private final Object target;
    
    public LoggingHandler(Object target) {
        this.target = target;
    }
    
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("Before method: " + method.getName());
        Object result = method.invoke(target, args);
        System.out.println("After method: " + method.getName());
        return result;
    }
}

// 使用示例
UserService userService = (UserService) Proxy.newProxyInstance(
    UserService.class.getClassLoader(),
    new Class<?>[] { UserService.class },
    new LoggingHandler(new UserServiceImpl())
);
```

#### 2.2 装饰器模式
```java
public interface DataSource {
    void writeData(String data);
    String readData();
}

public class FileDataSource implements DataSource {
    private String filename;
    
    public FileDataSource(String filename) {
        this.filename = filename;
    }
    
    @Override
    public void writeData(String data) {
        // 写入文件
    }
    
    @Override
    public String readData() {
        // 读取文件
        return null;
    }
}

public class EncryptionDecorator implements DataSource {
    private DataSource wrappee;
    
    public EncryptionDecorator(DataSource source) {
        this.wrappee = source;
    }
    
    @Override
    public void writeData(String data) {
        // 加密数据
        wrappee.writeData(encrypt(data));
    }
    
    @Override
    public String readData() {
        // 解密数据
        return decrypt(wrappee.readData());
    }
}
```

### 3. 行为型模式
#### 3.1 观察者模式
```java
public interface Observer {
    void update(String message);
}

public class Subject {
    private List<Observer> observers = new ArrayList<>();
    
    public void attach(Observer observer) {
        observers.add(observer);
    }
    
    public void detach(Observer observer) {
        observers.remove(observer);
    }
    
    public void notifyObservers(String message) {
        for (Observer observer : observers) {
            observer.update(message);
        }
    }
}
```

#### 3.2 策略模式
```java
public interface PaymentStrategy {
    void pay(int amount);
}

public class CreditCardPayment implements PaymentStrategy {
    @Override
    public void pay(int amount) {
        System.out.println("Paid " + amount + " using Credit Card");
    }
}

public class PayPalPayment implements PaymentStrategy {
    @Override
    public void pay(int amount) {
        System.out.println("Paid " + amount + " using PayPal");
    }
}

public class ShoppingCart {
    private PaymentStrategy paymentStrategy;
    
    public void setPaymentStrategy(PaymentStrategy strategy) {
        this.paymentStrategy = strategy;
    }
    
    public void checkout(int amount) {
        paymentStrategy.pay(amount);
    }
}
```

## 二、Java 8新特性

### 1. Lambda表达式
```java
// 1. 基本语法
Runnable r = () -> System.out.println("Hello Lambda!");

// 2. 带参数的Lambda
Comparator<String> c = (s1, s2) -> s1.compareTo(s2);

// 3. 函数式接口
@FunctionalInterface
interface Calculator {
    int calculate(int x, int y);
}

Calculator add = (x, y) -> x + y;
Calculator multiply = (x, y) -> x * y;
```

### 2. Stream API
```java
public class StreamDemo {
    public void demo() {
        List<String> list = Arrays.asList("a", "b", "c");
        
        // 1. 过滤
        list.stream()
            .filter(s -> s.startsWith("a"))
            .forEach(System.out::println);
        
        // 2. 映射
        list.stream()
            .map(String::toUpperCase)
            .collect(Collectors.toList());
        
        // 3. 归约
        int sum = list.stream()
            .mapToInt(String::length)
            .sum();
        
        // 4. 分组
        Map<Integer, List<String>> groups = list.stream()
            .collect(Collectors.groupingBy(String::length));
    }
}
```

### 3. Optional类
```java
public class OptionalDemo {
    public void demo() {
        Optional<String> optional = Optional.of("Hello");
        
        // 1. 安全获取值
        String result = optional.orElse("Default");
        
        // 2. 条件执行
        optional.ifPresent(System.out::println);
        
        // 3. 链式调用
        String transformed = optional
            .map(String::toUpperCase)
            .filter(s -> s.length() > 5)
            .orElse("Too Short");
    }
}
```

### 4. Stream API详解

#### 4.1 基础用法
```java
public class StreamExample {
    public void basicStreamOperations() {
        List<String> names = Arrays.asList("alice", "bob", "charlie", "david");

        // 1. 基础转换：全部转大写
        List<String> upperNames = names.stream()
            .map(name -> name.toUpperCase())
            .collect(Collectors.toList());
        // 结果: ["ALICE", "BOB", "CHARLIE", "DAVID"]

        // 2. 过滤长度大于4的名字
        List<String> longNames = names.stream()
            .filter(name -> name.length() > 4)
            .collect(Collectors.toList());
        // 结果: ["alice", "charlie", "david"]

        // 3. 找到第一个以'c'开头的名字
        Optional<String> firstC = names.stream()
            .filter(name -> name.startsWith("c"))
            .findFirst();
        // 结果: Optional["charlie"]
    }
}
```

#### 4.2 方法引用详解
```java
public class MethodReferenceDemo {
    public void methodReferenceTypes() {
        List<String> names = Arrays.asList("alice", "bob", "charlie");

        // 1. 对象::实例方法
        // 完整lambda: str -> str.toUpperCase()
        // 方法引用: String::toUpperCase
        List<String> upper1 = names.stream()
            .map(String::toUpperCase)
            .collect(Collectors.toList());

        // 2. 类::静态方法
        // 完整lambda: str -> Integer.parseInt(str)
        // 方法引用: Integer::parseInt
        List<String> numbers = Arrays.asList("1", "2", "3");
        List<Integer> parsed = numbers.stream()
            .map(Integer::parseInt)
            .collect(Collectors.toList());

        // 3. 对象::实例方法
        StringBuilder sb = new StringBuilder();
        // 完整lambda: str -> sb.append(str)
        // 方法引用: sb::append
        names.forEach(sb::append);

        // 4. 类::new（构造器引用）
        // 完整lambda: () -> new ArrayList<>()
        // 方法引用: ArrayList::new
        Supplier<List<String>> supplier = ArrayList::new;
    }
}
```

#### 4.3 Stream常用操作
```java
public class StreamOperationsDemo {
    public void demonstrateOperations() {
        List<String> words = Arrays.asList(
            "hello", "world", "java", "stream", "lambda"
        );

        // 1. map转换
        List<Integer> lengths = words.stream()
            .map(String::length)  // 获取每个字符串的长度
            .collect(Collectors.toList());
        // 结果: [5, 5, 4, 6, 6]

        // 2. filter过滤
        List<String> longWords = words.stream()
            .filter(word -> word.length() > 4)
            .collect(Collectors.toList());
        // 结果: ["hello", "world", "stream", "lambda"]

        // 3. sorted排序
        List<String> sorted = words.stream()
            .sorted()  // 自然排序
            .collect(Collectors.toList());
        // 结果: ["hello", "java", "lambda", "stream", "world"]

        // 4. distinct去重
        List<String> distinct = words.stream()
            .map(String::length)
            .distinct()
            .collect(Collectors.toList());
        // 结果: [5, 4, 6]

        // 5. peek查看元素（调试用）
        List<String> debugged = words.stream()
            .peek(e -> System.out.println("Processing: " + e))
            .map(String::toUpperCase)
            .collect(Collectors.toList());
    }
}
```

#### 4.4 收集器（Collectors）使用
```java
public class CollectorsExample {
    public void collectorsDemo() {
        List<String> words = Arrays.asList(
            "hello", "world", "java", "stream", "lambda"
        );

        // 1. 收集为List
        List<String> list = words.stream()
            .collect(Collectors.toList());

        // 2. 收集为Set
        Set<String> set = words.stream()
            .collect(Collectors.toSet());

        // 3. 收集为Map
        Map<String, Integer> map = words.stream()
            .collect(Collectors.toMap(
                word -> word,           // 键映射函数
                String::length          // 值映射函数
            ));
        // 结果: {"hello"=5, "world"=5, "java"=4, ...}

        // 4. 分组
        Map<Integer, List<String>> grouped = words.stream()
            .collect(Collectors.groupingBy(String::length));
        // 结果: {4=["java"], 5=["hello", "world"], 6=["stream", "lambda"]}

        // 5. 连接字符串
        String joined = words.stream()
            .collect(Collectors.joining(", "));
        // 结果: "hello, world, java, stream, lambda"

        // 6. 统计
        IntSummaryStatistics stats = words.stream()
            .collect(Collectors.summarizingInt(String::length));
        System.out.println("Average length: " + stats.getAverage());
        System.out.println("Max length: " + stats.getMax());
    }
}
```

### 5. Optional详解

#### 5.1 基础用法
```java
public class OptionalBasics {
    public void basicUsage() {
        // 1. 创建Optional对象
        // 1.1 创建非空Optional
        Optional<String> nonNull = Optional.of("Hello");
        
        // 1.2 创建可能为空的Optional
        String nullableString = getMaybeNull(); // 可能返回null的方法
        Optional<String> nullable = Optional.ofNullable(nullableString);
        
        // 1.3 创建空Optional
        Optional<String> empty = Optional.empty();
        
        // 2. 检查值是否存在
        if (nullable.isPresent()) {
            System.out.println("Value is present: " + nullable.get());
        }
        
        // 3. 如果值不存在则使用默认值
        String result = nullable.orElse("Default Value");
    }
}
```

#### 5.2 高级用法
```java
public class OptionalAdvanced {
    class User {
        private String name;
        private Address address;
        // getters and setters
    }
    
    class Address {
        private String street;
        // getters and setters
    }
    
    public void advancedUsage() {
        Optional<User> user = findUser("john");
        
        // 1. map转换值
        Optional<String> userName = user.map(User::getName);
        
        // 2. flatMap处理嵌套Optional
        Optional<String> street = user
            .flatMap(u -> Optional.ofNullable(u.getAddress()))
            .map(Address::getStreet);
        
        // 3. filter过滤值
        Optional<User> adult = user
            .filter(u -> u.getAge() > 18);
        
        // 4. orElseGet提供默认值（延迟计算）
        User defaultUser = user.orElseGet(() -> createDefaultUser());
        
        // 5. orElseThrow抛出异常
        User result = user.orElseThrow(() -> 
            new UserNotFoundException("User not found"));
    }
}
```

#### 5.3 Optional最佳实践
```java
public class OptionalBestPractices {
    // 1. 正确的返回Optional的方法
    public Optional<User> findUserById(Long id) {
        User user = userRepository.findById(id);
        return Optional.ofNullable(user);
    }
    
    // 2. 链式调用处理多层级对象
    public String getUserStreet(Long userId) {
        return findUserById(userId)
            .map(User::getAddress)
            .map(Address::getStreet)
            .orElse("Unknown");
    }
    
    // 3. 条件执行
    public void processUserIfPresent(Long userId) {
        findUserById(userId).ifPresent(user -> {
            sendEmail(user);
            updateLastLoginTime(user);
        });
    }
    
    // 4. 不同条件下的处理
    public void handleUser(Long userId) {
        findUserById(userId).ifPresentOrElse(
            user -> System.out.println("Found user: " + user.getName()),
            () -> System.out.println("User not found")
        );
    }
}
```

#### 5.4 Optional与Stream结合
```java
public class OptionalWithStream {
    public void optionalStreamCombination() {
        List<User> users = Arrays.asList(
            new User("John", "john@example.com"),
            new User("Jane", null),
            new User("Bob", "bob@example.com")
        );
        
        // 1. 过滤出所有有效的邮箱
        List<String> validEmails = users.stream()
            .map(User::getEmail)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .collect(Collectors.toList());
        
        // 2. 使用flatMap处理Optional
        List<String> emails = users.stream()
            .map(User::getEmail)
            .flatMap(Optional::stream)
            .collect(Collectors.toList());
    }
}
```

## 三、函数式编程

### 1. 函数式接口
```java
// 1. 常用函数式接口
public class FunctionalInterfaceDemo {
    public void demo() {
        // Predicate - 判断
        Predicate<String> isEmpty = String::isEmpty;
        
        // Function - 转换
        Function<String, Integer> toInt = Integer::parseInt;
        
        // Consumer - 消费
        Consumer<String> printer = System.out::println;
        
        // Supplier - 提供
        Supplier<Double> random = Math::random;
    }
}
```

### 2. 方法引用
```java
public class MethodReferenceDemo {
    public void demo() {
        // 1. 静态方法引用
        Function<String, Integer> parser = Integer::parseInt;
        
        // 2. 实例方法引用
        String str = "Hello";
        Supplier<Integer> lengthGetter = str::length;
        
        // 3. 构造方法引用
        Supplier<ArrayList<String>> listCreator = ArrayList::new;
    }
}
```

### 3. 组合式编程
```java
public class CompositionDemo {
    public void demo() {
        // 1. 函数组合
        Function<String, String> toLowerCase = String::toLowerCase;
        Function<String, String> trim = String::trim;
        Function<String, String> combined = toLowerCase.andThen(trim);
        
        // 2. 谓词组合
        Predicate<String> isEmpty = String::isEmpty;
        Predicate<String> isNull = Objects::isNull;
        Predicate<String> isNullOrEmpty = isNull.or(isEmpty);
    }
}
```

## 四、高级并发编程

### 1. CompletableFuture详解

#### 1.1 基础用法
```java
public class CompletableFutureBasics {
    public void basicOperations() {
        // 1. 创建CompletableFuture
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
            // 模拟耗时操作
            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            return "Hello";
        });

        // 2. 转换结果
        CompletableFuture<Integer> future2 = future1.thenApply(s -> {
            return s.length();
        });

        // 3. 消费结果
        future2.thenAccept(length -> {
            System.out.println("Length: " + length);
        });

        // 4. 异常处理
        future1.exceptionally(throwable -> {
            System.err.println("Error: " + throwable.getMessage());
            return "Error occurred";
        });
    }
}
```

#### 1.2 高级操作
```java
public class CompletableFutureAdvanced {
    private ExecutorService executor = Executors.newFixedThreadPool(4);

    public void advancedOperations() {
        // 1. 组合多个Future
        CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> "Hello", executor);
        CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> "World", executor);

        CompletableFuture<String> combined = future1
            .thenCombine(future2, (s1, s2) -> s1 + " " + s2)
            .whenComplete((result, throwable) -> {
                if (throwable != null) {
                    System.err.println("Error occurred: " + throwable.getMessage());
                } else {
                    System.out.println("Result: " + result);
                }
            });

        // 2. 多个Future的依赖执行
        CompletableFuture<String> dependent = future1
            .thenCompose(s -> CompletableFuture.supplyAsync(() -> s + " Composed"))
            .thenApply(String::toUpperCase)
            .thenApply(s -> s + "!");

        // 3. 任意一个完成就继续
        CompletableFuture<Object> any = CompletableFuture.anyOf(future1, future2);

        // 4. 所有完成才继续
        CompletableFuture<Void> all = CompletableFuture.allOf(future1, future2);
    }

    // 实际应用示例：异步HTTP请求
    public class AsyncHttpExample {
        public CompletableFuture<String> asyncHttpGet(String url) {
            return CompletableFuture.supplyAsync(() -> {
                // 模拟HTTP请求
                try {
                    Thread.sleep(1000);
                    return "Response from " + url;
                } catch (InterruptedException e) {
                    throw new CompletionException(e);
                }
            }, executor);
        }

        public void multipleRequests() {
            List<String> urls = Arrays.asList(
                "http://api1.example.com",
                "http://api2.example.com",
                "http://api3.example.com"
            );

            // 并行执行多个请求
            List<CompletableFuture<String>> futures = urls.stream()
                .map(this::asyncHttpGet)
                .collect(Collectors.toList());

            // 等待所有请求完成
            CompletableFuture<List<String>> allFutures = CompletableFuture.allOf(
                futures.toArray(new CompletableFuture[0]))
                .thenApply(v -> futures.stream()
                    .map(CompletableFuture::join)
                    .collect(Collectors.toList()));
        }
    }
}

### 2. 线程池深入理解

#### 2.1 线程池核心参数
```java
public class ThreadPoolExplained {
    public void createThreadPool() {
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            2,                      // 核心线程数
            4,                      // 最大线程数
            60L,                    // 空闲线程存活时间
            TimeUnit.SECONDS,       // 时间单位
            new LinkedBlockingQueue<>(100),  // 工作队列
            new ThreadFactory() {   // 线程工厂
                private final AtomicInteger counter = new AtomicInteger(1);
                @Override
                public Thread newThread(Runnable r) {
                    Thread thread = new Thread(r);
                    thread.setName("CustomThread-" + counter.getAndIncrement());
                    return thread;
                }
            },
            new ThreadPoolExecutor.CallerRunsPolicy()  // 拒绝策略
        );
    }

    // 自定义线程池配置
    public class CustomThreadPool {
        private final ThreadPoolExecutor executor;
        private final BlockingQueue<Runnable> workQueue;
        private final AtomicInteger activeTaskCount = new AtomicInteger(0);

        public CustomThreadPool(int coreSize, int maxSize) {
            this.workQueue = new LinkedBlockingQueue<>(1000);
            this.executor = new ThreadPoolExecutor(
                coreSize, maxSize, 60L, TimeUnit.SECONDS, workQueue,
                new ThreadPoolExecutor.AbortPolicy()) {
                
                @Override
                protected void beforeExecute(Thread t, Runnable r) {
                    activeTaskCount.incrementAndGet();
                }

                @Override
                protected void afterExecute(Runnable r, Throwable t) {
                    activeTaskCount.decrementAndGet();
                    if (t != null) {
                        logger.error("Task execution failed", t);
                    }
                }
            };
        }

        public void submitTask(Runnable task) {
            executor.execute(() -> {
                try {
                    task.run();
                } catch (Exception e) {
                    logger.error("Task execution error", e);
                }
            });
        }
    }
}
```

#### 2.2 线程池监控
```java
public class ThreadPoolMonitor {
    private final ThreadPoolExecutor executor;
    private final ScheduledExecutorService monitorExecutor;

    public ThreadPoolMonitor(ThreadPoolExecutor executor) {
        this.executor = executor;
        this.monitorExecutor = Executors.newSingleThreadScheduledExecutor();
    }

    public void startMonitoring() {
        monitorExecutor.scheduleAtFixedRate(() -> {
            System.out.println(
                String.format("""
                    Thread Pool Statistics:
                    - Active Thread Count: %d
                    - Pool Size: %d
                    - Core Pool Size: %d
                    - Maximum Pool Size: %d
                    - Task Count: %d
                    - Completed Task Count: %d
                    - Queue Size: %d
                    """,
                    executor.getActiveCount(),
                    executor.getPoolSize(),
                    executor.getCorePoolSize(),
                    executor.getMaximumPoolSize(),
                    executor.getTaskCount(),
                    executor.getCompletedTaskCount(),
                    executor.getQueue().size()
                )
            );
        }, 0, 5, TimeUnit.SECONDS);
    }
}
```

### 3. 并发工具类

#### 3.1 CountDownLatch使用
```java
public class CountDownLatchExample {
    public void coordinateWork() {
        int workerCount = 3;
        CountDownLatch startSignal = new CountDownLatch(1);
        CountDownLatch doneSignal = new CountDownLatch(workerCount);

        for (int i = 0; i < workerCount; i++) {
            new Thread(() -> {
                try {
                    startSignal.await(); // 等待开始信号
                    doWork();
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                } finally {
                    doneSignal.countDown(); // 完成工作
                }
            }).start();
        }

        // 发送开始信号
        startSignal.countDown();
        
        try {
            // 等待所有工作完成
            doneSignal.await();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
```

#### 3.2 CyclicBarrier使用
```java
public class CyclicBarrierExample {
    public void coordinateIterativeWork() {
        int parties = 3;
        CyclicBarrier barrier = new CyclicBarrier(parties, () -> {
            // 每次所有线程到达屏障时执行
            System.out.println("All parties have arrived at the barrier");
        });

        for (int i = 0; i < parties; i++) {
            new Thread(() -> {
                try {
                    for (int j = 0; j < 3; j++) { // 执行3轮
                        doWork();
                        System.out.println(Thread.currentThread().getName() + 
                            " waiting at barrier");
                        barrier.await(); // 等待其他线程
                        System.out.println(Thread.currentThread().getName() + 
                            " crossed barrier");
                    }
                } catch (Exception e) {
                    Thread.currentThread().interrupt();
                }
            }).start();
        }
    }
}
```

#### 3.3 Semaphore使用
```java
public class SemaphoreExample {
    public class ConnectionPool {
        private final Semaphore semaphore;
        private final List<Connection> connections;

        public ConnectionPool(int poolSize) {
            this.semaphore = new Semaphore(poolSize);
            this.connections = new ArrayList<>(poolSize);
            for (int i = 0; i < poolSize; i++) {
                connections.add(createConnection());
            }
        }

        public Connection acquire() throws InterruptedException {
            semaphore.acquire();
            return getConnection();
        }

        public void release(Connection connection) {
            returnConnection(connection);
            semaphore.release();
        }

        private synchronized Connection getConnection() {
            // 获取连接的具体实现
            return connections.remove(connections.size() - 1);
        }

        private synchronized void returnConnection(Connection connection) {
            // 归还连接的具体实现
            connections.add(connection);
        }
    }
}
```

### 4. 并发集合

#### 4.1 ConcurrentHashMap实现原理
```java
public class ConcurrentMapExample {
    private ConcurrentHashMap<String, Integer> map = new ConcurrentHashMap<>();

    public void demonstrateOperations() {
        // 1. 原子操作
        map.computeIfAbsent("key", k -> calculateValue(k));

        // 2. 原子更新
        map.merge("counter", 1, Integer::sum);

        // 3. 批量操作
        map.forEach(1, (key, value) -> {
            System.out.println(key + ": " + value);
        });

        // 4. 搜索
        Optional<String> result = map.search(1, (key, value) -> {
            if (value > 100) {
                return key;
            }
            return null;
        });
    }

    // 自定义并发Map实现
    public class CustomConcurrentMap<K, V> {
        private static final int SEGMENTS = 16;
        private final Object[] locks;
        private final Map<K, V>[] segments;

        @SuppressWarnings("unchecked")
        public CustomConcurrentMap() {
            this.locks = new Object[SEGMENTS];
            this.segments = new Map[SEGMENTS];
            for (int i = 0; i < SEGMENTS; i++) {
                locks[i] = new Object();
                segments[i] = new HashMap<>();
            }
        }

        private int getSegment(K key) {
            return Math.abs(key.hashCode() % SEGMENTS);
        }

        public V put(K key, V value) {
            int segment = getSegment(key);
            synchronized (locks[segment]) {
                return segments[segment].put(key, value);
            }
        }

        public V get(K key) {
            int segment = getSegment(key);
            synchronized (locks[segment]) {
                return segments[segment].get(key);
            }
        }
    }
}
```

#### 4.2 BlockingQueue实现
```java
public class BlockingQueueExample {
    public class BoundedBuffer<T> {
        private final Object[] items;
        private int putIndex, takeIndex, count;

        public BoundedBuffer(int capacity) {
            items = new Object[capacity];
        }

        public synchronized void put(T x) throws InterruptedException {
            while (count == items.length) {
                wait();
            }
            items[putIndex] = x;
            if (++putIndex == items.length) {
                putIndex = 0;
            }
            count++;
            notifyAll();
        }

        @SuppressWarnings("unchecked")
        public synchronized T take() throws InterruptedException {
            while (count == 0) {
                wait();
            }
            Object x = items[takeIndex];
            if (++takeIndex == items.length) {
                takeIndex = 0;
            }
            count--;
            notifyAll();
            return (T) x;
        }
    }

    // 生产者-消费者示例
    public void producerConsumerExample() {
        BlockingQueue<String> queue = new ArrayBlockingQueue<>(10);

        // 生产者
        CompletableFuture.runAsync(() -> {
            try {
                for (int i = 0; i < 20; i++) {
                    queue.put("Item " + i);
                    System.out.println("Produced: Item " + i);
                    Thread.sleep(100);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });

        // 消费者
        CompletableFuture.runAsync(() -> {
            try {
                while (true) {
                    String item = queue.take();
                    System.out.println("Consumed: " + item);
                    Thread.sleep(200);
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
    }
}
```

### 5. 线程安全性保证

#### 5.1 synchronized的底层实现
```java
public class SynchronizedExample {
    // 对象锁
    private final Object lock = new Object();
    private int count = 0;

    public void synchronizedBlock() {
        synchronized (lock) {
            count++;
            // 其他操作
        }
    }

    // 方法锁
    public synchronized void synchronizedMethod() {
        count++;
        // 其他操作
    }

    // 类锁
    public static synchronized void synchronizedStaticMethod() {
        // 静态方法同步
    }
}
```

#### 5.2 volatile的使用
```java
public class VolatileExample {
    private volatile boolean flag = false;
    private volatile long value = 0L;

    // 写线程
    public void writer() {
        flag = true;                // 写入flag
        value = System.nanoTime();  // 写入value
    }

    // 读线程
    public void reader() {
        if (flag) {                 // 读取flag
            System.out.println(value);  // 读取value
        }
    }
}
```

#### 5.3 原子类的使用
```java
public class AtomicExample {
    private AtomicInteger counter = new AtomicInteger(0);
    private AtomicReference<User> userRef = new AtomicReference<>();

    public void atomicOperations() {
        // 原子递增
        counter.incrementAndGet();

        // CAS操作
        int oldValue = counter.get();
        while (!counter.compareAndSet(oldValue, oldValue + 1)) {
            oldValue = counter.get();
        }

        // 原子引用更新
        userRef.updateAndGet(user -> {
            if (user == null) {
                return new User("default");
            }
            return new User(user.getName() + "_updated");
        });
    }

    // 自定义原子操作类
    public class AtomicCounter {
        private volatile long value;
        private final AtomicLongFieldUpdater<AtomicCounter> updater =
            AtomicLongFieldUpdater.newUpdater(AtomicCounter.class, "value");

        public long increment() {
            return updater.incrementAndGet(this);
        }

        public long decrement() {
            return updater.decrementAndGet(this);
        }

        public long get() {
            return value;
        }
    }
} 