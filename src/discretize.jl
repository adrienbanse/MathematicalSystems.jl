"""
    AbstractDiscretizationAlgorithm

Abstract supertype for all discretization algorithms.

### Note

For implementing a custom discretization algorithm, a type definition
`struct NewDiscretizationAlgorithm <: AbstractDiscretizationAlgorithm end`
and a `_discretize` method

```julia
_discretize(::NewDiscretizationAlgorithm, ΔT::Real,
             A::AbstractMatrix, B::AbstractMatrix, c::AbstractVector, D::AbstractMatrix)
```
are required.
"""
abstract type AbstractDiscretizationAlgorithm end

"""
    ExactDiscretization <: AbstractDiscretizationAlgorithm

Exact discretization algorithm for affine systems.

### Algorithm

This algorithm consists of integrating the continuous differential equation over
a specified time interval to obtain an associated difference equation.
The algorithm applies to any system of the form `x' = Ax + Bu + c + Dw` where the
state matrix `A` is invertible, and other system types, e.g. linear systems
`x' = Ax` which are included in the above formulation.

Without loss of generality, consider a `NoisyAffineControlledContinuousSystem`
with system dynamics ``x' = Ax + Bu + c + Dw``.

The exact discretization is calculated by integrating on both sides of the
continuous ODE over the time span `[t, t + ΔT]`, for a fixed input `u` and fixed
noise realization `w` at time `t`.
The resulting discretization writes as
``x^+ = A^d x + B^d u + c^d  + D^d w`` where
``A^d = \\exp^{A ~ ΔT}``,
``B^d = A^{-1}(A^d - I)B``,
``c^d = A^{-1}(A^d - I)c`` and
``D^d = A^{-1}(A^d - I)D``.

The algorithm described above is a well known result from the literature [1].

[1] https://en.wikipedia.org/wiki/Discretization#Discretization_of_linear_state_space_models
"""
struct ExactDiscretization <: AbstractDiscretizationAlgorithm end

"""
    EulerDiscretization <: AbstractDiscretizationAlgorithm

Euler discretization algorithm for affine systems.

### Algorithm

This algorithm consists of a first-order approximation to obtain an associated
difference equation. The algorithm applies to any system of the form
`x' = Ax + Bu + c + Dw`, and other system types, e.g. linear systems `x' = Ax`
which are included in the above formulation.

Without loss of generality, consider a `NoisyAffineControlledContinuousSystem`
with system dynamics ``x' = Ax + Bu + c + Dw``.

The Euler discretization is calculated by taking the first-order approximation
of the exact discretization [`ExactDiscretization`](@ref).
The resulting discretization writes as
``x^+ = A^d x + B^d u + c^d + D^d w``
where  ``A^d = I + ΔT ~ A``, ``B^d = ΔT ~ B``,
``c^d = ΔT ~ c`` and ``D^d = ΔT ~ D``.

The algorithm described above is a well known result from the literature [1].

[1] https://en.wikipedia.org/wiki/Discretization#Approximations
"""
struct EulerDiscretization <: AbstractDiscretizationAlgorithm end

"""
    discretize(system::AbstractContinuousSystem, ΔT::Real,
               algorithm::AbstractDiscretizationAlgorithm=ExactDiscretization(),
               constructor=_default_complementary_constructor(system))

Discretization of a `isaffine` `AbstractContinuousSystem` to a
`AbstractDiscreteSystem` with sampling time `ΔT` using the discretization
method `algorithm`.

### Input

- `system`      -- an affine continuous system
- `ΔT`          -- sampling time
- `algorithm`   -- (optional, default: `ExactDiscretization()`) discretization algorithm
- `constructor` -- (optional, default: `_default_complementary_constructor(system)`) construction method

### Output

Returns a discretization of the input system `system` with discretization method
`algorithm` and sampling time `ΔT`.
"""
function discretize(system::AbstractContinuousSystem, ΔT::Real,
                    algorithm::AbstractDiscretizationAlgorithm=ExactDiscretization(),
                    constructor=_default_complementary_constructor(system))
    (!isaffine(system)) && throw(ArgumentError("system needs to be affine"))

    sets(x) = x ∈ [:X, :U, :W]
    matrices(x) = x ∈ [:A, :B, :b, :c, :D]

    # get all fields from system
    fields = collect(fieldnames(typeof(system)))

    # get the fields of `system` that are parameters of the affine system dynamics
    # i.e., all fields that need to be discretized
    cont_values = [getfield(system, f) for f in filter(matrices, fields)]

    # compute discretized values of dynamics_params_c
    disc_values = _discretize(algorithm, ΔT, cont_values...)
    # get the fields of `system` that are sets
    set_values = [getfield(system, f) for f in filter(sets, fields)]

    # build the new discrete type according to the constructor method with the
    # discretized and set values
    return constructor(disc_values, set_values)
end

# returns a function with signature 'Vector × Vector -> AbstractDiscreteSystem'
function _default_complementary_constructor(system)
    # get corresponding discrete type of `system`
    discrete_type = _complementary_type(typename(system))
    # build the new discrete type with the discretized and set values
    return (disc_values, set_values) -> discrete_type(disc_values..., set_values...)
end

"""
    _discretize(::AbstractDiscretizationAlgorithm, ΔT::Real
                A::AbstractMatrix, B::AbstractMatrix, c::AbstractVector, D::AbstractMatrix)

Implementation of the discretization algorithm defined by the first input argument
with sampling time `ΔT`.

### Input

- ``   -- discretization algorithm, used for dispatch
- `ΔT` -- sampling time
- `A`  -- state matrix
- `B`  -- input matrix
- `c`  -- vector
- `D`  -- noise matrix

### Output

Returns a vector containing the discretized input arguments `A`, `B`, `c` and `D`.

### Notes

See [`discretize`](@ref) for more details.
"""
function _discretize(::AbstractDiscretizationAlgorithm, ΔT::Real,
                     A::AbstractMatrix,
                     B::AbstractMatrix,
                     c::AbstractVector,
                     D::AbstractMatrix)
