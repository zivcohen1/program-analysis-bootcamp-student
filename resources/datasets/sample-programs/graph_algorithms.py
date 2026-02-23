"""Basic graph algorithms."""

from collections import deque, defaultdict


class Graph:
    def __init__(self, directed=False):
        self.adj = defaultdict(list)
        self.directed = directed

    def add_edge(self, u, v, weight=1):
        """Add an edge between u and v."""
        self.adj[u].append((v, weight))
        if not self.directed:
            self.adj[v].append((u, weight))

    def vertices(self):
        """Return all vertices."""
        verts = set(self.adj.keys())
        for neighbors in self.adj.values():
            for v, _ in neighbors:
                verts.add(v)
        return verts

    def bfs(self, start):
        """Breadth-first search from start. Returns visited order."""
        visited = set()
        order = []
        queue = deque([start])
        visited.add(start)
        while queue:
            node = queue.popleft()
            order.append(node)
            for neighbor, _ in self.adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)
        return order

    def dfs(self, start):
        """Depth-first search from start. Returns visited order."""
        visited = set()
        order = []

        def _dfs(node):
            visited.add(node)
            order.append(node)
            for neighbor, _ in self.adj[node]:
                if neighbor not in visited:
                    _dfs(neighbor)

        _dfs(start)
        return order

    def has_cycle(self):
        """Detect if the directed graph has a cycle."""
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {v: WHITE for v in self.vertices()}

        def _visit(node):
            color[node] = GRAY
            for neighbor, _ in self.adj[node]:
                if color.get(neighbor, WHITE) == GRAY:
                    return True
                if color.get(neighbor, WHITE) == WHITE and _visit(neighbor):
                    return True
            color[node] = BLACK
            return False

        for v in self.vertices():
            if color.get(v, WHITE) == WHITE:
                if _visit(v):
                    return True
        return False

    def topological_sort(self):
        """Topological sort for a DAG. Returns sorted list or None if cycle."""
        in_degree = defaultdict(int)
        for v in self.vertices():
            in_degree.setdefault(v, 0)
        for u in self.adj:
            for v, _ in self.adj[u]:
                in_degree[v] += 1

        queue = deque([v for v in self.vertices() if in_degree[v] == 0])
        order = []
        while queue:
            node = queue.popleft()
            order.append(node)
            for neighbor, _ in self.adj[node]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        if len(order) != len(self.vertices()):
            return None
        return order


if __name__ == "__main__":
    g = Graph()
    for u, v in [(1, 2), (1, 3), (2, 4), (3, 4), (4, 5)]:
        g.add_edge(u, v)
    print(f"BFS from 1: {g.bfs(1)}")
    print(f"DFS from 1: {g.dfs(1)}")
