function expand_uses( sys )  #=

expands the <use> ... </use> sections by substituting their component definitions and then returns the result.

This function requires that the Julia package EzXML has been loaded prior to the execution.

Note! At this moment, variables in
  - multiphase elements:
    lhs and rhs pins, matrix parameters
  - control blocks (search for elseif elm.name == "ctrl"):
    input and output variables, one-line Julia code
are not replaced according to <use> substitutions.

Author: Taku Noda
Started on Nov. 5, 2020
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

cmpnnts = Component[]  # all components will be stored.
subsyss = Subsystem[]  # all subsystems will be stored.

sys_root = sys.root  # getting the root element.

# reading the component and subsystem definitions:
num_cmpnnts = 0
num_subsyss = 0
for elm in eachelement( sys_root )
  tag = elm.name
  if tag == "component"
    name = elm[ "name" ]
    type = elm[ "type" ]
    calc = ""
    for elm1 in eachelement( elm )
      if elm1.name == "calc"
        content = strip( elm1.content, [ ' ', '\t', '\n' ] )
        if !isempty( content )
          if content[ end ] == ';'
            calc = content
          else
            calc = content*";"
          end
        end
        break
      end
    end
    cmpnnt = Component( name, type, calc, elm )
    push!( cmpnnts, cmpnnt )
    num_cmpnnts = num_cmpnnts + 1
  elseif tag == "subsystem"
    name = elm[ "name" ]
    type = elm[ "type" ]
    calc = ""
    for elm1 in eachelement( elm )
      if elm1.name == "calc"
        content = strip( elm1.content, [ ' ', '\t', '\n' ] )
        if !isempty( content )
          if content[ end ] == ';'
            calc = content
          else
            calc = content*";"
          end
        end
        break
      end
    end
    subsys = Subsystem( name, type, calc, elm )
    push!( subsyss, subsys )
    num_subsyss = num_subsyss + 1
  end
end

uses = Use[]  # all use statements will be stored.

# collecting all use statements:
num_uses = 0
# from components:
for itr_cmpnnts = 1:num_cmpnnts
  cmpnnt_root = ( cmpnnts[ itr_cmpnnts ] ).root
  for elm in eachelement( cmpnnt_root )
    if elm.name == "use"
      path = nodepath( elm )
      if itr_cmpnnts == 1
        isdf_error( "A component must be defined before it is used, and thus the first component cannot have a <use> ... </use> section.", path )
      end
      component = elm[ "component" ]
      cmpnnt_id = 0
      for jtr_cmpnnts = 1:itr_cmpnnts
        if jtr_cmpnnts == itr_cmpnnts
          isdf_error( "The definition of the component \"$component\" cannot be found before this use statement. A component must be defined before it is used. Or, a recursive use of a component is not allowed.", path )
        end
        if component == ( cmpnnts[ jtr_cmpnnts ] ).name
          cmpnnt_id = jtr_cmpnnts
          break
        end
      end
      as = elm[ "as" ]
      subst = ""
      content = strip( elm.content, [ ' ', '\t', '\n' ] )
      if !isempty( content )
        if content[ end ] == ';'
          subst = content
        else
          subst = content*";"
        end
      end
      use = Use( cmpnnt_id, as, elm, subst )
      push!( uses, use )
      num_uses = num_uses + 1
    end
  end
end
# from subsystems:
for itr_subsyss = 1:num_subsyss
  subsys_root = ( subsyss[ itr_subsyss ] ).root
  for elm in eachelement( subsys_root )
    if elm.name == "use"
      path = nodepath( elm )
      component = elm[ "component" ]
      cmpnnt_id = 0
      for itr_cmpnnts = 1:num_cmpnnts
        if component == ( cmpnnts[ itr_cmpnnts ] ).name
          cmpnnt_id = itr_cmpnnts
          break
        end
      end
      if cmpnnt_id == 0
        isdf_error( "The definition of the component \"$component\" cannot be found before this use statement. A component must be defined before it is used.", path )
      end
      as = elm[ "as" ]
      subst = ""
      content = strip( elm.content, [ ' ', '\t', '\n' ] )
      if !isempty( content )
        if content[ end ] == ';'
          subst = content
        else
          subst = content*";"
        end
      end
      use = Use( cmpnnt_id, as, elm, subst )
      push!( uses, use )
      num_uses = num_uses + 1
    end
  end
