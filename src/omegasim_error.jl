function omegasim_error( errmsg, filename = "" )  #=

prints an error message given as the first argument "errmsg" and then immediately stops the execution. If a file name is given as the second argument "filename" which can be omitted, then which file was being read when the error occurred is also reported.

Author: Taku Noda
Started on Nov. 16, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#

println( "" )
println( "omegasim error:" )
println( errmsg )
if !isempty( filename )
  println( "" )
  println( "The error ocurred in file: $filename." )
end

# exit( 1 )  # currently commented out to avoid the termination of Julia environment when an error occurs. This should be decommented when the program is released for practical use.

end
