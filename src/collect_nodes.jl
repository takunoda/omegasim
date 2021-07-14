function collect_nodes( subsys )  #=

collects independent nodes in a given circuit. It is assumed that the information of the circuit has been stored in the variable "subsys" given as the input argument of this function. This function will return the collected independent nodes as the array "nodes" containing the node names.

Author: Taku Noda
Started on Nov. 11, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

nodes = String[]

gnd_exists = false
for elm in eachelement( subsys )
  if elm.name == "branch"
    nodes_str = ""
    if !haskey( elm, "nph" )  # if single-phase,
      nodes_str = ( elm[ "lhs" ] )*';'*( elm[ "rhs" ] )
    else  # if multiphase,
      for elm1 in eachelement( elm )
        if elm1.name == "lhs"
          nodes_str = ( elm1.content )*';'
          break
        end
      end
      for elm1 in eachelement( elm )
        if elm1.name == "rhs"
          nodes_str = nodes_str*( elm1.content )
          break
        end
      end
    end
    nodes1 = split( nodes_str, ";" )
    for node1 in nodes1
      if ( !gnd_exists )&&( node1 == "GND" )
        gnd_exists = true
      elseif node1 != "GND"
        already_exists = false
        for node in nodes
          if node == node1
            already_exists = true
            break
          end
        end
        if !already_exists
          push!( nodes, node1 )
        end
      end
    end
  end
end

if !gnd_exists
  omegasim_error( "In a circuit description, at least one node must be named \"GND\" that is used as the zero-voltage reference. However, the given circuit has no node named \"GND\"." )
end

return nodes

end
