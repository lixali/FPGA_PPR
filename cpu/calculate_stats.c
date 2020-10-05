#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include <vector>

#include "calculate_stats.h"

#define WITHOUT_NUMPY
#include "matplotlib-cpp-master/matplotlibcpp.h"
namespace plt = matplotlibcpp;

int in_true_community(int node, int * true_community, int true_community_size){
	int * end = true_community + true_community_size;
	for(int * t_cmty = true_community; t_cmty < end; t_cmty++){
		if(node == *t_cmty){
			printf("%d in true true_community\n", node);
			return 1;
		}
	}
	printf("%d NOT in true true_community\n", node);
	return 0;
}

int calc_stats(int * data_sorted, int max_size, int * true_community, int true_community_size, double top_c){
	std::vector<double> prec(max_size), recl(max_size), idx(max_size), fpr(max_size);

	int true_positive = 0;
	int fals_positive = 0;
	int in_cmty;
	double precision;
	double recall;
	int idx_ = 0;
	double false_pos_rate = 0;

	double neg = max_size - true_community_size;

	int * data_end = data_sorted + ((int) (true_community_size * top_c));

	for(int * data = data_sorted; data < data_end; data++){
		in_cmty = in_true_community(*data, true_community, true_community_size);
		true_positive += in_cmty;
		fals_positive += 1 - in_cmty;

		precision = ((double) true_positive) / ((double) true_positive + fals_positive);
		recall = ((double) true_positive) / ((double) true_community_size);
		idx_++;
		false_pos_rate = ((double) fals_positive) / neg;

		prec.push_back(precision);
		recl.push_back(recall);
		idx.push_back(idx_);
		fpr.push_back(false_pos_rate);
	}

	plt::plot(idx, prec);
    plt::save("./prec.png");

    plt::clf();
    plt::plot(idx, recl);
    plt::save("./recl.png");

    plt::clf();
    plt::plot(fpr, recl);
    plt::save("./ROC.png");

	return -1;
}