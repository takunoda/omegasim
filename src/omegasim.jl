
module omegasim  #=

is the module definition of the Julia package "omegasim".

omegasim aims at practical simulations of composite industrial systems. A composite system consists of two or more subsystems characterized by different response time scales. In omegasim, different simulation methods are used for subsystems with different response time scales, and inputs and outputs of those subsystems are interconnected for the whole system simulation. This feature is quite reasonable for the simulation of industrial systems which are inherently composed of two or more subsystems with different response time scales. Currently, omegasim has the following two time-domain simulation methods.

1. Transient simulation method.
2. Phasor simulation method.

Before talking about these methods, let us define scientific terms. When a system does not include distributed-parameter elements, then it can be fully described by a set of differential and algebraic equations, or DAEs for short. Differential equations describe the behavior of dynamic elements, whereas algebraic equations describe that of time-independent elements. The equations also describe the relationships among those elements. Since a set of DAEs fully describes a system, it is also called a descriptor system.

The transient simulation method solves the DAEs of a subsystem in a straightforward way with respect to time. Each nonlinearity which exists in the subsystem is represented by a piecewise linear curve, since a nonlinearity is usually given as point-list data for most industrial systems. And the point-list data immediately give a piecewise linear representation. Since a subsystem in an industrial system is often stiff, it must be solved by an L-stable integration scheme which does not produce spurious or non-existing numerical oscillation. An L-stable integration scheme is an implicit scheme, and a set of simultaneous nonlinear equations therefore has to be solved at each time step. The piecewise linear representation of nonlinearity mentioned above is also suitable for solving the set of nonlinear equations. This is because its convergence in the solution process is detected by a fairly simple condition. After all, the transient simulation method is summarized as follows. First, all nonlinearities in the subsystem are represented by piecewise linear curves, and then the resultant set of DAEs is integrated using an L-stable integration scheme of your choice with respect to time by solving the set of piecewise linear equations obtained at each time step.

Considering the overall response time scale, the responses of some subsystems are quite fast and negligible and can be substituted by their steady-state ones. In this case, the steady-state response can be obtained by solving a set of algebraic equations describing the subsystem. The subsystem may operate on a sinusoidal carrier. If this is the case, the solution of the algebraic equations is complex-valued, where its absolute value and argument respectively give the magnitude and phase angle of the sinusoidal carrier. The algebraic equations are solved at each time step and repeated as time evolves, and the solution follows the variation of the sinusoidal carrier with respect to time. This method is often called the phasor simulation method. If the subsystem operates on a dc signal basis, then the solution of its algebraic equations becomes real-valued. This can be considered as a special case of the phasor simulation method.

omegasim uses a constant time step size for all subsystems, since this strategy is reasonable for the simulation of industrial systems. Consider this awkward but real situation. The designers of industrial systems are engineers. When those engineers implement, for instance, a digital PI controller, they use fairly simple numerical integration algorithm such as the forward Euler method, the trapezoidal method and so on with a constant time step. Do we have to use an elaborate numerical integration algorithm with variable time steps for the simulation of such a system, as suggested by applied mathematicians? The answer is of course not. This is the primary reason why I, an engineer, have started creating omegasim.

At each time step, the responses of all subsystems are calculated as their outputs. Then, considering the interconnected topology, those outputs are considered as the inputs to the subsystems with allowing one time step delay. The whole system is divided into subsystems so that the one time step delay does not affect the solution. For industrial systems, this process should not be difficult, since existing subsystems are actually designed to allow one time step delay. So, once the responses of all subsystems have been calculated, the output-to-input interconnection process can be carried out by simple substitutions, and this process is repeated with respect to time so that the response of the whole system is obtained.

An industrial system often has one or more electrical circuits as part of the system. To deal with electrical circuits, omegasim has methods to derive the DAEs of a given electrical circuit.

omegasim also has stability analysis functions ...

Author: Taku Noda
Started on Oct. 31, 2019
Update on June 29, 2021

Copyright 2021 Central Research Institute of Electric Power Industry

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=#


# -- Packages used in this modeule -------------------------------------

using EzXML
using LinearAlgebra
using SparseArrays
using Plots


