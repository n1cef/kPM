
#include "../include/graph.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "../include/build_graph.h"
#include "../include/get_pkg.h"


void build_graph(Graph *graph, const char *pkg_name) {

    Node *pkg_node = find_node_by_name(graph, pkg_name);

    if (pkg_node) return;


    pkg_node = create_node(pkg_name);

    add_node(graph, pkg_node);

    

    int nbr_dep = 0;

    char **dep_array = get_pkg(pkg_name, &nbr_dep);

    if (!dep_array) return;


    for (int i = 0; i < nbr_dep; i++) {

        Node *dep_node = find_node_by_name(graph, dep_array[i]);

        if (!dep_node) {

            dep_node = create_node(dep_array[i]);

            add_node(graph, dep_node);

        }

        add_dependency(pkg_node, dep_node);

        build_graph(graph, dep_array[i]);

        free(dep_array[i]);

    }

    free(dep_array);

}