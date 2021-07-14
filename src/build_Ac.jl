function build_Ac(
  num_nodes,  # number of nodes.
  branches,  # array of branches.
  num_branches  # number of branches (sum of phases).
  )  #=

builds the branch-node connectivity matrix Ac from an array of Branch and returns it.

Author: Taku Noda
Started on Nov. 5, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

Ac = spzeros( num_branches, num_nodes )

irow = 1
for branch in branches
  for iph = 1:( branch.nph )
    jcol = branch.lhs[ iph ]
    if jcol > 0
      Ac[ irow, jcol ] = 1
    end
    jcol = branch.rhs[ iph ]
    if jcol > 0
      Ac[ irow, jcol ] = -1
    end
    irow = irow + 1
  end
end

return Ac

end
