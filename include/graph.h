#ifndef GRAPH_H
#define GRAPH_H

#include <stdbool.h>
typedef struct Node{
char * pkg_name;
char * version;
struct Node ** dep_array;
int nbr_dep;
int visited;



} Node;


typedef struct Graph {
 Node **node_array;
 int nbr_node;






} Graph;


Graph *create_graph();
Node *create_node(const char * pkg_name, const char * version);
void add_node(Graph *graph , Node *node);
void add_dependency(Node *parent , Node *child);
void free_graph(Graph *graph );
bool has_cycle(Graph *graph );
bool check_dfs_cycle(Node *node);
Node *find_node_by_name_and_version(Graph *graph,const char *pkg_name, const char *version);
#endif