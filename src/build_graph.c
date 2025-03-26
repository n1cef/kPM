#include "/usr/kraken/include/graph.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "/usr/kraken/include/build_graph.h"
#include "/usr/kraken/include/get_pkg.h"


#define BOLD "\033[1m"
#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define CYAN "\033[36m"
#define RESET "\033[0m"

void build_graph(Graph *graph, const char *pkg_name) {

    Node *pkg_node = find_node_by_name(graph, pkg_name);

    if(!pkg_node){
        pkg_node = create_node(pkg_name);
        printf(GREEN "✓ Created node: " YELLOW "%s" RESET "\n", pkg_name);
        add_node(graph, pkg_node);
    }

    int nbr_dep = 0;
    char **dep_array = get_pkg(pkg_name, &nbr_dep);

    if (!dep_array) return;
    
    if (dep_array) {
        printf(CYAN BOLD "\n📦 Package: " YELLOW "%s" CYAN BOLD " | Dependencies: %d" RESET "\n", 
              pkg_name, nbr_dep);
        for (int i = 0; i < nbr_dep; i++) {
            printf(CYAN "│ Dependency %d: " YELLOW "%s" RESET "\n", i, dep_array[i]);
        }
    }

    for (int i = 0; i < nbr_dep; i++) {
        Node *dep_node = find_node_by_name(graph, dep_array[i]);

        if (!dep_node) {
            dep_node = create_node(dep_array[i]);
            printf(GREEN "├─ Created node: " YELLOW "%s" RESET "\n", dep_array[i]);
            add_node(graph, dep_node);
            printf(GREEN "└─ Added to graph: " YELLOW "%s" RESET "\n", dep_array[i]);
        }

        add_dependency(pkg_node, dep_node);
        printf(CYAN "├─ Dependency: " YELLOW "%s" CYAN " → " YELLOW "%s" RESET "\n", 
              pkg_node->pkg_name, dep_node->pkg_name);

        build_graph(graph, dep_array[i]);
        free(dep_array[i]);
    }

    free(dep_array);
}