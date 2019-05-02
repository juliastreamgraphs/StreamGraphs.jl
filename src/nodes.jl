"""
    a == b

Nodes equality.
"""
function ==(a::Node, b::Node)
    (a.name==b.name) && (a.presence==b.presence)
end

"""
    nodes(ls)

Returns all the nodes of the given link stream. 
"""
function nodes(ls::Union{LinkStream,DirectedLinkStream})
    ls.V
end

"""
    nodes(ls,t)

Returns all the nodes of the given link stream present at t, which is all the nodes by definition of a LinkStream.
"""
function nodes(ls::Union{LinkStream,DirectedLinkStream}, t::Real)
    nodes(ls)
end

"""
    nodes(ls,t0,t1)

Returns all the nodes of the given link stream present at some point between t0 and t1, which is all the nodes by definition of a LinkStream.
"""
function nodes(ls::Union{LinkStream,DirectedLinkStream}, t0::Real, t1::Real)
    nodes(ls)
end

"""
    nodes(s,t)

Returns all the nodes of the given stream graph present at t.
"""
function nodes(s::Union{StreamGraph,DirectedStreamGraph}, t::Real)
    [n for (n,interv) in s.W if t ∈ interv]
end

"""
    nodes(s)

Returns all the nodes names in the stream graph.
"""
function nodes(s::Union{StreamGraph,DirectedStreamGraph})
    [b for (a,b) in s.W]
end

"""
    nodes(s,t0,t1)

Returns all the nodes of the given stream graph present at some point between t0 and t1.
"""
function nodes(s::Union{StreamGraph,DirectedStreamGraph}, t0::Real, t1::Real)
    if t0 <= t1
        [n for (n,interv) in s.W if !empty(IntervalUnion([Interval(t0,t1)]) ∩ interv)]
    else
        []
    end
end

"""
    nodes(tc)
"""
function nodes(tc::TimeCursor)
    length(tc.S.nodes) > 0 && return tc.S.nodes
    res = Set{AbstractString}()
    if length(tc.S.links) > 0
        for l in tc.S.links
            push!(res,l[1])
            push!(res,l[2])
        end
        return res
    else
        return Set{AbstractString}()
    end
end

"""
    nodes(tc,t)
"""
function nodes(tc::TimeCursor, t::Real)
    goto!(tc,t)
    if haskey(tc.T,t)
        s1 = nodes(tc)
        previous!(tc)
        return s1 ∪ nodes(tc)
    else
        return nodes(tc)
    end
end

"""
    nodes(tc,t0,t1)
"""
function nodes(tc::TimeCursor, t0::Real, t1::Real)
    N = Set{AbstractString}()
    goto!(tc,t0)
    haskey(tc.T,t0) && previous!(tc)
    N = N ∪ nodes(tc)
    while tc.S.t1 < t1
        next!(tc)
        N = N ∪ nodes(tc)
    end
    if haskey(tc.T,t1)
        next!(tc)
        N = N ∪ nodes(tc)
    end
    N
end
