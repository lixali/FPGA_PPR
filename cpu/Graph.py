import re
import random
from random import sample 

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
    
    def get_size(self):
        return self.node_cnt, self.edge_cnt

class Node:
    def __init__(self, node_id):
        self.node_id = node_id
        self.degree = 0
        self.is_seed = False
        self.counters = {}
        self.neighbors = []
        self.s_u_a_score = 0
        self.depth = -1

    def add_degree(self):
        self.degree += 1

    def add_neighbor(self, n):
        self.neighbors.append(n)


def Load_Graph( graph_file ):
    print("Loading graph from " + graph_file)
    
    f = open(graph_file, 'r')
    g = Graph()
    for line in f.readlines():
        u = list(map(int, re.findall(r'\d+', line)))[0]
        v = list(map(int, re.findall(r'\d+', line)))[1]
        g.add_edge(u, v)
    print("Graph size: E = %d, V = %d" % (g.edge_cnt, g.node_cnt))

    return g

def Clear_Counter( g ):
    for node_id in g.nodes:
        node = g.nodes[node_id]
        node.counters = {}


def Random_Sub_Graph( global_g, seed_node_id, sub_graph_id, max_length, max_neighbor_cnt, to_file = False):
    seed_node = global_g.nodes[seed_node_id]
    sub_g = Graph()
    queue_curr = seed_node.neighbors
    
    if to_file: f = open('sub_graph_' + str(sub_graph_id) + '.txt', 'w')
    
    random.seed()
    #print("Building sub-graph from seed %d" % seed_node_id)
    for level in range(0, max_length):
        queue_curr = sample(queue_curr, min(max_neighbor_cnt, len(queue_curr)))
        queue_next = []
        while queue_curr:
            src_node_id = queue_curr.pop(0)
            neighbors = global_g.nodes[src_node_id].neighbors
            if to_file: f.write("%d: " % src_node_id)
            for dst_node_id in neighbors:
                sub_g.add_edge(src_node_id, dst_node_id)
                if to_file: f.write("%d " % dst_node_id)
            queue_next += neighbors
            if to_file: f.write("\n")
        queue_curr = queue_next
    if to_file: f.close()
    #print("Sub-graph size: E = %d, V = %d" % (sub_g.edge_cnt, sub_g.node_cnt))
    
    return sub_g


def BFS_Sub_Graph(global_g, src_node_id, BFS_depth):
    sub_g = Graph()
    visited = []
    queue = []
    depth = 0

    visited.append(src_node_id)
    queue.append([src_node_id, depth])

    while queue:
        node = queue.pop(0)
        node_id = node[0]
        depth = node[1]
        if depth == BFS_depth:
            continue
        if len(visited) > 50000:
            return sub_g

        #print("Node %d, Visited: %d, depth: %d" % (node_id, len(visited), depth))
        neighbors = global_g.nodes[node_id].neighbors
        for n in neighbors:
            sub_g.add_edge(node_id, n)
            sub_g.nodes[node_id].depth = depth
            if n not in visited:
                visited.append(n)
                queue.append([n, depth+1])
                sub_g.nodes[n].depth = depth+1
            
    return sub_g