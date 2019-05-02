"""
    times(ls,n)

Returns the presence of the given node in the link stream.
"""
function times(ls::Union{LinkStream,DirectedLinkStream}, n::String)
    name ∈ ls ? ls.T : []
end

"""
    times(s,n)

Returns the presence of the given node in the stream graph.
"""
function times(s::Union{StreamGraph,DirectedStreamGraph}, n::String)
    name ∈ s ? s.W[name].presence : IntervalUnion()
end

"""
    times(ls,from,to)

Returns the presence of the given link in the directed link stream.
"""
function times(ls::AbstractDirectedStream, from::String, to::String)
    (haskey(ls.E,from) && haskey(ls.E[from],to)) ? ls.E[from][to].presence : IntervalUnion()
end

"""
    times(ls,from,to)

Returns the presence of the given link in the undirected link stream.
"""
function times(ls::AbstractUndirectedStream, from::String, to::String)
    if from == to
        return IntervalUnion()
    elseif from > to
        from,to = to,from
    end
    if haskey(ls.E,from)
        if haskey(ls.E[from],to)
            return ls.E[from][to].presence
        else
            return IntervalUnion()
        end
    else
        return IntervalUnion()
    end
end

function times(ls::Union{LinkStream,DirectedLinkStream})
    evt = Set{Real}([ls.T.list[1][1],ls.T.list[1][2]])
    for l in links(ls)
        for interv in l.presence.list
            push!(evt,interv[1])
            push!(evt,interv[2])
        end
    end
    sort(collect(evt))
end

function times(s::Union{StreamGraph,DirectedStreamGraph})
    evt = Set{Float64}([s.T.list[1][1],s.T.list[1][2]])
    for n in nodes(s)
        for interv in n.presence.list
            push!(evt,interv[1])
            push!(evt,interv[2])
        end
    end
    for l in links(s)
        for interv in l.presence.list
            push!(evt,interv[1])
            push!(evt,interv[2])
        end
    end
    sort(collect(evt))
end
