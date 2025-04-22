#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "/usr/kraken/include/graph.h"
#include "/usr/kraken/include/conflict.h"

void check_version_conflicts(Graph *graph) {
    
    typedef struct {
        char *name;
        char *version;
    } PkgVersion;
    
    PkgVersion *versions = malloc(graph->nbr_node * sizeof(PkgVersion));
    int count = 0;
    
    for (int i = 0; i < graph->nbr_node; i++) {
        Node *node = graph->node_array[i];
        
        for (int j = 0; j < count; j++) {
            if (strcmp(versions[j].name, node->pkg_name) == 0) {
                if (strcmp(versions[j].version, node->version) != 0) {
                    fprintf(stderr, "Version conflict detected: %s\n"
                            "  Existing: %s\n"
                            "  New:      %s\n",
                            node->pkg_name,
                            versions[j].version,
                            node->version);
                    exit(EXIT_FAILURE);
                }
            }
        }
        
        versions[count].name = strdup(node->pkg_name);
        versions[count].version = strdup(node->version);
        count++;
    }
    
    for (int i = 0; i < count; i++) {
        free(versions[i].name);
        free(versions[i].version);
    }
    free(versions);
}