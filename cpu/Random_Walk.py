import argparse
import re
import sys
from random import sample 
from Graph import *
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy
import time


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



def Random_Walk( hy_params = {} ):

    global args, graph_file, label_file, max_length, max_itr_all
    global max_itr_seed, alpha, seed_ratio, top_c, cmty_index, node_index
    global total_nodes

    # if hyperparameters are passed from outside
    set_hyper_parameters( hy_params )

    # build the graph
    f = open(graph_file, 'r')
    g = Graph()
    for line in f.readlines():
        u = map(int, re.findall(r'\d+', line))[0]
        v = map(int, re.findall(r'\d+', line))[1]
        g.add_edge(u, v)

    # for n in g.nodes:
    #     print(n)
    #     print(g.nodes[n].degree)
    #     print(g.nodes[n].neighbors)
    #for n in g.nodes:
    #    print(n, g.nodes[n])
    #print(g.nodes[1])
    #print(type(g.nodes[1]))

    total_nodes = g.node_cnt
        
    print("Graph size: E = %d, V = %d" % (g.edge_cnt, g.node_cnt))

    # read in communities
    all_communities = {}
    f = open(label_file, 'r')
    cmty = 1
    for line in f.readlines():
        cmty_nodes = re.findall(r'\d+', line)
        if len(cmty_nodes) >= 100 and len(cmty_nodes) <= 3000:
            all_communities[cmty] = map(int, cmty_nodes)
        cmty = cmty + 1
    f.close()

    print("Num communities larger than 100: ", len(all_communities))

    # print all communities that have been accepted as large enough
    """for cmty in all_communities:
        print("Community %d of size %d" % (cmty, len(all_communities[cmty])))"""

    # allow user to choose specific community
    if cmty_index < 0:
        length = -1
        for key, value in all_communities.items():
            if length < len(value):
                length = len(value)
                cmty_index = key
                # print("new longest found, #", cmty_index, ": ", value)
    
    target_cmty = all_communities[cmty_index]
    print("Chosen community index: ", cmty_index, " containing ", len(target_cmty), " nodes")

    target_cmty_file = label_file[: len(label_file)-4 ] + '_target_cmty.txt'
    f = open(target_cmty_file, 'w')
    for ele in target_cmty:
        f.write(str(ele) + '\n')
    f.close()

    # specify the seed set
    if node_index < 0:
        cmty_seeds = sample(target_cmty, int(seed_ratio * len(target_cmty)))
    else:
        cmty_seeds = {target_cmty[node_index]}

    cmty_seeds_cnt = len(cmty_seeds)
    print("Community seed set size: " + str(cmty_seeds_cnt))
    target_cmty_seeds_file = label_file[: len(label_file)-4 ] + '_target_cmty_seeds.txt'
    f = open(target_cmty_seeds_file, 'w')
    for ele in cmty_seeds:
        f.write(str(ele) + '\n')
    f.close()

    print('community seeds')
    for seed in cmty_seeds:
        print(seed)

    # start random walk
    for seed_node_id in cmty_seeds:
        # print("+ Computing seed node %d" % seed_node_id)

        #seed_node_id = int(seed_node_id)
        seed_node = g.nodes[seed_node_id]
        # print(seed_node.degree)
        # print(seed_node.neighbors)

        for itr in range(0, max_itr_seed):
            curr_node = seed_node
            #print(" -- Iteration %d" % itr)

            for step in range(0, max_length):
                #print("  ... Step %d" % step)
                
                curr_node_degree = curr_node.degree
                curr_node_neighbors = curr_node.neighbors

                next_node_id = sample(curr_node_neighbors, 1)[0]
                next_node = g.nodes[next_node_id]
                
                if seed_node_id not in next_node.counters:
                    next_node.counters[seed_node_id] = {}
                if step not in next_node.counters[seed_node_id]:
                    next_node.counters[seed_node_id][step] = int(0)
                
                next_node.counters[seed_node_id][step] += 1

                curr_node = next_node

    # compute s_{u, a} score
    for node_id in g.nodes:
        node = g.nodes[node_id]

        s_u_a = 0
        for step in range(0, max_length):
            for seed_node_id in cmty_seeds:
                seed_node = g.nodes[seed_node_id]
                seed_node_degree = seed_node.degree

                try:
                    x_u_i_v = node.counters[seed_node_id][step]
                except:
                    x_u_i_v = 0

                s_u_a += (alpha ** step) * x_u_i_v * seed_node_degree
        node.s_u_a_score = 1.0 * s_u_a / node.degree

    # rank those nodes
    sorted_nodes_raw = sorted(g.nodes.items(), key=lambda x: x[1].s_u_a_score, reverse=True)
    sorted_nodes = [node[1] for node in sorted_nodes_raw[0:int(top_c * len(target_cmty))]]
    print("sorted nodes count: ", len(sorted_nodes))

    return sorted_nodes

