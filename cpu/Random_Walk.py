
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
                    help='the percentage of top-c ranking nodes within the graph')

print("Running Experiments on Random Walk Algorithm")

def set_hyper_parameters( hy_params ):
    global args, graph_file, label_file, max_length, max_itr_all
    global max_itr_seed, alpha, seed_ratio, top_c

    args = parser.parse_args()
    graph_file = args.graph
    label_file = args.label
    max_length = args.max_length
    max_itr_all = args.max_itr_all
    max_itr_seed = args.max_itr_seed
    alpha = args.alpha
    seed_ratio = args.seed_ratio
    top_c = args.top_c

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
    global max_itr_seed, alpha, seed_ratio, top_c

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
        
    print("Graph size: E = %d, V = %d" % (g.edge_cnt, g.node_cnt))


    # find the largest community in the graph
    all_communities = {}
    f = open(label_file, 'r')
    for line in f.readlines():
        node = map(int, re.findall(r'\d+', line))[0]
        cmty = map(int, re.findall(r'\d+', line))[1]
        if cmty in all_communities:
            all_communities[cmty].append(node)
        else:
            all_communities[cmty] = []
    f.close()

    # for cmty in all_communities:
    #     print("Community %d of size %d" % (cmty, len(all_communities[cmty])))

    largest_cmty_size = max(len(item) for item in all_communities.values())
    print("Largest community size: " + str(largest_cmty_size))
    cmty_id = [key for key in all_communities if len(all_communities[key]) == largest_cmty_size]
    print("Largest community ID: " + str(cmty_id[0]))
    largest_cmty = all_communities[cmty_id[0]]

    largest_cmty_file = label_file[: len(label_file)-4 ] + '_largest_cmty.txt'
    f = open(largest_cmty_file, 'w')
    for ele in largest_cmty:
        f.write(str(ele) + '\n')
    f.close()

    # specify the seed set
    cmty_seeds = sample(largest_cmty, int(seed_ratio * largest_cmty_size))
    cmty_seeds_cnt = len(cmty_seeds)
    print("Community seed set size: " + str(cmty_seeds_cnt))
    largest_cmty_seeds_file = label_file[: len(label_file)-4 ] + '_largest_cmty_seeds.txt'
    f = open(largest_cmty_seeds_file, 'w')
    for ele in cmty_seeds:
        f.write(str(ele) + '\n')
    f.close()

    # start random walk
    for seed_node_id in cmty_seeds:
        # print("+ Computing seed node %d" % seed_node_id)

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
                
                # print("  ... curr_node: %d" % curr_node.node_id)
                # sys.stdout.write("  ... curr_node's neighbors: ")
                # print(curr_node_neighbors)

                curr_node = next_node

    # print("Results of Counters")
    # for n in g.nodes:
    #     print("node: " + str(n))
    #     for ele in g.nodes[n].counters:
    #         print(ele)
    #         print(g.nodes[n].counters[ele])

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
        #print("Node %d: score: %f" % (node_id, node.s_u_a_score))

    # rank those nodes
    sorted_nodes_raw = sorted(g.nodes.items(), key=lambda x: x[1].s_u_a_score, reverse=True)
    print("Node ranking:")
    rank = 1
    sorted_nodes = []
    for node in sorted_nodes_raw:
        if rank > int(top_c * g.node_cnt):
            break
        #print("Rank %d (score %f): Node %d" % (rank, node[1].s_u_a_score, node[1].node_id))
        rank += 1
        sorted_nodes.append(node[1])

    return sorted_nodes

def Plot_Curve( sorted_nodes_list, file_name ):

    # get the gound truth community
    largest_cmty_file = label_file[: len(label_file)-4 ] + '_largest_cmty.txt'
    f = open(largest_cmty_file, 'r')
    largest_cmty = []
    for line in f.readlines():
        largest_cmty.append(int(line))
    f.close()
    largest_cmty_size = len(largest_cmty)


    fig, (subfig0, subfig1) = plt.subplots(2, 1)
    for sorted_nodes, param in sorted_nodes_list:
        # compute the precision and recall, plot the curve for each combination
        true_pos = 0
        fals_pos = 0
        prec = 0
        recl = 0
        prec_list = []
        recl_list = []
        idx = 0
        idx_list = []

        for node in sorted_nodes:
            if node.node_id in largest_cmty:
                true_pos += 1
            else:
                fals_pos += 1

            prec = 1.0 * true_pos / (true_pos + fals_pos)
            recl = 1.0 * true_pos / largest_cmty_size
            idx += 1

            prec_list.append(prec)
            recl_list.append(recl)
            idx_list.append(idx * 1.0 / largest_cmty_size)
        
        subfig0.plot(recl_list, prec_list, color='b')
        subfig1.plot(idx_list, recl_list, color='r')
        subfig1.plot(idx_list, prec_list, color='y')


    subfig0.legend(["Precision-Recall"])
    subfig0.set_xlabel("Recall")
    subfig0.set_ylabel("Precision")

    subfig1.legend(["Recall", "Precision"])
    subfig1.set_xlabel("# of top-c ranking nodes")

    output_file = graph_file[: len(graph_file)-4 ] + '_' + file_name + '_curve' + '.png'
    plt.savefig(output_file)



def main():
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
        param['alpha'] = alpha
        sorted_nodes = Random_Walk(param)
        sorted_nodes_list.append([sorted_nodes, alpha])

    Plot_Curve(sorted_nodes_list, 'alpha')


if __name__ == "__main__":
    main()

