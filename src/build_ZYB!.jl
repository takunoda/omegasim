function build_ZYB!( branches, num_branches, num_dyns )  #=

builds the matrices Z, Y, B1 and B2 which are submatrices of the branch constitutive equations (BCEs) of the sparse tableau formulation (STF). They are built from the information of branches given as the arguments of this function. The first argument "branches" is an array of the struct Branch containing the information of a branch. The second argument "num_branches" and the third argument "num_dyns" are the number of branches and that of dynamic branches respectively, where an m-phase branch is counted as m branches. This function will return the matrices Z, Y, B1 and B2.

Author: Taku Noda
Started on May 10, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

# -- Internally used functions -----------------------------------------

function set_meye!( A, ipos, jpos, nph )
for iph = 0:( nph - 1 )
  A[ ipos + iph, jpos + iph ] = -1.0
end
end

function calc_slope0( x, y )
N = length( x )
if x[ 1 ] > 0.0
  a = ( y[ 2 ] - y[ 1 ] )/( x[ 2 ] - x[ 1 ] )
  op1 = 0
elseif x[ N ] < 0.0
  a = ( y[ N ] - y[ N - 1 ] )/( x[ N ] - x[ N - 1 ] )
  op1 = N
else
  for n = 2:N
    if x[ n ] >= 0.0
      a = ( y[ n ] - y[ n - 1 ] )/( x[ n ] - x[ n - 1 ] )
      op1 = n - 1
      break
    end
  end
end
return a, op1
end

# -- Main body starts here ---------------------------------------------

Z = spzeros( num_branches, num_branches )
Y = spzeros( num_branches, num_branches )
B1 = spzeros( num_branches, num_dyns )
B2 = spzeros( num_dyns, 2*num_branches )

for branch in branches
  kpos = branch.p_vars
  nph = branch.nph
  mpos = kpos + nph - 1
  if branch.type == "R"
    Z[ kpos:mpos, kpos:mpos ] = eval( branch.val )
    set_meye!( Y, kpos, kpos, nph )
  elseif branch.type == "L"
    Z[ kpos:mpos, kpos:mpos ] = eval( branch.val )
    ppos = branch.p_de
    set_meye!( B1, kpos, ppos, nph )
    set_meye!( B2, ppos, num_branches + kpos, nph )
  elseif branch.type == "G"
    Y[ kpos:mpos, kpos:mpos ] = eval( branch.val )
    set_meye!( Z, kpos, kpos, nph )
  elseif branch.type == "C"
    Y[ kpos:mpos, kpos:mpos ] = eval( branch.val )
    ppos = branch.p_de
    set_meye!( B1, kpos, ppos, nph )
    set_meye!( B2, ppos, kpos, nph )
  elseif branch.type == "NR"
    Z[ kpos, kpos ], op1 = calc_slope0( branch.plx, branch.ply )
    ( branch.op )[ 1 ] = op1
    Y[ kpos, kpos ] = -1.0
  elseif branch.type == "NL"
    Z[ kpos, kpos ], op1 = calc_slope0( branch.plx, branch.ply )
    ( branch.op )[ 1 ] = op1
    ppos = branch.p_de
    B1[ kpos, ppos ] = -1
    B2[ ppos, num_branches + kpos ] = -1
  elseif branch.type == "NC"
    Y[ kpos, kpos ], op1 = calc_slope0( branch.plx, branch.ply )
    ( branch.op )[ 1 ] = op1
    ppos = branch.p_de
    B1[ kpos, ppos ] = -1
    B2[ ppos, kpos ] = -1
  elseif branch.type == "E"
    Y[ kpos, kpos ] = 1.0
  elseif branch.type == "J"
    Z[ kpos, kpos ] = 1.0
  end
end

return Z, Y, B1, B2

end
