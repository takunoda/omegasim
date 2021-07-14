function collect_branches( subsys, nodes )  #=

collects the branches in a given circuit. It is assumed that the information of the circuit is contained in the variable "subsys" given as the first argument of this function. The variable "nodes" given as the second argument of this function is an array of the independent nodes in the circuit. The independent nodes may have been collected from the circuit description using the function collect_nodes(). The branches collected by this function will be returned as the array "branches" of the struct Branch. The number "num_branches" of branches (sum of branch phases) and the number "num_dyns" of dynamic branches will also be returned. In the array "branches", the node names have been replaced by their index numbers according to the array "nodes".

Author: Taku Noda
Started on Nov. 11, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

# -- Internally used function ------------------------------------------

function find( node, nodes )
index = 0
for i = 1:length( nodes )
  if nodes[ i ] == node
    index = i
    break
  end
end
return index
end

# -- Main body starts here ---------------------------------------------

branches = Branch[]
num_branches = 0
num_dyns = 0
num_nls = 0

for elm in eachelement( subsys )
  if elm.name == "branch"
    name = ""; type = ""; nph = 0; val_str = ""
    lhs = Int[]; rhs = Int[]; p_vars = 0
    p_de = 0
    p_ns = 0; plx = []; ply = [];
    #
    type = elm[ "type" ]
    name = elm[ "name" ]
    #
    if !haskey( elm, "nph" )  # if single-phase,
      nph = 1
      if ( type == "R" )||( type == "L" )||( type == "G" )||( type == "C" )
        val_str = elm[ "val" ]
      elseif ( type == "NR" )||( type == "NL" )||( type == "NC" )||( type == "E" )||( type == "J" )||( type == "Sw" )
        val_str = elm.content
      end
    else  # if multiphase,
      nph = parse( Int, elm[ "nph" ] )
      for elm1 in eachelement( elm )
        if elm1.name == "val"
          val_str = elm1.content
          break
        end
      end
    end
    if ( type == "R" )||( type == "L" )||( type == "G" )||( type == "C" )||( type == "NR" )||( type == "NL" )||( type == "NC" )||( type == "Sw" )
      val_str = '['*replace( val_str, r"\t|\n" => "" )*']'
    elseif ( type == "E" )||( type == "J" )
      val_str = replace( val_str, r" |\t|\n" => "" )
    end
    val = Meta.parse( val_str );
    if ( type == "NR" )||( type == "NL" )||( type == "NC" )
      pldat = eval( val )
      plx = pldat[ :, 1 ]
      ply = pldat[ :, 2 ]
    elseif type == "Sw"
      plx = eval( val )
    end
    #
    if ( type == "L" )||( type == "C" )||( type == "NL" )||( type == "NC" )
      p_de = num_dyns + 1
      num_dyns = num_dyns + nph
    else
      p_de = 0
    end
    if ( type[ 1 ] == 'N' )||( type == "E" )||( type == "J" )||( type == "CSw" )||( type == "CE" )||( type == "CJ" )||( type == "VP" )||( type == "CP" )
      p_ns = num_branches + 1
    end
    if ( type[ 1 ] == 'N' )
      num_nls = num_nls + 1
      p_nl = num_nls
    end
    if ( ( type == "R" )||( type == "L" )||( type == "G" )||( type == "C" ) )&&( nph != 1 )
      for elm1 in eachelement( elm )
        nph = parse( Int, elm[ "nph" ] )
        if elm1.name == "lhs"
          node_names = split( elm1.content, ";" )
          if length( node_names ) != nph
            omegasim_error( "For the branch $name, the number of lefthand-side node names specified does not match the number of phases." )
          end
          for node_name in node_names
            push!( lhs, find( node_name, nodes ) )
          end
        elseif elm1.name == "rhs"
          node_names = split( elm1.content, ";" )
          if length( node_names ) != nph
            omega_error( "For the branch $name, the number of righthand-side node names specified does not match the number of phases." )
          end
          for node_name in node_names
            push!( rhs, find( node_name, nodes ) )
          end
        end
      end
    else
      push!( lhs, find( elm[ "lhs" ], nodes ) )
      push!( rhs, find( elm[ "rhs" ], nodes ) )
    end
    #
    p_vars = num_branches + 1
    num_branches = num_branches + nph
    #
    branch = Branch( name, type, nph, val, lhs, rhs, p_vars, p_de, p_ns, plx, ply, [ -1 ] )
    push!( branches, branch )
  end
end

return branches, num_branches, num_dyns

end
