function build_F0_tr(
  nbset,  # tuple with the following elements.
    # nodes: array of Strings containing independent node names.
    # num_nodes: number of nodes.
    # branches: array of struct Branch.
    # num_branches: sum of branch phases.
    # num_dyns: number of dynamic branches.
  smset  # tuple with the following elements.
    # Ac: branch-node connectivity matrix.
    # Z: coefficient matrix of i.
    # Y: coefficient matrix of v.
    # B1: incidence matrix of alpha.
    # B2: incidence matrix of [ i v ].
  )  #=

builds the initial form of F which is the coefficient matrix of the sparse tableau equations for a transient simulation and returns it.

Author: Taku Noda
Started on Feb. 11, 2021
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

( nodes, num_nodes, branches, num_branches, num_dyns ) = nbset
( Ac, Z, Y, B1, B2 ) = smset

N = num_nodes + 2*num_branches + num_dyns

F = spzeros( N, N )
range1 = 1:num_nodes
range2 = num_nodes .+ ( 1:num_branches )
range3 = num_branches .+ range2
range4 = ( num_nodes + 2*num_branches ) .+ ( 1:num_dyns )
range23 = num_nodes .+ ( 1:( 2*num_branches ) )
F[ range1, range2 ] = transpose( Ac )
F[ range2, range1 ] = Ac
F[ range2, range3 ] = sparse( -I, num_branches, num_branches )
F[ range3, range2 ] = Z
F[ range3, range3 ] = Y
F[ range3, range4 ] = B1
F[ range4, range23 ] = B2

return F

end
