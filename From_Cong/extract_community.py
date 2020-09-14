

import re
from random import sample 
  

node_cmty = {}

f = open('cora_label.txt', 'r')
for line in f.readlines():
    node = map(int, re.findall(r'\d+', line))[0]
    cmty = map(int, re.findall(r'\d+', line))[1]
    if cmty in node_cmty:
        node_cmty[cmty].append(node)
    else:
        node_cmty[cmty] = []
f.close()

for cmty in node_cmty:
    print("community " + str(cmty))
    print(" - Length: " + str(len(node_cmty[cmty])))

cmty_4 = node_cmty[4]
f = open('core_cmty_4.txt', 'w')
for ele in cmty_4:
    f.write(str(ele) + '\n')
f.close()

cmty_4_seeds = sample(cmty_4, 20)
print(cmty_4_seeds)
f = open('core_cmty_4_seeds.txt', 'w')
for ele in cmty_4_seeds:
    f.write(str(ele) + '\n')
f.close()