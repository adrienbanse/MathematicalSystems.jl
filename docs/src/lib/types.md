# Types

This section describes systems types implemented in `MathematicalSystems.jl`.

```@contents
Pages = ["types.md"]
Depth = 3
```

```@meta
CurrentModule = MathematicalSystems
DocTestSetup = quote
    using MathematicalSystems
end
```

## Abstract Systems

```@docs
AbstractSystem
AbstractContinuousSystem
AbstractDiscreteSystem
```

## Continuous Systems

```@docs
ContinuousIdentitySystem
ConstrainedContinuousIdentitySystem
LinearContinuousSystem
AffineContinuousSystem
LinearControlContinuousSystem
AffineControlContinuousSystem
ConstrainedLinearContinuousSystem
ConstrainedAffineContinuousSystem
ConstrainedAffineControlContinuousSystem
ConstrainedLinearControlContinuousSystem
LinearDescriptorContinuousSystem
ConstrainedLinearDescriptorContinuousSystem
PolynomialContinuousSystem
ConstrainedPolynomialContinuousSystem
BlackBoxContinuousSystem
ConstrainedBlackBoxContinuousSystem
BlackBoxControlContinuousSystem
ConstrainedBlackBoxControlContinuousSystem
NoisyLinearContinuousSystem
NoisyConstrainedLinearContinuousSystem
NoisyLinearControlContinuousSystem
NoisyConstrainedLinearControlContinuousSystem
NoisyAffineControlContinuousSystem
NoisyConstrainedAffineControlContinuousSystem
NoisyBlackBoxControlContinuousSystem
NoisyConstrainedBlackBoxControlContinuousSystem
SecondOrderLinearContinuousSystem
SecondOrderAffineContinuousSystem
SecondOrderConstrainedAffineControlContinuousSystem
SecondOrderConstrainedLinearControlContinuousSystem
SecondOrderContinuousSystem
SecondOrderConstrainedContinuousSystem
```

## Discrete Systems

```@docs
DiscreteIdentitySystem
ConstrainedDiscreteIdentitySystem
LinearDiscreteSystem
AffineDiscreteSystem
LinearControlDiscreteSystem
AffineControlDiscreteSystem
ConstrainedLinearDiscreteSystem
ConstrainedAffineDiscreteSystem
ConstrainedLinearControlDiscreteSystem
ConstrainedAffineControlDiscreteSystem
LinearDescriptorDiscreteSystem
ConstrainedLinearDescriptorDiscreteSystem
PolynomialDiscreteSystem
ConstrainedPolynomialDiscreteSystem
BlackBoxDiscreteSystem
ConstrainedBlackBoxDiscreteSystem
BlackBoxControlDiscreteSystem
ConstrainedBlackBoxControlDiscreteSystem
NoisyLinearDiscreteSystem
NoisyConstrainedLinearDiscreteSystem
NoisyLinearControlDiscreteSystem
NoisyConstrainedLinearControlDiscreteSystem
NoisyAffineControlDiscreteSystem
NoisyConstrainedAffineControlDiscreteSystem
NoisyBlackBoxControlDiscreteSystem
NoisyConstrainedBlackBoxControlDiscreteSystem
SecondOrderLinearDiscreteSystem
SecondOrderAffineDiscreteSystem
SecondOrderConstrainedAffineControlDiscreteSystem
SecondOrderConstrainedLinearControlDiscreteSystem
SecondOrderDiscreteSystem
SecondOrderConstrainedDiscreteSystem
```

#### Discretization Algorithms

```@docs
AbstractDiscretizationAlgorithm
ExactDiscretization
EulerDiscretization
```

## System macro

```@docs
@system
```

## Initial-value problem macro

```@docs
@ivp
```

## Identity operator

```@docs
IdentityMultiple
Id
```

## Initial Value Problems

```@docs
InitialValueProblem
IVP
initial_state
system
```

## Input Types

```@docs
AbstractInput
ConstantInput
VaryingInput
```

## Maps

```@docs
AbstractMap
IdentityMap
ConstrainedIdentityMap
LinearMap
ConstrainedLinearMap
AffineMap
ConstrainedAffineMap
LinearControlMap
ConstrainedLinearControlMap
AffineControlMap
ConstrainedAffineControlMap
ResetMap
ConstrainedResetMap
```

### Macros

```@docs
@map
```

## Systems with output

```@docs
SystemWithOutput
LinearTimeInvariantSystem
LTISystem
```


## Vector Field
```@docs
VectorField
```
