function discretize_dyns!(
  F,  # coeff. matrix of the sparse tableau eqs.
  nbset,  # tuple with the following elements.
    # nodes: array of Strings containing independent node names.
    # num_nodes: number of nodes.
    # branches: array of struct Branch.
    # num_branches: sum of branch phases.
    # num_dyns: number of dynamic branches.
  h  # time-step size.
  )  #=

discretizes the time derivative operators appearing in the sparse tableau matrix F given as the first argument. The information of branches, the number of nodes, the number of branches and the time step size are respectively given as the second to fifth argument, and they are used in the discretization.

Author: Taku Noda
Started on Aug. 28, 2020
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

( nodes, num_nodes, branches, num_branches, num_dyns ) = nbset

noff_d = num_nodes + 2*num_branches
noff_v = num_nodes + num_branches
h2 = 0.5*h

for branch in branches
  if branch.type == "L"
    nph = branch.nph
    range = 0:( nph - 1 )
    d_range = ( noff_d + branch.p_de ) .+ range
    v_range = ( noff_v + branch.p_vars ) .+ range
    F[ d_range, v_range ] = sparse( -h2*I, nph, nph )
    F[ d_range, d_range ] = sparse( I, nph, nph )
  elseif branch.type == "C"
    nph = branch.nph
    range = 0:( nph - 1 )
    d_range = ( noff_d + branch.p_de ) .+ range
    i_range = ( num_nodes + branch.p_vars ) .+ range
    F[ d_range, i_range ] = sparse( -h2*I, nph, nph )
    F[ d_range, d_range ] = sparse( I, nph, nph )
  elseif branch.type == "NL"
    dpos = noff_d + branch.p_de
    vpos = noff_v + branch.p_vars
    F[ dpos, vpos ] = -h2
    F[ dpos, dpos ] = 1.0
  elseif branch.type == "NC"
    dpos = noff_d + branch.p_de
    ipos = num_nodes + branch.p_vars
    F[ dpos, vpos ] = -h2
    F[ dpos, dpos ] = 1.0
  end
end

end
