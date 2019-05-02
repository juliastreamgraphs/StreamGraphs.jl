"""
    l1 == l2

Equality between Links.
"""
function ==(l1::Link, l2::Link)
    (l1.name == l2.name) && (l1.presence == l2.presence) && (l1.from == l2.from) && (l1.to==l2.to)
end

"""
    links(s)

Returns all the links in the given stream.
"""
function links(s::AbstractStream)
    [l for (k,v) in s.E for (kk,l) in v]
end

"""
    links(s,t)

Returns all the links present at time t in stream s.
"""
function links(s::AbstractStream, t::Real)
    [l for (k,v) in s.E for (kk,l) in v if t ∈ l]
end

"""
    links(s,from,to)

Returns the link between from and to in the directed stream.
"""
function links(s::AbstractDirectedStream, from::String, to::String)
    if haskey(s.E,from) && haskey(s.E[from],to)
        return s.E[from][to]
    else
        throw("Link ($(from),$(to)) does not exist in stream $(s.name).")
    end
end

"""
    links(s,from,to)

Returns the link between from and to in the undirected stream.
"""
function links(s::AbstractUndirectedStream, from::String, to::String)
    if from < to
        if haskey(s.E,from) && haskey(s.E[from],to)
            return s.E[from][to]
        else
            trow("Link ($(from),$(to)) does not exist in stream $(s.name).")
        end
    else
        if haskey(s.E,to) && haskey(s.E[to],from)
            return s.E[to][from]
        else
            throw("Link ($(to),$(from)) does not exist in stream $(s.name).")
        end
    end
end

"""
    links_from(s,n)

Returns all the links starting at the given node in the given directed stream.
"""
function links_from(s::AbstractDirectedStream, n::String)
    haskey(s.E,n) ? s.E[n] : []
end

"""
    links_to(s,n)

Returns all the links ending at the given node in the given directed stream.
"""
function links_to(s::AbstractDirectedStream, n::String)
    [l for l in to[node] for (from,to) in s.E if haskey(to,node)]
end

"""
    links(s,n)

Returns all the links where the given node is an end point in the given undirected stream.
"""
function links(s::AbstractUndirectedStream, n::String)
    result = Link[]
    for (from,access) in s.E
        if from == node
            for (to,l) in access
                push!(result,l)
            end
        else
            for (to,l) in access
                if to == node
                    push!(result,l)
                end
            end
        end
    end
    result
end

"""
    links(s,t0,t1)

Returns all the links of the given stream which presence intersects with [t0,t1].
"""
function links(s::AbstractStream, t0::Real, t1::Real)
    t0 > t1 && return []
    result = Link[]
    t0t1 = IntervalUnion([Interval(t0,t1)])
    for (k,v) in s.E
        for (kk,l) in v
            inter = t0t1 ∩ l.presence
            if !empty(inter)
                push!(result, Link(l.name, inter, l.from, l.to))
            end
        end
    end
    result
end

"""
    links(s,n,t0,t1)

Returns all the links of the given stream which presence intersects with [t0,t1] and where one of the end points is n.
"""
function links(s::AbstractStream, n::String, t0::Real, t1::Real)
    t0 > t1 && return []
    result = Link[]
    t0t1 = IntervalUnion([Interval(t0,t1)])
    for (k,v) in s.E
        for (kk,l) in v
            if l.from == node || l.to == node
                inter = t0t1 ∩ l.presence
                if !empty(inter)
                    push!(result, Link(l.name, inter, l.from, l.to))
                end
            end
        end
    end
    result
end

"""
    links(tc)

Returns the links at the current TimeCursor's state.
"""
function links(tc::TimeCursor)
    tc.S.links
end

"""
    links(tc,t0,t1)

Returns all the links of the TimeCursor present at some point in [t0,t1].
"""
function links(tc::TimeCursor, t0::Real, t1::Real)
    L = Set{Tuple{AbstractString,AbstractString}}()
    goto!(tc,t0)
    haskey(tc.T,t0) && previous!(tc)
    L = L ∪ links(tc)
    while tc.S.t1 < t1
        next!(tc)
        L = L ∪ links(tc)
    end
    if haskey(tc.T,t1)
        next!(tc)
        L = L ∪ links(tc)
    end
    L
end

"""
    links(tc,t)
"""
function links(tc::TimeCursor, t::Real)
    goto!(tc,t)
    if haskey(tc.T,t)
        s1 = links(tc)
        previous!(tc)
        return s1 ∪ links(tc)
    else
        return links(tc)
    end
end

"""
    links(s,tc,t)
"""
function links(s::AbstractStream, tc::TimeCursor, t::Real)
    links(tc,t)
end

"""
    links(s,tc,t0,t1)
"""
function links(s::AbstractStream, tc::TimeCursor, t0::Real, t1::Real)
    t0 > t1 && return []
    result = Link[]
    t0t1 = IntervalUnion([Interval(t0,t1)])
    l = links(tc,t0,t1)
    for ll in l
        if haskey(s.E,ll[1]) && haskey(s.E[ll[1]],ll[2])
            temp = s.E[ll[1]][ll[2]]
        elseif haskey(s.E,ll[2]) && haskey(s.E[ll[2]],ll[1])
            temp = s.E[ll[2]][ll[1]]
        else
            throw("Unknown link $(ll)")
        end
        inter = t0t1 ∩ temp.presence
        if !empty(inter)>0
            push!(result, Link(temp.name, inter, temp.from, temp.to))
        end
    end
    result
end
