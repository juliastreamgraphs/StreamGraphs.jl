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

@testset "Intervals Tests" begin
    @info "Check Intervals operations"
    include("intervals.jl")
end

@testset "Node Tests" begin
    @info "Check Nodes"
    include("nodes.jl")
end

@testset "Link Tests" begin
    @info "Check Links"
    include("links.jl")
end
