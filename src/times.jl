times(ls::Union{LinkStream,DirectedLinkStream}, name::AbstractString)=name ∈ ls ? ls.T : []

times(s::Union{StreamGraph,DirectedStreamGraph}, name::AbstractString)=name ∈ s ? s.W[name].presence : Intervals()

times(ls::AbstractDirectedStream, from::AbstractString, to::AbstractString)=haskey(ls.E,from)&haskey(ls.E[from],to) ? ls.E[from][to].presence : Intervals()

function times(ls::AbstractUndirectedStream, from::AbstractString, to::AbstractString)
    if from==to
        return Intervals()
    elseif from>to
        from,to=to,from
    end
    if haskey(ls.E,from)
        if haskey(ls.E[from],to)
            return ls.E[from][to].presence
        else
            return Intervals()
        end
    else
        return Intervals()
    end
end

function times(ls::Union{LinkStream,DirectedLinkStream})
    evt = Set{Float64}([ls.T.list[1][1],ls.T.list[1][2]])
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
