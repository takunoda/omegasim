function update_y!(
  y,
  nbset,  # tuple with the following elements.
    # nodes: array of Strings containing independent node names.
    # num_nodes: number of nodes.
    # branches: array of struct Branch.
    # num_branches: sum of branch phases.
    # num_dyns: number of dynamic branches.
  h,  # time-step size.
  x1  # value of the unknown vector x at the previous time step.
  )  #=

updates the vector "y", which is given as the first argument, for a transient simulation. This update is done only once for each time step before entering a Newton-Raphson iteration. In this function, only source and dynamic equations are updated. Nonlinear equations are updated in the function update_Fy!().

Author: Taku Noda
Started on Aug. 29, 2020
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

( nodes, num_nodes, branches, num_branches, num_dyns ) = nbset

noff_v = num_nodes + num_branches
noff_d = num_nodes + 2*num_branches
h2 = 0.5*h

for branch in branches
  if branch.type == "E"
    vec = eval( branch.val )
    y[ noff_v + branch.p_ns ] = vec[ 1 ]
  elseif branch.type == "J"
    vec = eval( branch.val )
    y[ num_nodes + branch.p_ns ] = vec[ 1 ]
  elseif branch.type == "L"
    nph = branch.nph
    range = 0:( nph - 1 )
    v_range = ( noff_v + branch.p_vars ) .+ range
    d_range = ( noff_d + branch.p_de ) .+ range
    y[ d_range ] = h2*x1[ v_range ] + x1[ d_range ]
  elseif branch.type == "C"
    nph = branch.nph
    range = 0:( nph - 1 )
    i_range = ( num_nodes + branch.p_vars ) .+ range
    d_range = ( noff_d + branch.p_de ) .+ range
    y[ d_range ] = h2*x1[ i_range ] + x1[ d_range ]
  elseif branch.type == "NL"
    dpos = noff_d + branch.p_de
    y[ dpos ] = h2*x1[ noff_v + branch.p_vars ] + x1[ dpos ]
  elseif branch.type == "NC"
    dpos = noff_d + branch.p_de
    y[ dpos ] = h2*x1[ num_nodes + branch.p_vars ] + x1[ dpos ]
  end
end

return nothing

end
