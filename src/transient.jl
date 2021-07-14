function transient(
  F,  # coeff. matrix of the sparse tableau eqs.
  nbset,  # tuple with the following elements.
    # nodes: array of Strings containing independent node names.
    # num_nodes: number of nodes.
    # branches: array of struct Branch.
    # num_branches: sum of branch phases.
    # num_dyns: number of dynamic branches.
  h,  # time-step size.
  Tmax  # time where the simulation stops.
  # integration method.
  )  #=

performs a transient simulation. The arguments are described above.

Author: Taku Noda
Started on Jan. 6, 2021
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

( nodes, num_nodes, branches, num_branches, num_dyns ) = nbset

N = size( F, 1 )
x = zeros( N, 1 )
y = zeros( N, 1 )
discretize_dyns!( F, nbset, h )
println( "F =" )
display( Array( F ) )

t_dat = Float64[]
i_dat = Float64[]

while t <= Tmax
  global t = t + h
  update_y!( y, nbset, h, x )
  x = F\y
  push!( t_dat, t )
  push!( i_dat, -x[ num_nodes + 1 ] )
end

display( plot( t_dat, i_dat ) )

return nothing

end
