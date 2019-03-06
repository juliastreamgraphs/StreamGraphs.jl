==(l1::Link,l2::Link)=(l1.name==l2.name)&(l1.presence==l2.presence)&(l1.from==l2.from)&(l1.to==l2.to)&(l1.weight==l2.weight)

links(s::AbstractStream)=[l for (k,v) in s.E for (kk,l) in v]
links(s::AbstractStream,t::Float64)=[l for (k,v) in s.E for (kk,l) in v if t ∈ l]
links(s::AbstractDirectedStream,from::AbstractString,to::AbstractString)=s.E[from][to]
links(s::AbstractUndirectedStream,from::AbstractString,to::AbstractString)=from<to ? s.E[from][to] : s.E[to][from]
links_from(s::AbstractDirectedStream,node::AbstractString)=haskey(s.E,node) ? s.E[node] : []
links_to(s::AbstractDirectedStream,node::AbstractString)=[l for l in to[node] for (from,to) in s.E if haskey(to,node)]

function links(s::AbstractUndirectedStream,node::AbstractString)
    result = Link[]
    for (from,access) in s.E
        if from==node
            for (to,l) in access
                push!(result,l)
            end
        else
            for (to,l) in access
                if to==node
                    push!(result,l)
                end
            end
        end
    end
    result
end

function links(s::AbstractStream,t0::Float64,t1::Float64)
    if t0>t1
        return []
    end
    result=Link[]
    t0t1=Intervals([(t0,t1)])
    for (k,v) in s.E
        for (kk,l) in v
            inter=t0t1 ∩ l.presence
            if length(inter)>0
                push!(result,Link(l.name,inter,l.from,l.to,l.weight))
            end
        end
    end
    result
end

function links(s::AbstractStream,node::AbstractString,t0::Float64,t1::Float64)
    if t0 > t1
        return []
    end
    result=Link[]
    t0t1=Intervals([(t0,t1)])
    for (k,v) in s.E
        for (kk,l) in v
            if l.from==node | l.to==node
                inter=t0t1 ∩ l
                if length(inter)>0
                    push!(result,Link(l.name,inter,l.from,l.to,l.weight))
                end
            end
        end
    end
    result
end

links(tc::TimeCursor)=tc.S.links

function links(tc::TimeCursor,t0::Float64,t1::Float64)
    L=Set{Tuple{AbstractString,AbstractString}}()
    goto!(tc,t0)
    haskey(tc.T,t0) && previous!(tc)
    L=L ∪ links(tc)
    while tc.S.t1 < t1
        next!(tc)
        L=L ∪ links(tc)
    end
    if haskey(tc.T,t1)
        next!(tc)
        L=L ∪ links(tc)
    end
    L
end

function links(tc::TimeCursor,t::Float64)
    goto!(tc,t)
    if haskey(tc.T,t)
        s1=links(tc)
        previous!(tc)
        return s1 ∪ links(tc)
    else
        return links(tc)
    end
end

links(s::AbstractStream,tc::TimeCursor,t::Float64)=links(tc,t)

function links(s::AbstractStream,tc::TimeCursor,t0::Float64,t1::Float64)
    if t0>t1
        return []
    end
    result=Link[]
    t0t1=Intervals([(t0,t1)])
    l=links(tc,t0,t1)
    for ll in l
        if haskey(s.E,ll[1]) && haskey(s.E[ll[1]],ll[2])
            temp=s.E[ll[1]][ll[2]]
        elseif haskey(s.E,ll[2]) && haskey(s.E[ll[2]],ll[1])
            temp=s.E[ll[2]][ll[1]]
        else
            throw("Unknown link $ll")
        end
        inter=t0t1 ∩ temp.presence
        if length(inter)>0
            push!(result,Link(temp.name,inter,temp.from,temp.to,temp.weight))
        end
    end
    result
end