end

# expanding the use statements:
for itr_uses = 1:num_uses
  use = uses[ itr_uses ]
  use_elm = use.use_elm
  use_as = use.as
  cmpnnt_root = ( cmpnnts[ use.cmpnnt_id ] ).root
  io = IOBuffer();
  println( io, cmpnnt_root )
  cmpnnt1_doc = parsexml( String( take!( io ) ) )
  cmpnnt1_root = cmpnnt1_doc.root
  # appending use substitutions on top of calc in cmpnnt1_root:
  hascalc = false
  for elm in eachelement( cmpnnt1_root )
    if elm.name == "calc"
      elm.content = ( use.subst )*( elm.content )
      hascalc = true
    end
  end
  elms = elements( cmpnnt1_root )
  if !hascalc
    calc = ElementNode( "calc" )
    calc.content = use.subst
    linkprev!( elms[ 1 ], calc )
  end
  #
  curr_elm = use_elm
  num_elms = length( elms )
  for itr_elms = 1:num_elms
    elm = elms[ itr_elms ]
    unlink!( elm )
    if elm.name != "calc"
      elm[ "name" ] = use_as*'/'*( elm[ "name" ] )
      lhs = elm[ "lhs" ]
      if lhs[ 1 ] != '_'
        elm[ "lhs" ] = use_as*'/'*( elm[ "lhs" ] )
      end
      rhs = elm[ "rhs" ]
      if rhs[ 1 ] != '_'
        elm[ "rhs" ] = use_as*'/'*( elm[ "rhs" ] )
      end
    end
    curr_elm = linknext!( curr_elm, elm )
  end
  unlink!( use_elm )
end

# unlinking used components:
for itr_cmpnnts = 1:num_cmpnnts
  cmpnnt_root = ( cmpnnts[ itr_cmpnnts ] ).root
  unlink!( cmpnnt_root )
end

dq = Char( 34 )  # double quotation.
bsdq = Char( 92 )*dq  # backslash + double quotation.

for itr_subsyss = 1:num_subsyss
  subsys_root = ( subsyss[ itr_subsyss ] ).root
  calc = ""
  for elm in eachelement( subsys_root )
    path = nodepath( elm )
    if elm.name == "calc"
      calc = elm.content
    elseif elm.name == "branch"
      if haskey( elm, "val" )
        calc1 = calc*elm[ "val" ]
        calc1 = replace( calc1, r" |\t|\n" => "" )
        calc1_p = try
          Meta.parse( calc1 )
        catch
          isdf_error( "An error occurred when the following calculation code was parsed: $calc1.", path )
        end
        val = try
          eval( calc1_p )
        catch
          isdf_error( "An error occurred when the following calculation was evaluated: $calc1.", path )
        end
        elm[ "val" ] = string( val )
      end
      if haskey( elm, "lhs" )
        lhs = elm[ "lhs" ]
        if lhs[ 1 ] == '_'
          calc1 = calc*lhs
          calc1 = replace( calc1, r" |\t|\n" => "" )
          calc1_p = try
            Meta.parse( calc1 )
          catch
            isdf_error( "An error occurred when the following calculation code was parsed: $calc1.", path )
          end
          lhs = try
            eval( calc1_p )
          catch
            isdf_error( "An error occurred when the following calculation was evaluated: $calc1.", path )
          end
          elm[ "lhs" ] = lhs
        end
      end
      if haskey( elm, "rhs" )
        rhs = elm[ "rhs" ]
        if rhs[ 1 ] == '_'
          calc1 = calc*rhs
          calc1 = replace( calc1, r" |\t|\n" => "" )
          calc1_p = try
            Meta.parse( calc1 )
          catch
            isdf_error( "An error occurred when the following calculation code was parsed: $calc1.", path )
          end
          rhs = try
            eval( calc1_p )
          catch
            isdf_error( "An error occurred when the following calculation was evaluated: $calc1.", path )
          end
          elm[ "rhs" ] = rhs
        end
      end
    # elseif elm.name == "ctrl"
    end
  end
  elms = elements( subsys_root )
  for itr_elms = 1:length( elms )
    elm = elms[ itr_elms ]
    if elm.name == "calc"
      unlink!( elm )
    end
  end
end

return sys

end
