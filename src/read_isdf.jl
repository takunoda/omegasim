function read_isdf( filename )  #=

reads an industrial system described in the Industrial System Description Format (iSDF) from the file whose file name is designated by the argument "filename".

This function requires that the Julia package EzXML has been loaded prior to the execution.

Author: Taku Noda
Started on Oct. 25, 2020
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

# reading a system description from file:
sys = readxml( filename )

# reading the root element:
sys_root = sys.root
path = nodepath( sys_root )
tag = sys_root.name
if tag != "system"
  isdf_error( "The tag of the root iSDF element must be <system>. The tag <$tag>, which is not valid, has been found.", path )
end
if !haskey( sys_root, "name" )
  isdf_error( "The <system> ... </system> section does not have a \"name\" attribute. A <system> ... </system> section must have a \"name\" attribute so as to identify the system by its name.", path )
end
name = sys_root[ "name" ]
if isempty( name )
  isdf_error( "The \"name\" attribute of the <system> ... </system> section is empty. It cannot be empty.", path )
end

# reading the component and subsystem elements:
num_subsyss = 0
for elm in eachelement( sys_root )
  tag = elm.name
  if tag == "component"
    check_component( elm )
  elseif tag == "subsystem"
    num_subsyss = num_subsyss + 1
    if num_subsyss > 1
      isdf_error( "Currently, only one subsystem is allowed in the definition of an industrial system. More than one subsystem is found.", nodepath( elm ) )
    end
    check_component( elm, true )
  end
end

# returning the entire system as an EzXML document:
return sys

end
