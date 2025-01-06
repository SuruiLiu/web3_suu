# 分布式系统详解

## 第一部分：分布式系统基础

### 1. 什么是分布式系统

分布式系统是由多个独立计算机组成的系统，这些计算机通过网络相互连接和通信，对外呈现为一个统一的整体。

#### 1.1 基本特征
- **分布性**：系统组件分布在网络中的不同位置
- **并发性**：多个组件同时运行和交互
- **缺乏全局时钟**：难以确定全局事件发生的顺序
- **故障独立性**：部分组件的故障不应影响整体系统

#### 1.2 设计目标
```
1. 资源共享
2. 透明性
3. 开放性
4. 可扩展性
5. 容错性
6. 一致性
```

### 2. CAP 理论

#### 2.1 三个核心特性
```
C (Consistency): 一致性
- 所有节点在同一时间看到的数据是一致的

A (Availability): 可用性
- 服务在正常响应时间内返回合理的响应

P (Partition Tolerance): 分区容错性
- 系统在网络分区的情况下仍能继续运行
```

#### 2.2 CAP 权衡
```java
public enum CAPChoice {
    CP,  // 一致性+分区容错 (如：ZooKeeper)
    AP,  // 可用性+分区容错 (如：Cassandra)
    CA   // 一致性+可用性 (如：传统关系数据库)
}

public class SystemDesign {
    private CAPChoice choice;
    
    public SystemDesign(CAPChoice choice) {
        this.choice = choice;
        switch(choice) {
            case CP:
                configureForConsistency();
                break;
            case AP:
                configureForAvailability();
                break;
            case CA:
                configureForLocalTransaction();
                break;
        }
    }
}
```

### 3. 分布式一致性

#### 3.1 强一致性
```java
public interface StrongConsistency {
    // 同步写入所有节点
    CompletableFuture<Boolean> syncWrite(String key, String value);
    
    // 读取最新值
    String read(String key);
}

public class StrongConsistencyImpl implements StrongConsistency {
    private List<Node> nodes;
    
    @Override
    public CompletableFuture<Boolean> syncWrite(String key, String value) {
        return CompletableFuture.allOf(
            nodes.stream()
                .map(node -> node.write(key, value))
                .toArray(CompletableFuture[]::new)
        ).thenApply(v -> true);
    }
}
```

#### 3.2 最终一致性
```java
public interface EventualConsistency {
    // 异步写入
    void asyncWrite(String key, String value);
    
    // 读取可能不是最新值
    String read(String key);
    
    // 检查一致性状态
    boolean isConsistent(String key);
}
```

### 4. 分布式事务

#### 4.1 两阶段提交（2PC）
```java
public class TwoPhaseCommit {
    private List<Participant> participants;
    
    public boolean executeTransaction(Transaction tx) {
        // 阶段1：准备
        boolean allPrepared = participants.stream()
            .allMatch(p -> p.prepare(tx));
            
        if (!allPrepared) {
            participants.forEach(p -> p.rollback(tx));
            return false;
        }
        
        // 阶段2：提交
        participants.forEach(p -> p.commit(tx));
        return true;
    }
}
```

#### 4.2 三阶段提交（3PC）
```java
public class ThreePhaseCommit {
    private List<Participant> participants;
    
    public boolean executeTransaction(Transaction tx) {
        // 阶段1：CanCommit
        if (!canCommit(tx)) return false;
        
        // 阶段2：PreCommit
        if (!preCommit(tx)) {
            abort(tx);
            return false;
        }
        
        // 阶段3：DoCommit
        return doCommit(tx);
    }
}
```

## 第二部分：分布式系统架构

### 1. 架构模式

#### 1.1 主从架构
```java
public class MasterSlaveArchitecture {
    private Node master;
    private List<Node> slaves;
    
    public void write(String data) {
        // 写入主节点
        master.write(data);
        // 异步复制到从节点
        slaves.forEach(slave -> 
            CompletableFuture.runAsync(() -> slave.replicate(data))
        );
    }
    
    public String read() {
        // 负载均衡读取
        return slaves.get(random.nextInt(slaves.size())).read();
    }
}
```

#### 1.2 P2P 架构
```java
public class P2PNode {
    private Set<Node> peers;
    private RoutingTable routingTable;
    
    public void broadcast(Message message) {
        peers.forEach(peer -> 
            CompletableFuture.runAsync(() -> peer.send(message))
        );
    }
    
    public void join(Node node) {
        // 加入网络
        routingTable.addPeer(node);
        // 通知其他节点
        broadcast(new JoinMessage(node));
    }
}
```

### 2. 负载均衡

