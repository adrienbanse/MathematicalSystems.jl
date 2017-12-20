@testset "Continuous linear system" begin
    for sd in 1:3
        s = LinearContinuousSystem(zeros(sd, sd))
        @test statedim(s) == sd
        @test inputdim(s) == 0
    end
end

@testset "Continuous linear control system" begin
    for sd in 1:3
        s = LinearControlContinuousSystem(zeros(sd, sd), ones(sd, sd))
        @test statedim(s) == sd
        @test inputdim(s) == sd
    end
end

@testset "Continuous constrained linear system" begin
    A = [1. 1; 1 -1]
    X = Line([1., -1], 0.) # line x = y
    s = ConstrainedLinearContinuousSystem(A, X)
    @test statedim(s) == 2
    @test inputdim(s) == 0
end

@testset "Continuous constrained linear control system" begin
    A = [1. 1; 1 -1]
    B = [0.5 1.5]'
    X = Line([1., -1], 0.)
    U = Hyperrectangle(low=[0.9, 0.9], high=[1.1, 1.2])
    s = ConstrainedLinearControlContinuousSystem(A, B, X, U)
    @test statedim(s) == 2
    @test inputdim(s) == 1
end
