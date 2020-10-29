import argparse
import re
from Graph import *
# import matplotlib
# matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from Random_Walk import *
import json


parser = argparse.ArgumentParser(description='Random Walk Parameters')
parser.add_argument('--graph', '-g', type=str, default='./datasets-RW/cora_adj.txt',
                    help='the input adjacency graph')

def Get_Seeds():
    args = parser.parse_args()
    graph_file = args.graph

    print graph_file

    # build the graph
    f = open(graph_file, 'r')
    g = Graph()
    for line in f.readlines():
        u = map(int, re.findall(r'\d+', line))[0]
        v = map(int, re.findall(r'\d+', line))[1]
        g.add_edge(u, v)

    potential_seeds = []
    for (id, node) in g.nodes.items():
    	if node.degree >= 20 and node.degree <= 40:
    		potential_seeds.append(node.node_id)
    		print "appending node %d degree %d" % (node.node_id, node.degree)

    	if len(potential_seeds) > 200:
    		break

    print potential_seeds
    return potential_seeds


def main():
    args = parser.parse_args()
    graph_file = args.graph

    print graph_file

    global_g = Load_Graph(graph_file)
    #seed_node_id = 21
    BFS_depth = 4
    top_c = 50
    max_length = 8
    alpha = 0.95

    potential_seeds = Get_Seeds()

    #todo tomorrow: have it call compute_score_rank every 100k to see when it converges
    for seed_node_id in potential_seeds:
        Clear_Counter(global_g)
        Random_Walk_Seed_Local( global_g = global_g, sub_g = global_g, start_step = 0, seed_node_id = seed_node_id, \
    	                        top_c = top_c, alpha = alpha, max_length = max_length, max_itr_seed = 1000000 )
        ground_truth = Compute_Score_Rank( global_g, top_c, seed_node_id, alpha )
        print("ground_truth")
        print(ground_truth)

main()