#### 2.1 负载均衡策略
```java
public interface LoadBalancer {
    Node selectNode(List<Node> nodes, Request request);
}

public class RoundRobinLoadBalancer implements LoadBalancer {
    private AtomicInteger counter = new AtomicInteger(0);
    
    @Override
    public Node selectNode(List<Node> nodes, Request request) {
        int index = counter.getAndIncrement() % nodes.size();
        return nodes.get(index);
    }
}

public class WeightedLoadBalancer implements LoadBalancer {
    @Override
    public Node selectNode(List<Node> nodes, Request request) {
        return nodes.stream()
            .max(Comparator.comparingInt(Node::getWeight))
            .orElseThrow();
    }
}
```

#### 2.2 服务发现
```java
public interface ServiceDiscovery {
    List<ServiceInstance> getInstances(String serviceId);
    void register(ServiceInstance instance);
    void deregister(ServiceInstance instance);
}
```

### 3. 分布式存储

#### 3.1 数据分片
```java
public interface ShardingStrategy {
    int calculateShard(String key, int totalShards);
}

public class ConsistentHashing implements ShardingStrategy {
    private TreeMap<Integer, Node> ring = new TreeMap<>();
    
    @Override
    public int calculateShard(String key, int totalShards) {
        int hash = hash(key);
        Map.Entry<Integer, Node> entry = ring.ceilingEntry(hash);
        return entry != null ? entry.getValue().getShardId() : 
            ring.firstEntry().getValue().getShardId();
    }
}
```

#### 3.2 数据复制
```java
public interface ReplicationStrategy {
    List<Node> selectReplicaNodes(String key, int replicationFactor);
}

public class QuorumReplication {
    private final int R; // 读quorum
    private final int W; // 写quorum
    private final int N; // 总副本数
    
    public boolean write(String key, String value) {
        int successWrites = writeToNodes(key, value);
        return successWrites >= W;
    }
    
    public String read(String key) {
        List<String> values = readFromNodes(key);
        return selectMostRecent(values);
    }
}
```

## 第三部分：分布式系统问题

### 1. 分布式锁

#### 1.1 基于 Redis 的实现
```java
public class RedisDistributedLock {
    private RedisTemplate redis;
    
    public boolean lock(String key, String value, long expireTime) {
        return redis.opsForValue()
            .setIfAbsent(key, value, expireTime, TimeUnit.MILLISECONDS);
    }
    
    public boolean unlock(String key, String value) {
        String script = "if redis.call('get',KEYS[1]) == ARGV[1] then " +
                       "return redis.call('del',KEYS[1]) else return 0 end";
        return redis.execute(script, Arrays.asList(key), value);
    }
}
```

#### 1.2 基于 ZooKeeper 的实现
```java
public class ZookeeperDistributedLock {
    private ZooKeeper zk;
    private String lockPath;
    
    public boolean lock() throws Exception {
        String path = zk.create(lockPath, null, 
            ZooDefs.Ids.OPEN_ACL_UNSAFE, CreateMode.EPHEMERAL_SEQUENTIAL);
        return waitForLock(path);
    }
    
    private boolean waitForLock(String path) {
        try {
            List<String> nodes = zk.getChildren(lockPath, true);
            Collections.sort(nodes);
            if (path.equals(nodes.get(0))) {
                return true;
            }
            // 等待前一个节点删除
            return waitForDelete(nodes.get(nodes.indexOf(path) - 1));
        } catch (Exception e) {
            return false;
        }
    }
}
```

### 2. 分布式缓存

#### 2.1 缓存策略
```java
public interface CacheStrategy {
    void put(String key, String value);
    String get(String key);
    void invalidate(String key);
}

public class WriteThrough implements CacheStrategy {
    private Cache cache;
    private Storage storage;
    
    @Override
    public void put(String key, String value) {
        storage.write(key, value);
        cache.put(key, value);
    }
}

public class WriteBack implements CacheStrategy {
    private Cache cache;
    private Storage storage;
    private Queue<WriteOperation> writeQueue;
    
    @Override
    public void put(String key, String value) {
        cache.put(key, value);
        writeQueue.offer(new WriteOperation(key, value));
    }
}
```

#### 2.2 缓存一致性
```java
public class CacheConsistency {
    private Cache cache;
    private Storage storage;
    
    public void update(String key, String value) {
        // 先使缓存失效
        cache.invalidate(key);
        // 更新存储
        storage.update(key, value);
    }
    
    public String read(String key) {
        String value = cache.get(key);
        if (value == null) {
            value = storage.read(key);
            cache.put(key, value);
        }
        return value;
    }
}
```

### 3. 分布式消息队列

