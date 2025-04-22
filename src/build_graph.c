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



    char version_cmd[256];
    snprintf(version_cmd, sizeof(version_cmd),
        "sudo kraken getversion %s",
        pkg_name);
    
    FILE *version_file = popen(version_cmd, "r");
    if (!version_file) {
        fprintf(stderr, "Failed to get version for %s\n", pkg_name);
        return;
    }
    
    char version[128];
    if (!fgets(version, sizeof(version), version_file)) {
        pclose(version_file);
        return;
    }
    pclose(version_file);
    version[strcspn(version, "\n")] = 0;




   

    Node *pkg_node = find_node_by_name_and_version(graph, pkg_name,version);

    if(!pkg_node){
        pkg_node = create_node(pkg_name,version);
        printf(GREEN "✓ Created node: " YELLOW "%s" RESET "\n", pkg_name);
        add_node(graph, pkg_node);
    }

    char dep_cmd[256];
    snprintf(dep_cmd, sizeof(dep_cmd),
        "sudo kraken getdeps %s %s",
        pkg_name, version);
    
    FILE *dep_file = popen(dep_cmd, "r");
    if (!dep_file) {
        fprintf(stderr, "Failed to get dependencies\n");
        return;
    }
    
    char dep_line[256];
    while (fgets(dep_line, sizeof(dep_line), dep_file)) {
        dep_line[strcspn(dep_line, "\n")] = 0;
        
        char dep_name[128];
        char dep_version[128];
        if (sscanf(dep_line, "%127[^@]@%127s", dep_name, dep_version) != 2) {
            continue;
        }
        
        Node *dep_node = find_node_by_name_and_version(graph, dep_name, dep_version);
        if (!dep_node) {
            dep_node = create_node(dep_name, dep_version);
            add_node(graph, dep_node);
        }
        
        add_dependency(pkg_node, dep_node);
        build_graph(graph, dep_name);  // Recursive build
    }
    pclose(dep_file);





    
    }

