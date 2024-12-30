# 数据结构与算法 - 第3周：图论

## 1. 图的基本概念

### 1.1 什么是图？
图是由顶点（节点）和边组成的数据结构，用于表示元素之间的关系。

**示例**：社交网络关系
```
    Alice -------- Bob
      |            |
      |            |
    Charlie ----- David
```

### 1.2 图的分类
1. **按方向分**：
   - 有向图：边有方向
   - 无向图：边无方向

2. **按权重分**：
   - 带权图：边有权重
   - 无权图：边无权重

### 1.3 图的表示方法

#### 1. 邻接矩阵
```javascript
// 邻接矩阵表示
const graph = [
    [0, 1, 1, 0],  // Alice 与 Bob、Charlie 相连
    [1, 0, 0, 1],  // Bob 与 Alice、David 相连
    [1, 0, 0, 1],  // Charlie 与 Alice、David 相连
    [0, 1, 1, 0]   // David 与 Bob、Charlie 相连
];
```

**优缺点**：
- 优点：查找、修改快速 O(1)
- 缺点：空间消耗大 O(V²)

#### 2. 邻接表
```javascript
class Graph {
    constructor() {
        this.adjacencyList = new Map();
    }
    
    addVertex(vertex) {
        if (!this.adjacencyList.has(vertex)) {
            this.adjacencyList.set(vertex, []);
        }
    }
    
    addEdge(vertex1, vertex2) {
        this.adjacencyList.get(vertex1).push(vertex2);
        this.adjacencyList.get(vertex2).push(vertex1); // 无向图需要双向添加
    }
}

// 使用示例
const graph = new Graph();
graph.addVertex("Alice");
graph.addVertex("Bob");
graph.addEdge("Alice", "Bob");

// 结果：
// Map {
//   "Alice" => ["Bob"],
//   "Bob" => ["Alice"]
// }
```

**优缺点**：
- 优点：空间效率高，适合稀疏图
- 缺点：查找特定边需要 O(V) 时间

## 2. 图的遍历

### 2.1 深度优先搜索 (DFS)
```javascript
class Graph {
    dfs(startVertex) {
        const visited = new Set();
        
        const dfsHelper = (vertex) => {
            visited.add(vertex);
            console.log(vertex);  // 访问顶点
            
            const neighbors = this.adjacencyList.get(vertex);
            for (const neighbor of neighbors) {
                if (!visited.has(neighbor)) {
                    dfsHelper(neighbor);
                }
            }
        };
        
        dfsHelper(startVertex);
    }
}

// 使用示例
const g = new Graph();
// ... 添加顶点和边 ...
g.dfs("Alice");  // 从Alice开始深度优先遍历
```

**过程示例**：
```
     A
   /   \
  B     C
 /     / \
D     E   F

遍历顺序：A -> B -> D -> C -> E -> F
```

### 2.2 广度优先搜索 (BFS)
```javascript
class Graph {
    bfs(startVertex) {
        const visited = new Set();
        const queue = [startVertex];
        visited.add(startVertex);
        
        while (queue.length) {
            const vertex = queue.shift();
            console.log(vertex);  // 访问顶点
            
            const neighbors = this.adjacencyList.get(vertex);
            for (const neighbor of neighbors) {
                if (!visited.has(neighbor)) {
                    visited.add(neighbor);
                    queue.push(neighbor);
                }
            }
        }
    }
}

// 使用示例
const g = new Graph();
// ... 添加顶点和边 ...
g.bfs("Alice");  // 从Alice开始广度优先遍历
```

**过程示例**：
```
     A
   /   \
  B     C
 /     / \
D     E   F

遍历顺序：A -> B -> C -> D -> E -> F
```

## 3. 最短路径算法

### 3.1 Dijkstra算法
用于找到图中一个顶点到其他所有顶点的最短路径。

```javascript
class Graph {
    dijkstra(start) {
        const distances = new Map();
        const previous = new Map();
        const unvisited = new Set();
        
        // 初始化
        for (const vertex of this.adjacencyList.keys()) {
            distances.set(vertex, Infinity);
            previous.set(vertex, null);
            unvisited.add(vertex);
        }
        distances.set(start, 0);
        
        while (unvisited.size) {
            // 获取距离最小的顶点
            let minVertex = null;
            let minDistance = Infinity;
            for (const vertex of unvisited) {
                if (distances.get(vertex) < minDistance) {
                    minVertex = vertex;
                    minDistance = distances.get(vertex);
                }
            }
            
            if (minDistance === Infinity) break;
            
            unvisited.delete(minVertex);
            
            // 更新邻居的距离
            for (const neighbor of this.adjacencyList.get(minVertex)) {
                const distance = distances.get(minVertex) + this.getWeight(minVertex, neighbor);
                if (distance < distances.get(neighbor)) {
                    distances.set(neighbor, distance);
                    previous.set(neighbor, minVertex);
                }
            }
        }
        
        return { distances, previous };
    }
}
```

### 3.2 Floyd-Warshall算法
用于找到所有顶点对之间的最短路径。

