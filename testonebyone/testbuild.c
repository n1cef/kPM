#include<stdio.h>
#include<stdlib.h>
#include "/usr/kraken/include/build_graph.h"
#include "/usr/kraken/include/graph.h"
#include "/usr/kraken/include/get_ver_dep_checkins.h"



int main(){

  Graph *graph = create_graph();
  
  
  build_graph(graph , "emacs");

  print_graph(graph);


  





  return 0;
  
}
