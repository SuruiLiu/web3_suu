# Java基础学习指南

## 一、面向对象编程基础

### 1. 类与对象
#### 1.1 基本概念
- **类的定义**：类是对象的模板，定义了对象的属性和行为
- **对象的创建**：使用new关键字实例化对象
- **构造方法**：对象初始化的特殊方法
- **this关键字**：指向当前对象的引用

```java
public class Student {
    // 属性（成员变量）
    private String name;
    private int age;
    
    // 构造方法
    public Student(String name, int age) {
        this.name = name;
        this.age = age;
    }
    
    // 方法
    public void study() {
        System.out.println(this.name + "正在学习");
    }
}
```

#### 1.2 成员变量与方法
- **成员变量**：定义对象的属性
- **实例方法**：定义对象的行为
- **静态成员**：使用static关键字修饰，属于类而不是对象
- **访问控制**：public、private、protected和默认访问级别

### 2. 继承与多态
#### 2.1 继承
- **extends关键字**：实现类的继承
- **方法重写**：子类重写父类的方法
- **super关键字**：调用父类的构造方法和成员

```java
public class Person {
    protected String name;
    
    public Person(String name) {
        this.name = name;
    }
    
    public void introduce() {
        System.out.println("我是" + name);
    }
}

public class Teacher extends Person {
    private String subject;
    
    public Teacher(String name, String subject) {
        super(name);
        this.subject = subject;
    }
    
    @Override
    public void introduce() {
        super.introduce();
        System.out.println("我教授" + subject);
    }
}
```

#### 2.2 多态
- **向上转型**：父类引用指向子类对象
- **方法的动态绑定**：运行时确定调用的方法
- **instanceof运算符**：检查对象的类型

### 3. 接口与抽象类
#### 3.1 抽象类
- **abstract关键字**：定义抽象类和抽象方法
- **抽象方法**：没有实现的方法，子类必须实现
- **抽象类的特点**：不能实例化，可以包含普通方法

```java
public abstract class Shape {
    protected String color;
    
    public abstract double getArea();
    
    public void setColor(String color) {
        this.color = color;
    }
}
```

#### 3.2 接口
- **interface关键字**：定义接口
- **默认方法**：接口中可以有默认实现的方法
- **静态方法**：接口中的静态方法
- **多接口实现**：一个类可以实现多个接口

```java
public interface Flyable {
    void fly();
    
    default void land() {
        System.out.println("正常降落");
    }
}
```

## 二、Java核心机制

### 1. 异常处理
#### 1.1 异常体系
- **Throwable类**：所有异常的父类
- **Error**：严重错误，程序无法处理
- **Exception**：可以处理的异常
- **RuntimeException**：运行时异常

#### 1.2 异常处理机制
- **try-catch-finally**：异常捕获和处理
- **throws关键字**：声明方法可能抛出的异常
- **throw关键字**：手动抛出异常

```java
public class ExceptionDemo {
    public void readFile(String path) throws IOException {
        try {
            FileReader reader = new FileReader(path);
            // 读取文件操作
        } catch (FileNotFoundException e) {
            throw new RuntimeException("文件不存在", e);
        } finally {
            // 清理资源
        }
    }
}
```

### 2. 反射机制
#### 2.1 反射基础概念
- **什么是反射**：在运行时检查、修改类和对象的能力
- **反射的用途**：
  - 在运行时检查类的结构
  - 动态创建对象和调用方法
  - 实现框架的依赖注入
  - 支持注解处理
  - 实现动态代理

#### 2.2 获取Class对象的三种方式
```java
// 1. 通过类名.class
Class<String> clazz1 = String.class;

// 2. 通过对象.getClass()
String str = "Hello";
Class<?> clazz2 = str.getClass();

// 3. 通过Class.forName()
Class<?> clazz3 = Class.forName("java.lang.String");
```