```javascript
class Graph {
    floydWarshall() {
        const vertices = Array.from(this.adjacencyList.keys());
        const n = vertices.length;
        
        // 初始化距离矩阵
        const dist = Array(n).fill().map(() => Array(n).fill(Infinity));
        
        // 设置直接相连的边的权重
        vertices.forEach((i, idx) => {
            dist[idx][idx] = 0;
            this.adjacencyList.get(i).forEach(j => {
                const jIdx = vertices.indexOf(j);
                dist[idx][jIdx] = this.getWeight(i, j);
            });
        });
        
        // Floyd-Warshall核心算法
        for (let k = 0; k < n; k++) {
            for (let i = 0; i < n; i++) {
                for (let j = 0; j < n; j++) {
                    if (dist[i][k] + dist[k][j] < dist[i][j]) {
                        dist[i][j] = dist[i][k] + dist[k][j];
                    }
                }
            }
        }
        
        return dist;
    }
}
```

**使用场景**：
- 所有顶点对之间的最短路径
- 传递闭包问题
- 网络路由规划

## 4. 最小生成树算法

### 4.1 Kruskal算法
```javascript
class Graph {
    kruskal() {
        const edges = this.getAllEdges();
        edges.sort((a, b) => a.weight - b.weight);  // 按权重排序
        
        const uf = new UnionFind(this.adjacencyList.size);
        const mst = [];
        
        for (const edge of edges) {
            const { from, to, weight } = edge;
            if (uf.find(from) !== uf.find(to)) {  // 如果不会形成环
                uf.union(from, to);
                mst.push(edge);
            }
        }
        
        return mst;
    }
}
```

### 4.2 Prim算法
```javascript
class Graph {
    prim(start) {
        const visited = new Set();
        const mst = [];
        const minHeap = new PriorityQueue();
        
        // 从起始顶点开始
        visited.add(start);
        this.adjacencyList.get(start).forEach(neighbor => {
            minHeap.enqueue({
                vertex: neighbor,
                parent: start,
                weight: this.getWeight(start, neighbor)
            });
        });
        
        while (!minHeap.isEmpty() && visited.size < this.adjacencyList.size) {
            const { vertex, parent, weight } = minHeap.dequeue();
            
            if (visited.has(vertex)) continue;
            
            visited.add(vertex);
            mst.push({ from: parent, to: vertex, weight });
            
            // 将新顶点的邻居加入优先队列
            this.adjacencyList.get(vertex).forEach(neighbor => {
                if (!visited.has(neighbor)) {
                    minHeap.enqueue({
                        vertex: neighbor,
                        parent: vertex,
                        weight: this.getWeight(vertex, neighbor)
                    });
                }
            });
        }
        
        return mst;
    }
}
```

## 5. 图的应用

### 5.1 拓扑排序
```javascript
class Graph {
    topologicalSort() {
        const visited = new Set();
        const stack = [];
        
        const dfsHelper = (vertex) => {
            visited.add(vertex);
            
            const neighbors = this.adjacencyList.get(vertex);
            for (const neighbor of neighbors) {
                if (!visited.has(neighbor)) {
                    dfsHelper(neighbor);
                }
            }
            
            stack.push(vertex);
        };
        
        for (const vertex of this.adjacencyList.keys()) {
            if (!visited.has(vertex)) {
                dfsHelper(vertex);
            }
        }
        
        return stack.reverse();
    }
}
```

**应用场景**：
- 任务调度
- 课程安排
- 构建系统依赖

### 5.2 图的实际应用示例

#### 1. 社交网络分析
```javascript
class SocialNetwork extends Graph {
    // 查找共同好友
    findMutualFriends(user1, user2) {
        const friends1 = new Set(this.adjacencyList.get(user1));
        const friends2 = new Set(this.adjacencyList.get(user2));
        return [...friends1].filter(friend => friends2.has(friend));
    }
    
    // 计算社交距离
    socialDistance(user1, user2) {
        return this.bfsDistance(user1, user2);
    }
}
```

#### 2. 导航系统
```javascript
class NavigationSystem extends Graph {
    // 计算最短路线
    findShortestRoute(start, end) {
        const { distances, previous } = this.dijkstra(start);
        return this.reconstructPath(previous, start, end);
    }
    
    // 考虑交通状况的路线规划
    findOptimalRoute(start, end, trafficData) {
        // 根据交通数据调整边的权重
        this.updateEdgeWeights(trafficData);
        return this.findShortestRoute(start, end);
    }
}
```

## 6. 性能优化和注意事项

### 6.1 时间复杂度比较
| 算法 | 时间复杂度 | 空间复杂度 |
|-----|-----------|------------|
| DFS | O(V + E) | O(V) |
| BFS | O(V + E) | O(V) |
| Dijkstra | O(V² + E) | O(V) |
| Floyd-Warshall | O(V³) | O(V²) |
| Kruskal | O(E log E) | O(V) |
| Prim | O(E log V) | O(V) |

### 6.2 实践建议
1. 选择合适的图表示方法
   - 稠密图：邻接矩阵
   - 稀疏图：邻接表

2. 根据具体问题选择算法
   - 单源最短路径：Dijkstra
   - 所有点对最短路径：Floyd-Warshall
   - 最小生成树：Kruskal/Prim

3. 注意边界情况
   - 处理不连通的图
   - 处理负权边
   - 处理环

## 7. 练习题推荐
1. [课程表](https://leetcode.cn/problems/course-schedule/) - 拓扑排序
2. [网络延迟时间](https://leetcode.cn/problems/network-delay-time/) - Dijkstra算法
3. [找到最终的安全状态](https://leetcode.cn/problems/find-eventual-safe-states/) - DFS
4. [冗余连接](https://leetcode.cn/problems/redundant-connection/) - 并查集 