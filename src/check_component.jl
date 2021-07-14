function check_component( cmpnnt_root, is_subsys = false )  #=

checks if a component, described by the Industrial System Description Format (iSDF), is grammatcally correct or not.

A component is a functioning unit defined in the iSDF. A component usually consists of a physical part embedded with its control part but can consist only of a physical part or a control part. One or more components can be used to define another component.

The first argument "cmpnnt_root" gives the root element of the component. If the second argument "is_subsys" is unity, the checking is applied to a subsystem instead of a component.

This function requires that the Julia package EzXML has been loaded prior to execution.

Author: Taku Noda
Started on Oct. 31, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

path = nodepath( cmpnnt_root )
tag = cmpnnt_root.name
if !is_subsys
  if tag != "component"
    isdf_error( "In a component definition, the tag of the root XML element must be <component>. The tag <$tag>, which is not valid, has been found.", path )
  end
  if !haskey( cmpnnt_root, "name" )
    isdf_error( "The <component> ... </component> section does not have a \"name\" attribute. A <component> ... </component> section must have a \"name\" attribute so as to identify the component by its name.", path )
  end
  name = cmpnnt_root[ "name" ]
  if isempty( name )
    isdf_error( "The \"name\" attribute of the <component> ... </component> section is empty. It cannot be empty.", path )
  end
  if !haskey( cmpnnt_root, "type" )
    isdf_error( "The component \"$name\" does not have a \"type\" attribute. A <component> ... </component> section must have a \"type\" attribute so as to specify the type of the component.", path )
  end
  type = cmpnnt_root[ "type" ]
  if isempty( type )
    isdf_error( "The \"type\" attribute of the component \"$name\" is empty. It cannot be empty.", path )
  end
else  # if is_subsys,
  if tag != "subsystem"
    isdf_error( "In a subsystem definition, the tag of the root XML element must be <subsystem>. The tag <$tag>, which is not valid, has been found.", path )
  end
  if !haskey( cmpnnt_root, "name" )
    isdf_error( "The <subsystem> ... </subsystem> section does not have a \"name\" attribute. A <subsystem> ... </subsystem> section must have a \"name\" attribute so as to identify the subsystem by its name.", path )
  end
  name = cmpnnt_root[ "name" ]
  if isempty( name )
    isdf_error( "The \"name\" attribute of the <subsystem> ... </subsystem> section is empty. It cannot be empty.", path )
  end
  if !haskey( cmpnnt_root, "type" )
    isdf_error( "The subsystem \"$name\" does not have a \"type\" attribute. A <subsystem> ... </subsystem> section must have a \"type\" attribute so as to specify the type of the subsystem.", path )
  end
  type = cmpnnt_root[ "type" ]
  if isempty( type )
    isdf_error( "The \"type\" attribute of the subsystem \"$name\" is empty. It cannot be empty.", path )
  end
end

