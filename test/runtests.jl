using MathematicalSystems, LazySets, TypedPolynomials
using SparseArrays, LinearAlgebra
using InteractiveUtils: subtypes
using Test

# fix namespace conflicts with LazySets
using MathematicalSystems: LinearMap, AffineMap, ResetMap

const SECOND_ORDER_CTYPES = [SecondOrderAffineContinuousSystem,
                             SecondOrderConstrainedAffineControlContinuousSystem,
                             SecondOrderConstrainedLinearControlContinuousSystem,
                             SecondOrderLinearContinuousSystem]

@testset "Utilities" begin
    include("utilities.jl")
end
@testset "Abstract systems" begin
    include("abstract.jl")
end
@testset "Continuous systems" begin
    include("continuous.jl")
end
@testset "Discrete systems" begin
    include("discrete.jl")
end
@testset "Identity multiple" begin
    include("identity.jl")
end
@testset "Inputs" begin
    include("inputs.jl")
end
@testset "Maps" begin
    include("maps.jl")
end
@testset "Outputs" begin
    include("outputs.jl")
end
@testset "Successor of discrete system" begin
    include("successor.jl")
end
@testset "Vector field of continuous system" begin
    include("vector_field.jl")
end
@testset "Discretize continuous system" begin
    include("discretize.jl")
end
@testset "Instantiate" begin
    include("instantiate.jl")
end
@testset "Initial-value problem" begin
    include("ivp.jl")
end
@testset "@system macro" begin
    include("@system.jl")
end
@testset "@ivp macro" begin
    include("@ivp.jl")
end
@testset "Other macros" begin
    include("macros.jl")
end