def Plot_Curve( sorted_nodes_list, file_name ):
    print('plotting curve')

    # get the gound truth community
    target_cmty_file = label_file[: len(label_file)-4 ] + '_target_cmty.txt'
    f = open(target_cmty_file, 'r')
    target_cmty = []
    for line in f.readlines():
        target_cmty.append(int(line))
    f.close()
    target_cmty_size = len(target_cmty)


    fig, (subfig0, subfig1, subfig2) = plt.subplots(3, 1)
    for sorted_nodes, param in sorted_nodes_list:
        # compute the precision and recall, plot the curve for each combination
        true_pos = 0
        fals_pos = 0
        prec = 0
        recl = 0
        fpr = 0
        prec_list = []
        recl_list = []
        idx = 0
        idx_list = []

        fpr_list = []

        neg = total_nodes - target_cmty_size

        for node in sorted_nodes:
            if node.node_id in target_cmty:
                true_pos += 1
            else:
                fals_pos += 1

            prec = 1.0 * true_pos / (true_pos + fals_pos)
            recl = 1.0 * true_pos / target_cmty_size
            fpr = 1.0 * fals_pos / neg
            idx += 1

            prec_list.append(prec)
            recl_list.append(recl)
            fpr_list.append(fpr)
            idx_list.append(idx * 1.0 / target_cmty_size)
        
        """print('precision list')
        print(prec_list[0:2*target_cmty_size])
        print('recall list')
        print(recl_list[0:2*target_cmty_size])
        print('fpr list')
        print(fpr_list[0:2*target_cmty_size])"""
        subfig0.plot(recl_list, prec_list, color='b')
        subfig1.plot(idx_list, recl_list, color='r')
        subfig1.plot(idx_list, prec_list, color='y')
        subfig2.plot(fpr_list, recl_list, color='g')


    subfig0.legend(["Precision-Recall"])
    subfig0.set_xlabel("Recall")
    subfig0.set_ylabel("Precision")

    subfig1.legend(["Recall", "Precision"])
    subfig1.set_xlabel("# of top-c ranking nodes")

    subfig2.legend(["Recall, False Positive Rate"])

    output_file = graph_file[: len(graph_file)-4 ] + '_' + file_name + '_curve' + '.png'
    plt.savefig(output_file, pad_inches=1.5)



def main():
    sorted_nodes_list = []
    param = {}
    start_time = time.clock()

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

    #for alpha in numpy.arange(0.80, 1.0, 0.02):
    for alpha in numpy.arange(0.80, 0.82, 0.02):
        param['alpha'] = alpha
        sorted_nodes = Random_Walk(param)
        sorted_nodes_list.append([sorted_nodes, alpha])

    Plot_Curve(sorted_nodes_list, 'alpha')

    stop_time = time.clock()
    print(stop_time - start_time)

if __name__ == "__main__":
    main()