#### 2.3 反射API详解
1. **获取类信息**
```java
public class ReflectionAPIDemo {
    public void getClassInfo(Class<?> clazz) {
        // 获取所有public方法（包括继承的）
        Method[] methods = clazz.getMethods();
        
        // 获取当前类声明的所有方法（不包括继承的）
        Method[] declaredMethods = clazz.getDeclaredMethods();
        
        // 获取所有public字段
        Field[] fields = clazz.getFields();
        
        // 获取所有构造器
        Constructor<?>[] constructors = clazz.getConstructors();
        
        // 获取类的修饰符
        int modifiers = clazz.getModifiers();
        boolean isPublic = Modifier.isPublic(modifiers);
    }
}
```

2. **创建对象和调用方法**
```java
public class ReflectionCreateDemo {
    public void createAndInvoke() throws Exception {
        Class<?> clazz = Class.forName("com.example.User");
        
        // 创建对象
        Constructor<?> constructor = clazz.getConstructor(String.class, int.class);
        Object user = constructor.newInstance("张三", 25);
        
        // 获取并调用方法
        Method method = clazz.getMethod("setName", String.class);
        method.invoke(user, "李四");
        
        // 访问私有成员
        Field field = clazz.getDeclaredField("age");
        field.setAccessible(true); // 设置可访问
        field.set(user, 30);
    }
}
```

3. **反射的实际应用**
```java
public class SimpleIOC {
    private Map<String, Object> beans = new HashMap<>();
    
    public Object getBean(String name) throws Exception {
        // 模拟IOC容器获取bean
        Class<?> clazz = Class.forName(name);
        Object obj = clazz.newInstance();
        // 处理依赖注入
        for (Field field : clazz.getDeclaredFields()) {
            if (field.isAnnotationPresent(Autowired.class)) {
                field.setAccessible(true);
                field.set(obj, getBean(field.getType().getName()));
            }
        }
        return obj;
    }
}
```

### 3. 泛型
#### 3.1 泛型详解
1. **为什么需要泛型**
   - 提供编译时类型检查
   - 消除类型转换
   - 实现通用算法

2. **泛型类型**
```java
// 泛型类
public class Box<T> {
    private T value;
    
    public void set(T value) { this.value = value; }
    public T get() { return value; }
}

// 泛型接口
public interface Comparable<T> {
    int compareTo(T other);
}

// 泛型方法
public class Util {
    public static <T> void swap(T[] array, int i, int j) {
        T temp = array[i];
        array[i] = array[j];
        array[j] = temp;
    }
}
```

3. **类型边界**
```java
// 上界通配符
public void processNumbers(List<? extends Number> numbers) {
    for (Number num : numbers) {
        System.out.println(num.doubleValue());
    }
}

// 下界通配符
public void addNumbers(List<? super Integer> list) {
    list.add(1);
    list.add(2);
}

// 多重边界
public class Calculator<T extends Number & Comparable<T>> {
    public T max(T x, T y) {
        return x.compareTo(y) > 0 ? x : y;
    }
}
```

4. **类型擦除**
```java
// 泛型擦除示例
public class ErasureExample<T> {
    private T data;
    
    public void setData(T data) {
        this.data = data;
    }
    
    // 编译后实际变成：
    // private Object data;
    // public void setData(Object data) {
    //     this.data = data;
    // }
}
```

5. **实际应用示例**
```java
public class GenericDAO<T> {
    private Class<T> entityClass;
    
    public GenericDAO(Class<T> entityClass) {
        this.entityClass = entityClass;
    }
    
    public T findById(long id) {
        // 模拟数据库查询
        try {
            T entity = entityClass.newInstance();
            // 设置属性
            return entity;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
    public List<T> findAll() {
        List<T> result = new ArrayList<>();
        // 实现查询逻辑
        return result;
    }
}

// 使用示例
public class UserDAO extends GenericDAO<User> {
    public UserDAO() {
        super(User.class);
    }
    
    // 特定于User的方法
    public List<User> findByAge(int age) {
        // 实现查询逻辑
        return new ArrayList<>();
    }
}
```

