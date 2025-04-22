#include<stdio.h>
#include"/usr/kraken/include/graph.h"
#include"/usr/kraken/include/conflict.h"
#include"/usr/kraken/include/dependency.h"
#include "/usr/kraken/include/build_graph.h"
#include<stdlib.h>


#define RED "\033[31m"
#define GREEN "\033[32m"
#define YELLOW "\033[33m"
#define CYAN "\033[36m"
#define BOLD "\033[1m"
#define RESET "\033[0m"

int main(int argc, char *argv[]){
    
    printf(BOLD CYAN "\n=== Kraken Package Resolver ===\n\n" RESET);

    if(argc < 2){
        fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Usage: %s <package-name>\n" RESET, argv[0]);
        return 1;
    }

    const char *pkg_name = argv[1];
    printf(CYAN BOLD "📦 Target package: " YELLOW "%s\n\n" RESET, pkg_name);

    Graph *graph = create_graph();
    if (graph == NULL) {
        fprintf(stderr, RED BOLD "✗ ERROR: " RESET RED "Failed to initialize dependency graph\n" RESET);
        return EXIT_FAILURE;
    }

    printf(CYAN BOLD "🔨 Building dependency graph...\n" RESET);
    build_graph(graph, pkg_name);


    printf(CYAN BOLD "\n🔍 Checking for version conflicts...\n" RESET);
    check_version_conflicts(graph);


    printf(CYAN BOLD "\n🔍 Checking for cycles...\n" RESET);
    if(has_cycle(graph)){
        fprintf(stderr, RED BOLD "\n✗ ERROR: " RESET RED "Circular dependency detected!\n" RESET);
        free_graph(graph);
        return EXIT_FAILURE;
    }

    printf(GREEN BOLD "\n✓ Dependency graph validated\n" RESET);
    printf(CYAN BOLD "\n🚀 Resolving dependencies...\n\n" RESET);
    resolve_dep(graph);

    printf(GREEN BOLD "\n✅ Resolution completed successfully\n\n" RESET);
    free_graph(graph);
    return EXIT_SUCCESS;
}


