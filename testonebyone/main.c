#include <stdio.h>
#include <stdlib.h>
#include "/usr/kraken/include/graph.h"
int  main(){


  printf("hellp form main graph \n");


  
  Graph *graph = create_graph();

  if (!graph){



    printf("graph not creted");
  }
  else {
    printf("graph  created succesfully");
  }
  // parent node 
Node *pkg_node=create_node("nano","8.3");


  if (!pkg_node){



    printf("pkgnode not creted\n");
  }
  else {
    printf("pkgnode   created succesfully\n");
  }


  //child node


  
Node *child_node=create_node("firefox","20.2.3");


  if (!child_node){



    printf("childnode not creted\n");
  }
  else {
    printf("childnode   created succesfully\n");
  }

  //add node pkgnode to graph

  add_node(graph ,pkg_node);

//add node child node to graph

  add_node(graph ,child_node);
  
  //add dependency nano depend on firefox
  add_dependencies(pkg_node , child_node );
  

  for (int i=0;i<graph->nbr_node;i++){
  
    printf("package name is %s \n",graph->node_array[i]->pkg_name);

  }

  return 0;
}



