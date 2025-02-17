
#include "../include/graph.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "../include/build_graph.h"
#include "../include/get_pkg.h"


void build_graph(Graph *graph, const char *pkg_name) {

    Node *pkg_node = find_node_by_name(graph, pkg_name);

    

 if(!pkg_node){
    pkg_node = create_node(pkg_name);

    add_node(graph, pkg_node);
 }
    

    int nbr_dep = 0;

    char **dep_array = get_pkg(pkg_name, &nbr_dep);

    if (!dep_array) return;
    if (dep_array) {

    for (int i = 0; i < nbr_dep; i++) {

        // Access each dependency using dep_array[i]

        printf("Dependency %d: %s\n", i, dep_array[i]);

    }
    }


    for (int i = 0; i < nbr_dep; i++) {

        Node *dep_node = find_node_by_name(graph, dep_array[i]);

        if (!dep_node) {

            dep_node = create_node(dep_array[i]);
            printf("node %s created \n",dep_array[i]);

            add_node(graph, dep_node);
            printf("node %s added to graph   \n",dep_array[i]);


        }

        add_dependency(pkg_node, dep_node);
        printf("node %s is depende on node %s\n",pkg_node->pkg_name,dep_node->pkg_name);

        build_graph(graph, dep_array[i]);

        free(dep_array[i]);

    }

    free(dep_array);

}