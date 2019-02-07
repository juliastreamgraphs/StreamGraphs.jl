using StreamGraphs
using Test
using Logging

# Testing tuples
gl = global_logger()
global_logger(ConsoleLogger(gl.stream, Logging.Error))

@testset "Tuple Tests" begin
    @info "Check tuple equality approximation"
    include("tuples.jl")
end