#### 3.2 泛型最佳实践
1. **PECS原则**
   - Producer Extends, Consumer Super
   - 当你需要从集合中读取类型T的数据时，使用 `? extends T`
   - 当你需要向集合中写入类型T的数据时，使用 `? super T`

```java
public class PECSExample {
    // Producer - 只读取数据
    public void copyElements(List<? extends Number> source, 
                           List<? super Number> dest) {
        for (Number number : source) {
            dest.add(number);
        }
    }
    
    // Consumer - 只写入数据
    public void addNumbers(List<? super Integer> list) {
        list.add(1);
        list.add(2);
    }
}
```

2. **类型安全的异构容器**
```java
public class TypeSafeMap {
    private Map<Class<?>, Object> map = new HashMap<>();
    
    public <T> void put(Class<T> type, T value) {
        map.put(type, value);
    }
    
    public <T> T get(Class<T> type) {
        return type.cast(map.get(type));
    }
}
```

## 三、Java集合框架详解

### 1. Collection接口体系

#### 1.1 List接口实现类
1. **ArrayList**
   - **实现原理**：基于动态数组实现
   - **特点**：
     - 随机访问效率高 O(1)
     - 尾部插入删除效率高
     - 中间插入删除需要移动元素
     - 扩容机制：当前容量的1.5倍
   - **适用场景**：
     - 频繁随机访问
     - 尾部插入删除较多
     - 元素数量可预知
   ```java
   // ArrayList实现原理示例
   public class SimpleArrayList<E> {
       private static final int DEFAULT_CAPACITY = 10;
       private Object[] elementData;
       private int size;
       
       public boolean add(E element) {
           ensureCapacity(size + 1);
           elementData[size++] = element;
           return true;
       }
       
       private void ensureCapacity(int minCapacity) {
           if (minCapacity > elementData.length) {
               int newCapacity = Math.max(elementData.length * 3/2, minCapacity);
               elementData = Arrays.copyOf(elementData, newCapacity);
           }
       }
   }
   ```

2. **LinkedList**
   - **实现原理**：双向链表
   - **特点**：
     - 随机访问效率低 O(n)
     - 任意位置插入删除效率高 O(1)
     - 内存占用较高（需要存储前后节点引用）
   - **适用场景**：
     - 频繁在任意位置插入删除
     - 实现队列或栈
     - 不需要随机访问
   ```java
   // LinkedList实现原理示例
   public class SimpleLinkedList<E> {
       private static class Node<E> {
           E item;
           Node<E> next;
           Node<E> prev;
           
           Node(Node<E> prev, E element, Node<E> next) {
               this.item = element;
               this.next = next;
               this.prev = prev;
           }
       }
       
       private Node<E> first;
       private Node<E> last;
       private int size;
       
       public void add(E element) {
           final Node<E> l = last;
           final Node<E> newNode = new Node<>(l, element, null);
           last = newNode;
           if (l == null)
               first = newNode;
           else
               l.next = newNode;
           size++;
       }
   }
   ```

#### 1.2 Set接口实现类
1. **HashSet**
   - **实现原理**：基于HashMap实现
   - **特点**：
     - 不允许重复元素
     - 无序
     - 查找效率高 O(1)
   - **适用场景**：
     - 需要去重
     - 不关心元素顺序
     - 频繁查找
   ```java
   // HashSet原理示例（基于HashMap）
   public class SimpleHashSet<E> {
       private static final Object PRESENT = new Object();
       private HashMap<E, Object> map;
       
       public boolean add(E e) {
           return map.put(e, PRESENT) == null;
       }
       
       public boolean contains(Object o) {
           return map.containsKey(o);
       }
   }
   ```

