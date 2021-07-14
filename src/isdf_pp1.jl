function isdf_pp1( filename )  #=

perform the preprocessing stage 1 which includes

- error checking
- expansion of the use sections

and returns the result as an EzXML document.

Author: Taku Noda
Started on Nov. 29, 2020
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

if length( filename ) <= 4
  omegasim_error( "The file name is too short." )
end
ext = filename[ ( end - 3 ):end ]
if ext != ".xml"
  omegasim_error( "The file extension must be \".xml\"." )
end
filename_pp1 = ( filename[ 1:( end - 4 ) ] )*".pp1.xml"

sys = read_isdf( filename )
sys_pp1 = expand_uses( sys )

io = open( filename_pp1, "w" )
prettyprint( io, sys_pp1 )
close( io )

return sys_pp1

end
