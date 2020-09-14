
import matplotlib
matplotlib.use('Agg')

import re
import matplotlib.pyplot as plt

gt_nodes = []
f = open('core_cmty_4.txt', 'r')
for line in f.readlines():
    gt_nodes.append(int(line))


all_cmty_4 = len(gt_nodes)
true_pos = 0
fals_pos = 0
prec = 0
recl = 0
prec_list = []
recl_list = []
idx = 0
idx_list = []

f = open('sorted_nodes_cmty_4.txt', 'r')
f.readline() # skip the first line
for line in f.readlines():
    grp = map(int, re.findall(r'\d+', line))
    node = grp[ len(grp)-1 ]
    if node in gt_nodes:
        true_pos += 1
    else:
        fals_pos += 1

    prec = 1.0 * true_pos / (true_pos + fals_pos)
    recl = 1.0 * true_pos / all_cmty_4
    idx += 1

    prec_list.append(prec)
    recl_list.append(recl)
    idx_list.append(idx)

    if idx > 400:
        break


fig, (subfig0, subfig1) = plt.subplots(2, 1)
subfig0.plot(recl_list, prec_list, color='b')
subfig0.legend(["Precision-Recall Curve"])
subfig0.set_xlabel("Recall")
subfig0.set_ylabel("Precision")

subfig1.plot(idx_list, recl_list, color='r')
subfig1.plot(idx_list, prec_list, color='y')
subfig1.legend(["Recall", "Precision"])
subfig1.set_xlabel("# of top-k ranking nodes")

plt.savefig("cmty_4_PR.png")
