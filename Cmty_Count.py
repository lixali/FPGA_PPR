
import argparse
import re
import sys
from random import sample 
from Graph import *
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy


parser = argparse.ArgumentParser(description='Random Walk Parameters')
parser.add_argument('--graph', '-g', type=str, default='./datasets-RW/cora_adj.txt',
                    help='the input adjacency graph')
parser.add_argument('--label', '-lb', type=str, default='./datasets-RW/cora_label.txt',
                    help='ground truth communities')
parser.add_argument('--max-length', '-ml', type=int, default=5,
                    help='the maximum length of a path')
parser.add_argument('--max-itr-all', '-ma', type=int, default=5000,
                    help='the maximum total iterations of random walk')
parser.add_argument('--max-itr-seed', '-ms', type=int, default=500,
                    help='the maximum iterations of one seed')
parser.add_argument('--alpha', '-a', type=float, default=0.95,
                    help='the possibility of keep walking')
parser.add_argument('--seed-ratio', '-sr', type=float, default=0.05,
                    help='the percentage of seed nodes within the community')
parser.add_argument('--top-c', '-c', type=float, default=1.0,
                    help='the proportion of top-c ranking nodes within the graph, as a proportion of the size of the target community')
parser.add_argument('--cmty_index', '-ic', type=int, default=-1,
                    help='the index of community to perform the walk on. -1 is largest.')
parser.add_argument('--node_index', '-nc', type=int, default=-1,
                    help='the index of node in the community to perform the walk on. -1 does all nodes.')

print("Running Experiments on Random Walk Algorithm")

def set_hyper_parameters( hy_params ):
    global args, graph_file, label_file, max_length, max_itr_all
    global max_itr_seed, alpha, seed_ratio, top_c, cmty_index, node_index

    args = parser.parse_args()
    graph_file = args.graph
    label_file = args.label
    max_length = args.max_length
    max_itr_all = args.max_itr_all
    max_itr_seed = args.max_itr_seed
    alpha = args.alpha
    seed_ratio = args.seed_ratio
    top_c = args.top_c
    cmty_index = args.cmty_index
    node_index = args.node_index

    if hy_params:
        if 'graph_file' in hy_params:
            graph_file = hy_params['graph_file']
        if 'label_file' in hy_params:
            label_file = hy_params['label_file']
        if 'max_length' in hy_params:
            max_length = hy_params['max_length']
        if 'max_itr_all' in hy_params:
            max_itr_all = hy_params['max_itr_all']
        if 'max_itr_seed' in hy_params:
            max_itr_seed = hy_params['max_itr_seed']
        if 'alpha' in hy_params:
            alpha = hy_params['alpha']
        if 'seed_ratio' in hy_params:
            seed_ratio = hy_params['seed_ratio']
        if 'top_c' in hy_params:
            top_c = hy_params['top_c']

    print("=== Hyper-parameters ===")
    print("- Graph file: " + graph_file)
    print("- Label file: " + label_file)
    print("- Max length of a path: " + str(max_length))
    print("- Max iterations overall: " + str(max_itr_all))
    print("- Max iterations for each seed: " + str(max_itr_seed))
    print("- Alpha: " + str(alpha))
    print("- Seed ratio: " + str(seed_ratio))
    print("- Top-c ranking: " + str(top_c))

def main():

    global args, graph_file, label_file, max_length, max_itr_all
    global max_itr_seed, alpha, seed_ratio, top_c, cmty_index, node_index
    global total_nodes

    # if hyperparameters are passed from outside
    set_hyper_parameters( hy_params )
    
    sorted_nodes_list = []
    param = {}

    # for seed_ratio in numpy.arange(0.01, 0.2, 0.01):
    #     param['seed_ratio'] = seed_ratio
    #     sorted_nodes = Random_Walk(param)
    #     sorted_nodes_list.append([sorted_nodes, seed_ratio])

    # Plot_Curve(sorted_nodes_list, 'seed_ratio')


    # for max_itr_seed in numpy.arange(500, 2000, 100):
    #     param['max_itr_seed'] = max_itr_seed
    #     sorted_nodes = Random_Walk(param)
    #     sorted_nodes_list.append([sorted_nodes, max_itr_seed])

    # Plot_Curve(sorted_nodes_list, 'max_itr_seed')


    # for max_length in numpy.arange(3, 11, 1):
    #     param['max_length'] = max_length
    #     sorted_nodes = Random_Walk(param)
    #     sorted_nodes_list.append([sorted_nodes, max_length])

    # Plot_Curve(sorted_nodes_list, 'max_length')

    for alpha in numpy.arange(0.80, 1.0, 0.02):
    #for alpha in numpy.arange(0.80, 0.84, 0.02):
        param['alpha'] = alpha
        sorted_nodes = Random_Walk(param)
        sorted_nodes_list.append([sorted_nodes, alpha])

    Plot_Curve(sorted_nodes_list, 'alpha')


if __name__ == "__main__":
    main()