end

function _discretize(::ExactDiscretization, ΔT::Real,
                     A::AbstractMatrix,
                     B::AbstractMatrix,
                     c::AbstractVector,
                     D::AbstractMatrix)
    if rank(A) == size(A, 1)
        A_d = exp(A * ΔT)
        Matr = inv(A) * (A_d - I)
        B_d = Matr * B
        c_d = Matr * c
        D_d = Matr * D
    else
        throw(ArgumentError("exact discretization for singular state matrix " *
                            "(i.e., A is non-invertible) is not implemented; " *
                            "use the `EulerDiscretization` algorithm"))
    end
    return [A_d, B_d, c_d, D_d]
end

function _discretize(::EulerDiscretization, ΔT::Real,
                     A::AbstractMatrix,
                     B::AbstractMatrix,
                     c::AbstractVector,
                     D::AbstractMatrix)
    A_d = I + ΔT * A
    B_d = ΔT * B
    c_d = ΔT * c
    D_d = ΔT * D
    return [A_d, B_d, c_d, D_d]
end

"""
    _discretize(A::AbstractMatrix, ΔT::Real; algorithm=:exact)

Discretize the state matrix `A` with sampling time `ΔT` and discretization method
`algorithm`.

### Input

- `A`         -- state matrix
- `ΔT`        -- sampling time
- `algorithm` -- (optional, default: `:exact`) discretization algorithm

### Output

Returns a vector containing the discretized input argument `A`.

### Notes

See [`discretize`](@ref) for more details.
"""
function _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                     A::AbstractMatrix)
    n = size(A, 1)
    mzero = spzeros(n, n)
    vzero = spzeros(n)
    A_d, _, _, _ = _discretize(algorithm, ΔT, A, mzero, vzero, mzero)
    return [A_d]
end

"""
    _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                A::AbstractMatrix, B::AbstractMatrix)

Discretize the state matrix `A` and input or noise matrix `B` with sampling time
`ΔT` and discretization method `algorithm`.

### Input

- `algorithm` -- discretization algorithm
- `ΔT`        -- sampling time
- `A`         -- state matrix
- `B`         -- input or noise matrix

### Output

Returns a vector containing the discretized input arguments `A` and `B`.

### Notes

This method signature with two arguments of type `AbstractMatrix` works both for
a noisy system with fields `(:A,:D)` and a controlled system with fields `(:A,:B)`.

See [`discretize`](@ref) for more details.
"""
function _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                     A::AbstractMatrix, B::AbstractMatrix)
    n = size(A, 1)
    mzero = spzeros(n, n)
    vzero = spzeros(n)
    A_d, B_d, _, _ = _discretize(algorithm, ΔT, A, B, vzero, mzero)
    return [A_d, B_d]
end

"""
    _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                A::AbstractMatrix,c::AbstractVector)

Discretize the state matrix `A` and vector `c` with sampling time `ΔT` and
discretization method `algorithm`.

### Input

- `algorithm` -- discretization algorithm
- `ΔT`        -- sampling time
- `A`         -- state matrix
- `c`         -- vector

### Output

Returns a vector containing the discretized input arguments `A` and `c`.

### Notes

See [`discretize`](@ref) for more details.
"""
function _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                     A::AbstractMatrix, c::AbstractVector)
    n = size(A, 1)
    mzero = spzeros(n, n)
    A_d, _, c_d, _ = _discretize(algorithm, ΔT, A, mzero, c, mzero)
    return [A_d, c_d]
end

"""
    _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                A::AbstractMatrix, B::AbstractMatrix, c::AbstractVector)

Discretize the state matrix `A`, input matrix `B` and vector `c` with sampling
time `ΔT` and discretization method `algorithm`.

### Input

- `algorithm` -- discretization algorithm
- `ΔT`        -- sampling time
- `A`         -- state matrix
- `B`         -- input matrix
- `c`         -- vector

### Output

Returns a vector containing the discretized input arguments `A`, `B` and `c`.

### Notes

See [`discretize`](@ref) for more details.
"""
function _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                     A::AbstractMatrix, B::AbstractMatrix, c::AbstractVector)
    n = size(A, 1)
    mzero = spzeros(n, n)
    A_d, B_d, c_d, _ = _discretize(algorithm, ΔT, A, B, c, mzero)
    return [A_d, B_d, c_d]
end

"""
    _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                A::AbstractMatrix, B::AbstractMatrix, D::AbstractMatrix)

Discretize the state matrix `A`, input matrix `B` and noise matrix `C` with
sampling time `ΔT` and discretization method `algorithm`.

### Input

- `algorithm` -- discretization algorithm
- `ΔT`        -- sampling time
- `A`         -- state matrix
- `B`         -- input matrix
- `D`         -- noise matrix

### Output

Returns a vector containing the discretized input arguments `A`, `B` and `D`.

### Notes

See [`discretize`](@ref) for more details.
"""
function _discretize(algorithm::AbstractDiscretizationAlgorithm, ΔT::Real,
                     A::AbstractMatrix, B::AbstractMatrix, D::AbstractMatrix)
    n = size(A, 1)
    vzero = spzeros(n)
    A_d, B_d, _, D_d = _discretize(algorithm, ΔT, A, B, vzero, D)
    return [A_d, B_d, D_d]
end