num_calcs = 0
num_branches = 0
num_ctrls = 0
num_uses = 0
for elm in eachelement( cmpnnt_root )
  path = nodepath( elm )
  tag = elm.name
  if tag == "calc"  # checking validity of calc sections:
    num_calcs = num_calcs + 1
    if num_calcs > 1
      if !is_susys
        isdf_error( "More than one <calc> ... </calc> section has been found. A component definition can have one or no <calc> ... </calc> section.", path )
      else
        isdf_error( "More than one <calc> ... </calc> section has been found. A subsystem definition can have one or no <calc> ... </calc> section.", path )
      end
    end
  elseif tag == "branch"  # checking validity of branches:
    num_branches = num_branches + 1
    ord_branch = ordinal_string( num_branches )
    if !haskey( elm, "name" )
      isdf_error( "The $ord_branch <branch> ... </branch> section does not have a \"name\" attribute. A <branch> ... </branch> section must have a \"name\" attribute so as to identify the branch by its name.", path )
    end
    name = elm[ "name" ]
    if isempty( name )
      isdf_error( "The \"name\" attribute of the $ord_branch <branch> ... </branch> section is empty. It cannot be empty.", path )
    end
    if !haskey( elm, "type" )
      isdf_error( "The branch \"$name\" does not have a \"type\" attribute. A <branch> ... </branch> section must have a \"type\" attribute so as to specify the type of the branch.", path )
    end
    type = elm[ "type" ]
    if isempty( type )
      isdf_error( "The \"type\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
    end
    # checking if the given type is an existing type or not:
    exists = false
    for type1 in BranchTypes
      if type == type1
        exists = true
        break
      end
    end
    if exists == false
      isdf_error( "Undefined branch type \"$type\" has been found for the branch \"$name\"." )
    end
    if ( type == "R" )||( type == "L" )||( type == "G" )||( type == "C" )
      if !haskey( elm, "nph" )  # if single-phase,
        if !haskey( elm, "val" )
          isdf_error( "The branch \"$name\" does not have a \"val\" attribute. A single-phase R, L, G or C branch must have a \"val\" attribute so as to specify the value of the branch. Since no \"nph\" attribute is given, it is assumed that this branch is single-phase.", path )
        end
        val = elm[ "val" ]
        if isempty( val )
          isdf_error( "The \"val\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
        if !haskey( elm, "lhs" )
          isdf_error( "The branch \"$name\" does not have a \"lhs\" attribute. A single-phase R, L, G or C branch must have a \"lhs\" attribute so as to specify the node to which the left-hand-side pin is connected. Since no \"nph\" attribute is given, it is assumed that this branch is single-phase.", path )
        end
        lhs = elm[ "lhs" ]
        if isempty( lhs )
          isdf_error( "The \"lhs\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
        # eliminating unnecessary white spaces:
        elm[ "lhs" ] = replace( lhs, " " => "" )
        if !haskey( elm, "rhs" )
          isdf_error( "The branch \"$name\" does not have a \"rhs\" attribute. A single-phase R, L, G or C branch must have a \"rhs\" attribute so as to specify the node to which the right-hand-side pin is connected. Since no \"nph\" attribute is given, it is assumed that this branch is single-phase.", path )
        end
        rhs = elm[ "rhs" ]
        if isempty( rhs )
          isdf_error( "The \"rhs\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
        # eliminating unnecessary white spaces:
        elm[ "rhs" ] = replace( rhs, " " => "" )
      else  # if mutiphase,
        nph = elm[ "nph" ]
        if isempty( nph )
          isdf_error( "The \"nph\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
        if parse( Int, nph ) < 2
          omega_error( "For the branch \"$name\", the number of phases is given as the \"nph\" attribute, and this means that the branch is multiphase. However, it is set to a value less than two. The \"nph\" attribute of a multiphase branch must be set to an integer greater than or equal to two." )
        end
        # checking the <val> section:
        hastag = false
        val = ""
        for elm1 in eachelement( elm )
          path1 = nodepath( elm1 )
          if elm1.name == "val"
            if hastag
              isdf_error( "More than one <val> ... </val> section have been found in the definition of the branch \"$name\". Multiple definition is not allowed.", path1 )
            end
            val = elm1.content
            if isempty( val )
              isdf_error( "The <val> ... </val> section of the branch \"name\" is empty.", path1 )
            end
            mat = Meta.parse( '['*replace( val, r"\t|\n" => "" )*']' )
            if ( size( mat, 1 ) != nph )||( size( mat, 2 ) != nph )
              isdf_error( "The size of the resistance, inductance, conductance or capacitance matrix for the branch \"$name\" is not $nph by $nph. Its size must be $nph by $nph.", path )
            end
            hastag = true
          end
        end
        if !hastag
          isdf_error( "The branch \"$name\" does not have a <val> ... </val> section. A multiphase R, L, G or C branch must have a <val> ... </val> section so as to specify its matrix.", path )
        end
        # checking the <lhs> section:
        hastag = false
        lhs = ""
        for elm1 in eachelement( elm )
          path1 = nodepath( elm1 )
          if elm1.name == "lhs"
            if hastag
              isdf_error( "More than one <lhs> ... </lhs> section have been found in the definition of the branch \"$name\". Multiple definition is not allowed.", path1 )
            end
            lhs = elm1.content
            if isempty( lhs )
              isdf_error( "The <lhs> ... </lhs> section of the branch \"name\" is empty.", path1 )
            end
            # eliminating unnecessary white spaces:
            elm1.content = replace( lhs, " " => "" )
            hastag = true
          end
        end
        if !hastag
          isdf_error( "The branch \"$name\" does not have a <lhs> ... </lhs> section. A multiphase R, L, G or C branch must have a <lhs> ... </lhs> section so as to specify the nodes to which the left-hand-side pins are connected.", path )
        end
        # checking the <rhs> section:
        hastag = false
        rhs = ""
        for elm1 in eachelement( elm )
          path1 = nodepath( elm1 )
          if elm1.name == "rhs"
            if hastag
              isdf_error( "More than one <rhs> ... </rhs> section have been found in the definition of the branch \"$name\". Multiple definition is not allowed.", path1 )
            end
            rhs = elm1.content
            if isempty( rhs )
              isdf_error( "The <rhs> ... </rhs> section of the branch \"name\" is empty.", path1 )
            end
            # eliminating unnecessary white spaces:
            elm1.content = replace( rhs, " " => "" )
            hastag = true
          end
        end
        if !hastag
          isdf_error( "The branch \"$name\" does not have a <rhs> ... </rhs> section. A multiphase R, L, G or C branch must have a <rhs> ... </rhs> section so as to specify the nodes to which the right-hand-side pins are connected.", path )
        end
      end
    else  # if NOT R, L, G or C,
      # common part for checking lhs, rhs and nph:
      if !haskey( elm, "lhs" )
        isdf_error( "The branch \"$name\" does not have a \"lhs\" attribute. A branch whose type is \"$type\" must have a \"lhs\" attribute so as to specify the node to which the left-hand-side pin is connected.", path )
      end
      lhs = elm[ "lhs" ]
      if isempty( lhs )
        isdf_error( "The \"lhs\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
      end
      # eliminating unnecessary white spaces:
      elm[ "lhs" ] = replace( lhs, " " => "" )
      if !haskey( elm, "rhs" )
        isdf_error( "The branch \"$name\" does not have a \"rhs\" attribute. A branch whose type is \"$type\" must have a \"rhs\" attribute so as to specify the node to which the right-hand-side pin is connected.", path )
      end
      rhs = elm[ "rhs" ]
      if isempty( rhs )
        isdf_error( "The \"rhs\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
      end
      # eliminating unnecessary white spaces:
      elm[ "rhs" ] = replace( rhs, " " => "" )
      if haskey( elm, "nph" )
        nph = parse( Int, elm[ "nph" ] )
        if( nph != 1 )
          isdf_error( "A value being not unity is set to the \"nph\" attribute of the branch \"$name\" whose type is \"$type\". Currently, the number of phases is restricted to unity for this type. Note that omitting the \"nph\" attribute implies that it is unity.", path )
        end
      end
      # checking NR, NL, NC and Sw:
      if ( type == "NR" )||( type == "NL" )||( type == "NC" )||( type == "Sw" )
        # checking if the content exists:
        if isempty( elm.content )
          isdf_error( "The branch \"$name\" does not have a point list to represent its nonlinear characteristic or a list of closing and opening time points. A NR (nonlinear resistor), NL (nonlinear inductor) or NC (nonlinear capacitor) must have the point list as the content of the <branch> ... </branch> section. A Sw (time-controlled switch) must have the time points as the content.", path )
        end
        if type == "Sw"
          val = Meta.parse( '('*replace( elm.content, r"\t|\n" => "" )*')' )
          if size( val, 1 ) != 1
            isdf_error( "The list of closing and opening time points for the Sw branch \"$name\" is not given as a single line. It must be given as a single-line sequence of numbers separated by commas.", path )
          end
        else  # if NR, NL or NC
          val = Meta.parse( '['*replace( elm.content, r"\t|\n" => "" )*']' )
          if size( val, 2 ) != 2
            isdf_error( "The point list to represent the nonlinear characteristic of the NR, NL or NC branch \"$name\" is not given as a two-column matrix. It must be given as a two-column matrix.", path )
          end
        end
      elseif ( type == "E" )||( type == "J" )
        # checking if the equation exists:
        if isempty( elm.content )
          isdf_error( "The branch \"$name\" does not have an  equation to determine its output. An E (voltage source) or J (current source) branch must have a Julia equation to determine its voltage or current with respect to time t as the content of the <branch> ... </branch> section.", path )
        end
      elseif ( type == "CR" )||( type == "CE" )||( type == "CJ" )
        if !haskey( elm, "ctrl" )
          isdf_error( "The branch \"$name\" does not have a \"ctrl\" attribute. A CR (controlled resistor), CE (controlled voltage source) or CJ (controlled current source) branch must have a \"ctrl\" attribute so as to specify the name of a control block which gives the resistance, voltage or current value.", path )
        end
        ctrl = elm[ "ctrl" ]
        if isempty( ctrl )
          isdf_error( "The \"ctrl\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
        if !haskey( elm, "inival" )
          isdf_error( "The branch \"$name\" does not have an \"inival\" attribute. A CR (controlled resistor), CE (controlled voltage source) or CJ (controlled current source) branch must have an \"inival\" attribute so as to specify the initial value of the control quantity which is used until the first control signal is received.", path )
        end
        inival = elm[ "inival" ]
        if isempty( inval )
          isdf_error( "The \"inival\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
      elseif type == "CSw"
        if !haskey( elm, "ctrl" )
          isdf_error( "The branch \"$name\" does not have a \"ctrl\" attribute. A CSw (controlled switch) branch must have a \"ctrl\" attribute so as to specify the name of a control block which gives the switch state.", path )
        end
        ctrl = elm[ "ctrl" ]
        if isempty( ctrl )
          isdf_error( "The \"ctrl\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
        if !haskey( elm, "inistate" )
          isdf_error( "The branch \"$name\" does not have an \"inistate\" attribute. A CSw (controlled switch) branch must have an \"inistate\" attribute so as to specify the initial state of the switch which is used until the first control signal is received.", path )
        end
        inistate = elm[ "inistate" ]
        if isempty( instate )
          isdf_error( "The \"inistate\" attribute of the branch \"$name\" is empty. It cannot be empty.", path )
        end
      end
    end
  elseif tag == "ctrl"  # checking validity of control blocks:
    num_ctrls = num_ctrls + 1
    ord_ctrl = ordinal_string( num_ctrls )
    if !haskey( elm, "name" )
      isdf_error( "The $ord_ctrl <ctrl> ... </ctrl> section does not have a \"name\" attribute. A <ctrl> ... </ctrl> section must have a \"name\" attribute so as to identify the control block by its name.", path )
    end
    name = elm[ "name" ]
    if isempty( name )
      isdf_error( "The \"name\" attribute of the $ord_ctrl <ctrl> ... </ctrl> section is empty. It cannot be empty.", path )
    end
    # checking the <input> section:
    hastag = false
    input = ""
    for elm1 in eachelement( elm )
      path1 = nodepath( elm1 )
      if elm1.name == "input"
        if hastag
          isdf_error( "More than one <input> ... </input> section have been found in the definition of the control block \"$name\". Multiple definition is not allowed.", path1 )
        end
        input = elm1.content
        if isempty( input )
          isdf_error( "The <input> ... </input> section of the control block \"name\" is empty.", path1 )
        end
        hastag = true
      end
    end
    if !hastag
      isdf_error( "The control block \"$name\" does not have a <input> ... </input> section. A control block must have an <input> ... </input> section so as to specify the list of input variables to this control block.", path )
    end
    # checking the <Julia> section:
    hastag = false
    Julia = ""
    for elm1 in eachelement( elm )
      path1 = nodepath( elm1 )
      if elm1.name == "Julia"
        if hastag
          isdf_error( "More than one <Julia> ... </Julia> section have been found in the definition of the control block \"$name\". Multiple definition is not allowed.", path1 )
        end
        Julia = elm1.content
        if isempty( Julia )
          isdf_error( "The <Julia> ... </Julia> section of the control block \"name\" is empty.", path1 )
        end
        hastag = true
      end
    end
    if !hastag
      isdf_error( "The control block \"$name\" does not have a <Julia> ... </Julia> section. A control block must have a <Julia> ... </Julia> section so as to specify its algorithm as a Julia expression.", path )
    end
  elseif tag == "use"
    num_uses = num_uses + 1
    ord_use = ordinal_string( num_uses )
    if !haskey( elm, "component" )
      isdf_error( "The $ord_use <use> ... </use> section does not have a \"component\" attribute. A <use> ... </use> section must have a \"component\" attribute so as to identify the component to be used as a subcomponent in this <use> ... </use> section.", path )
    end
    component = elm[ "component" ]
    if isempty( component )
      isdf_error( "The \"component\" attribute of the $ord_use <use> ... </use> section is empty. It cannot be empty.", path )
    end
    if !haskey( elm, "as" )
      isdf_error( "The $ord_use <use> ... </use> section does not have an \"as\" attribute. A <use> ... </use> section must have an \"as\" attribute so as to specify the name of the instance to be generated by this <use> ... </use> section.", path )
    end
    as = elm[ "as" ]
    if isempty( as )
      isdf_error( "The \"as\" attribute of the $ord_use <use> ... </use> section is empty. It cannot be empty.", path )
    end
  end
end

return nothing

end