# -- Structure definitions ---------------------------------------------

struct Component  #=
is used to store component definitions when reading an iSDF file.
=#
  name::String  # name of the component.
  type::String  # type of the component.
  calc::String  # content of the calc section of the component.
  root::EzXML.Node  # EzXML pointer to this component definition.
end

struct Subsystem  #=
is used to store subsystem definitions when reading an iSDF file.
=#
  name::String  # name of the subsystem.
  type::String  # type of the subsystem.
  calc::String  # content of the calc section of the subsystem.
  root::EzXML.Node  # EzXML pointer to this subsystem definition.
end

struct Use  #=
is used to store use declarations when reading an iSDF file.
=#
  cmpnnt_id::Int  # id of the component to be used.
  as::String  # name of the instance generated by this use declaration.
  use_elm::EzXML.Node  # EzXML pointer to this use declaration.
  subst::String  # content of the use declaration (variable substitutions).
end

struct Branch  #=
holds the information of a branch, or an electrical component. It is assumed that an array of the struct branch will be created for each circuit and the array holds information of all branches in the circuit.
=#
  # fields used by all branches:
  name::String  # name of the branch
  type::String  # type of the branch
  nph::Int  # number of phases
  val::Expr  # val(s) of the branch; given as an Expr to accept different formats defined by different types
  lhs::Vector{ Int }  # left-hand-side node numbers
  rhs::Vector{ Int }  # right-hand-side node numbers
  p_vars::Int  # pointer to the state variables of the branch
  # fields used by dynamic branches:
  p_de::Int  # pointer to the 1st differential equation
  # fields used by nonlinear and source branches:
  p_ns::Int  # pointer to nonlinear or source variable in u
  plx::Array{ Float64 }  # point list data (x, y) to represent the
  ply::Array{ Float64 }  # piecewise linear curve of this branch.
  op::Array{ Int }  # operating point of this branch.
end

struct Records  #=
is used to store calculation results .
=#
end


# -- Global variables --------------------------------------------------

t = 0.0  # time.


# -- Type definition ---------------------------------------------------

BranchTypes = (
  "R",  # linear resistor (single- or multiphase)
  "L",  # linear inductor (single- or multiphase)
  "G",  # linear conductance (single- or multiphase)
  "C",  # linear capacitor (single- or multiphase)
  "NR",  # nonlinear resistor (single-phase only)
  "NL",  # nonlinear inductor (single-phase only)
  "NC",  # nonlinear capacitor (single-phase only)
  "E",  # voltage source (single-phase only)
  "J",  # current source (single-phase only)
  "Sw",  # time controlled switch (single-phase only)
  "CR",  # controlled resistor (single-phase only)
  "CSw",  # controlled switch (single-phase only)
  "CE",  # controlled voltage source (single-phase only)
  "CJ",  # controlled current source (single-phase only)
  "VP",  # voltage probe (single-phase only)
  "CP" )  # current probe (single-phase only)


# -- Files to be included ----------------------------------------------

# iSDF-related source files:
include( "isdf_error.jl" )
include( "ordinal_string.jl" )
include( "check_component.jl" )
include( "read_isdf.jl" )
include( "expand_uses.jl" )
include( "isdf_pp1.jl" )
# omegasim source files:
include( "omegasim_error.jl" )
include( "collect_nodes.jl" )
include( "collect_branches.jl" )
include( "build_Ac.jl" )
include( "build_ZYB!.jl" )
include( "discretize_dyns!.jl" )
include( "update_y!.jl" )
# omegasim
include( "extract_nodes_branches.jl" )
include( "calc_submatrices.jl" )
include( "build_F0_tr.jl" )
include( "transient.jl" )


# -- Test code ---------------------------------------------------------

function test()
  filename = "test01.xml"
  h = 0.05e-3
  Tmax = 20.0e-3
  #
  nbset = extract_nodes_branches( filename )
  smset = calc_submatrices( nbset )
  F = build_F0_tr( nbset, smset )
  transient( F, nbset, h, Tmax )
  #
  return nothing
end


# -- This is the end of the module omegasim ----------------------------

end
