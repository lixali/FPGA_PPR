

class Graph:
    def __init__(self):
        self.nodes = {}
        self.node_cnt = 0
        self.edge_cnt = 0

    def add_edge(self, u_id, v_id):
        if u_id not in self.nodes:
            self.nodes[u_id] = Node(u_id)
        self.nodes[u_id].add_degree()
        self.nodes[u_id].add_neighbor(v_id)

        if v_id not in self.nodes:
            self.nodes[v_id] = Node(v_id)
        self.nodes[v_id].add_degree()
        self.nodes[v_id].add_neighbor(u_id)

        self.node_cnt = len(self.nodes)
        self.edge_cnt += 1

class Node:
    def __init__(self, node_id):
        self.node_id = node_id
        self.degree = 0
        self.is_seed = False
        self.counters = {}
        self.neighbors = []
        self.s_u_a_score = 0

    def add_degree(self):
        self.degree += 1

    def add_neighbor(self, n):
        self.neighbors.append(n)