2. **TreeSet**
   - **实现原理**：基于红黑树（TreeMap）
   - **特点**：
     - 有序（自然顺序或自定义比较器）
     - 查找效率 O(log n)
     - 插入删除效率 O(log n)
   - **适用场景**：
     - 需要有序集合
     - 需要范围查询
     - 对查询效率要求不是特别高
   ```java
   // TreeSet使用示例
   public class TreeSetDemo {
       public void demo() {
           // 自然顺序
           TreeSet<Integer> numbers = new TreeSet<>();
           numbers.add(5);
           numbers.add(2);
           numbers.add(8);
           // 输出：2, 5, 8
           
           // 自定义比较器
           TreeSet<Person> persons = new TreeSet<>((p1, p2) -> 
               p1.getAge() - p2.getAge());
           persons.add(new Person("张三", 25));
           persons.add(new Person("李四", 20));
           // 按年龄排序
       }
   }
   ```

### 2. Map接口实现类

#### 2.1 HashMap
1. **实现原理**
   - 基于哈希表（数组 + 链表/红黑树）
   - 链表长度超过8转换为红黑树
   - 负载因子0.75，容量是2的幂
   ```java
   // HashMap原理示例
   public class SimpleHashMap<K,V> {
       private static final int DEFAULT_CAPACITY = 16;
       private static final float LOAD_FACTOR = 0.75f;
       
       private Entry<K,V>[] table;
       private int size;
       
       static class Entry<K,V> {
           final int hash;
           final K key;
           V value;
           Entry<K,V> next;
           
           Entry(int hash, K key, V value, Entry<K,V> next) {
               this.hash = hash;
               this.key = key;
               this.value = value;
               this.next = next;
           }
       }
       
       public V put(K key, V value) {
           int hash = hash(key);
           int index = indexFor(hash, table.length);
           // 处理冲突和扩容逻辑
       }
       
       private int hash(Object key) {
           return key == null ? 0 : key.hashCode() ^ (key.hashCode() >>> 16);
       }
   }
   ```

2. **性能优化**
   - 初始容量设置
   - 自定义hashCode和equals
   - 避免哈希冲突
   ```java
   public class HashMapOptimization {
       // 已知大约需要存储1000个元素
       Map<String, User> userMap = new HashMap<>(1024); // 2的幂，大于1000/0.75
       
       // 自定义对象作为key
       public class CacheKey {
           private String name;
           private long timestamp;
           
           @Override
           public int hashCode() {
               return Objects.hash(name, timestamp);
           }
           
           @Override
           public boolean equals(Object obj) {
               if (this == obj) return true;
               if (!(obj instanceof CacheKey)) return false;
               CacheKey other = (CacheKey) obj;
               return Objects.equals(name, other.name) 
                   && timestamp == other.timestamp;
           }
       }
   }
   ```

#### 2.2 ConcurrentHashMap
1. **实现原理**
   - JDK 1.8基于CAS和synchronized实现
   - 分段锁设计
   - 并发度提升
   ```java
   public class ConcurrentMapDemo {
       private ConcurrentHashMap<String, AtomicInteger> countMap = 
           new ConcurrentHashMap<>();
           
       public void increment(String key) {
           countMap.computeIfAbsent(key, k -> new AtomicInteger())
                  .incrementAndGet();
       }
       
       public int get(String key) {
           AtomicInteger count = countMap.get(key);
           return count == null ? 0 : count.get();
       }
   }
   ```

### 3. 集合框架性能对比

#### 3.1 时间复杂度对比
```
操作          ArrayList   LinkedList   HashSet    TreeSet
添加(尾部)     O(1)        O(1)         O(1)       O(log n)
添加(中间)     O(n)        O(1)         O(1)       O(log n)
删除(尾部)     O(1)        O(1)         O(1)       O(log n)
删除(中间)     O(n)        O(1)         O(1)       O(log n)
查找          O(n)        O(n)         O(1)       O(log n)
```

#### 3.2 常见性能陷阱
1. **ArrayList**
   ```java
   public class ArrayListPitfalls {
       public void pitfalls() {
           // 错误：频繁中间插入
           List<Integer> list = new ArrayList<>();
           for (int i = 0; i < 10000; i++) {
               list.add(0, i); // 每次都需要移动元素
           }
           
           // 正确：使用LinkedList或在尾部插入
           List<Integer> linkedList = new LinkedList<>();
           for (int i = 0; i < 10000; i++) {
               linkedList.add(0, i);
           }
       }
   }
   ```

