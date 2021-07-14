function extract_nodes_branches(
  filename  # name of the iSDF file which contains the information of the circuit to be simulated.
  )  #=

reads the circuit to be simulated from a file whose file name is designated by the argument "filename" and then extracts the information of the nodes and branches in the circuit. The following variables are returned as the elements of the tuple "nbset".
- nodes: array of Strings containing independent node names.
- num_nodes: number of nodes.
- branches: array of struct Branch.
- num_branches: sum of branch phases.
- num_dyns: number of dynamic branches.

Author: Taku Noda
Started on Jan. 6, 2021
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

sys = isdf_pp1( filename )
subsyss = elements( sys.root )
subsys = subsyss[ 1 ]

nodes = collect_nodes( subsys )
num_nodes = length( nodes )
branches, num_branches, num_dyns = collect_branches( subsys, nodes )
nbset = ( nodes, num_nodes, branches, num_branches, num_dyns )

return nbset

end