#### 3.1 消息投递语义
```java
public enum DeliverySemantics {
    AT_MOST_ONCE,    // 最多一次
    AT_LEAST_ONCE,   // 至少一次
    EXACTLY_ONCE     // 精确一次
}

public class MessageQueue {
    private DeliverySemantics semantics;
    
    public void send(Message message) {
        switch (semantics) {
            case AT_MOST_ONCE:
                sendWithoutAck(message);
                break;
            case AT_LEAST_ONCE:
                sendWithRetry(message);
                break;
            case EXACTLY_ONCE:
                sendWithDeduplication(message);
                break;
        }
    }
}
```

#### 3.2 消息顺序性
```java
public class OrderedMessageQueue {
    private Map<String, Queue<Message>> partitions;
    
    public void send(String key, Message message) {
        // 相同key的消息进入同一分区
        int partition = getPartition(key);
        partitions.get(partition).offer(message);
    }
    
    public void consume(String key, Consumer consumer) {
        int partition = getPartition(key);
        Queue<Message> queue = partitions.get(partition);
        while (!queue.isEmpty()) {
            consumer.consume(queue.poll());
        }
    }
}
```

## 第四部分：分布式系统监控

### 1. 监控指标

#### 1.1 系统指标
```java
public class SystemMetrics {
    // CPU 使用率
    public double getCpuUsage();
    
    // 内存使用率
    public double getMemoryUsage();
    
    // 磁盘 IO
    public double getDiskIO();
    
    // 网络流量
    public double getNetworkThroughput();
}
```

#### 1.2 业务指标
```java
public class BusinessMetrics {
    // QPS (每秒查询率)
    public double getQPS();
    
    // 响应时间
    public double getResponseTime();
    
    // 错误率
    public double getErrorRate();
    
    // 成功率
    public double getSuccessRate();
}
```

### 2. 链路追踪

#### 2.1 分布式追踪
```java
public class Trace {
    private String traceId;
    private String spanId;
    private String parentSpanId;
    private long timestamp;
    private Map<String, String> tags;
    
    public void addTag(String key, String value) {
        tags.put(key, value);
    }
}

public class TraceContext {
    private static ThreadLocal<Trace> context = new ThreadLocal<>();
    
    public static void setTrace(Trace trace) {
        context.set(trace);
    }
    
    public static Trace getTrace() {
        return context.get();
    }
}
```

#### 2.2 日志聚合
```java
public interface LogCollector {
    void collect(LogEvent event);
}

public class ElasticsearchLogCollector implements LogCollector {
    private ElasticsearchClient client;
    
    @Override
    public void collect(LogEvent event) {
        // 添加追踪信息
        event.setTraceId(TraceContext.getTrace().getTraceId());
        // 存储到 Elasticsearch
        client.index(event);
    }
}
```

## 第五部分：分布式系统安全

### 1. 认证与授权

#### 1.1 分布式 Session
```java
public interface SessionManager {
    String createSession(User user);
    Session getSession(String sessionId);
    void invalidateSession(String sessionId);
}

public class RedisSessionManager implements SessionManager {
    private RedisTemplate redis;
    
    @Override
    public String createSession(User user) {
        String sessionId = generateSessionId();
        redis.opsForValue().set(
            sessionId, 
            user, 
            30, 
            TimeUnit.MINUTES
        );
        return sessionId;
    }
}
```

#### 1.2 JWT 认证
```java
public class JwtAuthentication {
    private String secret;
    
    public String generateToken(User user) {
        return Jwts.builder()
            .setSubject(user.getUsername())
            .setIssuedAt(new Date())
            .setExpiration(new Date(System.currentTimeMillis() + 86400000))
            .signWith(SignatureAlgorithm.HS512, secret)
            .compact();
    }
    
    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(secret).parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
```

### 2. 数据安全

#### 2.1 数据加密
```java
public interface EncryptionService {
    String encrypt(String data);
    String decrypt(String encryptedData);
}

public class AESEncryption implements EncryptionService {
    private SecretKey key;
    
    @Override
    public String encrypt(String data) {
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.ENCRYPT_MODE, key);
        return Base64.encode(cipher.doFinal(data.getBytes()));
    }
}
```

#### 2.2 数据脱敏
```java
public class DataMasking {
    public String maskPhoneNumber(String phone) {
        return phone.replaceAll("(\\d{3})\\d{4}(\\d{4})", "$1****$2");
    }
    
    public String maskEmail(String email) {
        return email.replaceAll("(\\w{3})\\w+(@\\w+)", "$1***$2");
    }
}
```

---

这个文档涵盖了分布式系统的主要方面：
1. 基础理论和概念
2. 系统架构设计
3. 常见问题和解决方案
4. 系统监控
5. 安全机制

需要我详细解释某个部分吗？ 