2. **HashMap**
   ```java
   public class HashMapPitfalls {
       public void pitfalls() {
           // 错误：hashCode相同导致性能下降
           Map<Point, String> map = new HashMap<>();
           class Point {
               int x, y;
               @Override
               public int hashCode() {
                   return 1; // 所有对象hashCode相同
               }
           }
           
           // 正确：合理的hashCode实现
           class GoodPoint {
               int x, y;
               @Override
               public int hashCode() {
                   return Objects.hash(x, y);
               }
           }
       }
   }
   ```

### 4. 集合框架最佳实践

#### 4.1 选择合适的集合
```java
public class CollectionChoice {
    // 1. 需要频繁随机访问
    List<User> userList = new ArrayList<>();
    
    // 2. 需要频繁插入删除
    List<Task> taskQueue = new LinkedList<>();
    
    // 3. 需要去重
    Set<String> uniqueNames = new HashSet<>();
    
    // 4. 需要排序
    Set<Score> scoreSet = new TreeSet<>();
    
    // 5. 需要键值对
    Map<String, User> userMap = new HashMap<>();
    
    // 6. 需要线程安全
    Map<String, Integer> concurrentMap = new ConcurrentHashMap<>();
}
```

#### 4.2 性能优化技巧
```java
public class CollectionOptimization {
    public void optimize() {
        // 1. 指定初始容量
        List<String> list = new ArrayList<>(1000);
        
        // 2. 批量操作
        List<String> batch = new ArrayList<>();
        for (int i = 0; i < 1000; i++) {
            batch.add("item" + i);
        }
        list.addAll(batch); // 一次性添加
        
        // 3. 使用适当的数据结构
        Set<String> set = new HashSet<>(list); // 去重
        List<String> uniqueList = new ArrayList<>(set); // 转回List
    }
}
```

#### 4.3 常见应用场景示例
```java
public class CollectionUseCases {
    // 1. 缓存实现
    private Map<String, Object> cache = new LinkedHashMap<>(16, 0.75f, true) {
        @Override
        protected boolean removeEldestEntry(Map.Entry eldest) {
            return size() > 100; // 限制缓存大小
        }
    };
    
    // 2. 优先级队列
    private PriorityQueue<Task> taskQueue = new PriorityQueue<>((t1, t2) -> 
        t1.getPriority() - t2.getPriority());
    
    // 3. 统计频率
    public Map<String, Integer> wordFrequency(List<String> words) {
        return words.stream()
            .collect(Collectors.groupingBy(
                w -> w,
                Collectors.collectingAndThen(
                    Collectors.counting(),
                    Long::intValue
                )
            ));
    }
}
```

## 实践项目建议

1. **学生信息管理系统**
   - 实践面向对象编程
   - 使用集合框架存储数据
   - 实现基本的CRUD操作

2. **自定义集合类**
   - 实现简单的ArrayList
   - 实现简单的LinkedList
   - 理解数据结构原理

3. **注解处理工具**
   - 创建自定义注解
   - 实现注解处理器
   - 应用反射机制

## 学习资源

1. **推荐书籍**
   - 《Java核心技术卷I》
   - 《Effective Java》
   - 《Java编程思想》

2. **在线资源**
   - Oracle Java官方文档
   - GitHub优秀开源项目
   - Stack Overflow

3. **练习建议**
   - 每个概念都要动手实践
   - 从简单到复杂循序渐进
   - 注重代码质量和设计模式

## 学习成果检验

1. **掌握程度评估**
   - 能够独立编写类和接口
   - 理解并正确使用继承和多态
   - 熟练使用集合框架
   - 理解并应用反射机制

2. **进阶方向**
   - 设计模式
   - Java8新特性
   - 函数式编程
   - 并发编程基础 