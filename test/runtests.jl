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

@testset "LinkStream Tests" begin
    @info "Check LinkStreams"
    include("link_streams.jl")
end

@testset "StreamGraph Tests" begin
    @info "Check StreamGraphs"
    include("stream_graphs.jl")
end

@testset "Jump Tests" begin
    @info "Check Jumps"
    include("jumps.jl")
end

@testset "Path Tests" begin
    @info "Check Paths"
    include("paths.jl")
end
