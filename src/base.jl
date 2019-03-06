abstract type StreamObject end
abstract type AbstractStream end
abstract type AbstractDirectedStream <: AbstractStream end
abstract type AbstractUndirectedStream <: AbstractStream end
abstract type AbstractPath end

# ----------- SETS -------------
#
function -(S1::Set{T},S2::Set{T}) where T
    setdiff(S1,S2)
end

function ×(S1::Set{T},S2::Set{T}) where T
    S=Set()
    for s1 in S1
        for s2 in S2
            push!(S,(s1,s2))
        end
    end
    S
end

function ⊗(S1::Set{T},S2::Set{T}) where T
    S=Set()
    for s1 in S1
        for s2 in S2
            if s1<s2
                push!(S,(s1,s2))
            elseif s2<s1
                push!(S,(s2,s1))
            end
        end
    end
    S
end

# ----------- TUPLES -------------
#
# Equality between tuples of float64 is defined at 10^-6 rouding error
≈(a::Tuple{Float64,Float64},b::Tuple{Float64,Float64};atol::Real=10^-6)=≈(a[1],b[1],atol=atol)&&≈(a[2],b[2],atol=atol)
≈(a::Array{Tuple{Float64,Float64}},b::Array{Tuple{Float64,Float64}};atol::Real=10^-6)=length(a)==length(b) ? all([x[1]≈x[2] for x in zip(a,b)]) : false

# ----------- INTERVALS -------------
#
"""
Structure implementing lists of intervals.
These structures are extremely useful when working with stream graphs.
"""
mutable struct Intervals
    list::Array{Tuple{Float64,Float64},1}
end

Intervals()=Intervals([])
    
"""
Equality between two lists of intervals
NOTE: Use approx here because of rounding errors in intervals.
"""
==(i1::Intervals,i2::Intervals)=clean(i1).list≈clean(i2).list

"""
In operator.
Returns true if the given element is inside one of the intervals of the list.
"""
function ∈(x::Float64, i::Intervals)
    for ii in i.list
        if ii[1] <= x <= ii[2]
            return true
        end
    end
    return false
end

"""Returns the number of intervals in the list."""
count(i::Intervals) = length(i.list)

"""Compute the length of a list of intervals as the sum of the interval lengths."""
length(i::Intervals)=sum([ii[2]-ii[1] for ii in i.list])

"""Merge a new interval within a list of intervals."""
merge(i::Intervals, x::Tuple{Float64,Float64})=union(i, Intervals([x]))

"""
Push a new interval at the end of the list.
WARNING: No sorting is done here...
"""
function push(i::Intervals, x::Tuple{Float64,Float64})
    push!(i.list, x)
    return i
end

"""Intersection between two list of intervals."""
function ∩(i1::Intervals, i2::Intervals)
    i1=clean(i1)
    i2=clean(i2)
    l = []
    components = vcat(i1.list,i2.list)
    if length(components)==0
        return Intervals()
    end
    sort!(components)
    push!(l, popfirst!(components))
    while length(components)>0
        modif = false
        c = popfirst!(components)
        if length(l) == 0
            push!(l,c)
            continue
        end
        if c[2] < l[end][2]
            push!(components,(c[2],l[end][2]))
            l[end] = (l[end][1],c[2])
            modif = true
        end
        if l[end][2] >= c[1] >= l[end][1]
            l[end] = (c[1], l[end][2])
            modif = true
        end   
        if !modif
            pop!(l)
        else
            sort!(components)
        end
        push!(l,c)
    end
    pop!(l)
    return clean(Intervals(l))
end

"""Union between two lists of intervals."""
function ∪(i1::Intervals, i2::Intervals)
    l = []
    components = union(i1.list,i2.list)
    sort!(components)
    for c in components
        if length(l) == 0 || c[1] > l[end][2]
            push!(l,c)
        elseif c[2] > l[end][2]
            l[end] = (l[end][1], c[2])
        end
    end
    return clean(Intervals(l))
end

function clean(i::Intervals)
    l = []
    sort!(i.list)
    for c in i.list
        if length(l) == 0
            push!(l,c)
            continue
        end
        if c[1] == l[end][2]
            l[end] = (l[end][1],c[2])
            continue
        end
        push!(l,c)
    end
    return Intervals(l)
end
            
"""Is subset returns True if i2 is included within i1."""
⊆(i1::Intervals,i2::Intervals)=(i1 ∩ i2)==clean(i1)
⊆(i1::Tuple{Float64,Float64},i2::Intervals)=Intervals([i1]) ⊆ i2

# ----------- NODE DEFINITIONS -------------
#
mutable struct Node <: StreamObject
    name::AbstractString
    presence::Intervals
end

==(a::Node,b::Node)=(a.name==b.name)&(a.presence==b.presence)

# ----------- LINK DEFINITIONS -------------
#
mutable struct Link <: StreamObject
    name::AbstractString
    presence::Intervals
    from::AbstractString
    to::AbstractString
    weight::Float64
end

==(l1::Link,l2::Link)=(l1.name==l2.name)&(l1.presence==l2.presence)&(l1.from==l2.from)&(l1.to==l2.to)&(l1.weight==l2.weight)

# --- Operations on StreamObjects ---
⊆(i::Intervals,o::StreamObject)=i ⊆ o.presence
⊆(i::Tuple{Float64,Float64},o::StreamObject)=i ⊆ o.presence
⊆(a::StreamObject,b::StreamObject)=a.presence ⊆ b.presence
∈(t::Float64,o::StreamObject)=t ∈ o.presence
∩(a::StreamObject,b::StreamObject)=a.presence ∩ b.presence
∪(a::StreamObject,b::StreamObject)=a.presence ∪ b.presence

duration(o::StreamObject)=length(o.presence)

# --- Operations on Nodes ---
function merge(n1::Node,n2::Node)
    if n1.name!=n2.name
        throw("Cannot merge nodes with different names...")
    end
    return Node(n1.name, n1 ∪ n2)
end

function merge!(n1::Node,n2::Node)
    if n1.name!=n2.name
        throw("Cannot merge nodes with different names...")
    end
    n1.presence = n1 ∪ n2
end

# --- Operations on Links ---
from_match(l1::Link,l2::Link)=(l1.from==l2.from)
from_match(name::AbstractString,l::Link)=(name==l.from)
to_match(l1::Link,l2::Link)=(l1.to==l2.to)
to_match(name::AbstractString,l::Link)=(name==l.to)
match(l1::Link,l2::Link)=from_match(l1,l2)&to_match(l1,l2)
match(from::AbstractString,to::AbstractString,l::Link)=from_match(from,l)&to_match(to,l)

function merge(l1::Link,l2::Link)
    if !match(l1,l2)
        throw("Cannot merge links with different end points...")
    end
    return Link(l1.name, l1 ∪ l2, l1.from, l1.to, l1.weight)
end

function merge!(l1::Link,l2::Link)
    if !match(l1,l2)
        throw("Cannot merge links with different end points...")
    end
    l1.presence = l1 ∪ l2
end

# --- Operations on Vectors of Nodes ---
get_idx(n::Node,a::Vector{Node})=findall(i->i==n,a)
get_idx(name::AbstractString,a::Vector{Node})=findall(i->i.name==name,a)
get_idx(t::Float64,a::Vector{Node})=findall(i->t ∈ i,a)

function ∪(a::Vector{Node},b::Vector{Node})
    c = Vector(Node[])
    for aa in a
        idx = get_idx(aa.name,b)
        if length(idx)==0
            new = Node(aa.name, aa.presence)
        elseif length(idx)==1
            new = Node(aa.name, aa ∪ b[idx][1])
        else
            throw("More than one node named $aa.name in array.")
        end
        push!(c,new)
    end
    for bb in b
        idx = get_idx(bb,a)
        if length(idx)==0
            new = Node(bb.name, bb.presence)
            push!(c,new)
        elseif length(idx)!=1
            throw("More than one node named $aa.name in array.")
        end
    end
    return c
end

function ∩(a::Vector{Node},b::Vector{Node})
    c = Vector(Node[])
    for aa in a
        idx = get_idx(aa.name,b)
        if length(idx)==1
            new = Node(aa.name, aa ∩ b[idx][1])
            push!(c,new)
        elseif length(idx)!=0
            throw("More than one node named $aa.name in array.")
        end
    end
    return c
end

# --- Operations on Vectors of Links ---
from_match(l1::Link,l::Vector{Link})=findall(x->from_match(x,l1),l)
from_match(name::AbstractString,l::Vector{Link})=findall(x->from_match(name,x),l)
to_match(l1::Link,l::Vector{Link})=findall(x->to_match(x,l1),l)
to_match(name::AbstractString,l::Vector{Link})=findall(x->to_match(name,x),l)
match(l1::Link,l::Vector{Link})=findall(x->match(x,l1),l)
match(from::AbstractString,to::AbstractString,l::Vector{Link})=findall(x->match(from,to,x),l)

get_idx(l::Link,a::Vector{Link})=findall(i->i==l,a)
get_idx(name::AbstractString,a::Vector{Link})=findall(i->i.name==name,a)
get_idx(t::Float64,a::Vector{Link})=findall(i->t ∈ i,a)

function ∪(a::Vector{Link},b::Vector{Link})
    c = Vector(Link[])
    for aa in a
        idx = match(aa,b)
        if length(idx)==0
            new = Link(aa.name, aa.presence, aa.from, aa.to, aa.weight)
        elseif length(idx)==1
            new = Link(aa.name, aa ∪ b[idx][1], aa.from, aa.to, aa.weight)
        else
            throw("More than one link matching from $aa.from and to $aa.to in array.")
        end
        push!(c,new)
    end
    for bb in b
        idx = match(bb,a)
        if length(idx)==0
            new = Link(bb.name, bb.presence, bb.from, bb.to, bb.weight)
            push!(c,new)
        elseif length(idx)!=1
            throw("More than one link matching from $aa.from and to $aa.to in array.")
        end
    end
    return c
end

function ∩(a::Vector{Link},b::Vector{Link})
    c = Vector(Link[])
    for aa in a
        idx = match(aa,b)
        if length(idx)==1
            new = Link(aa.name, aa ∩ b[idx][1], aa.from, aa.to, aa.weight)
            push!(c,new)
        elseif length(idx)!=0
            throw("More than one link matching from $aa.from and to $aa.to in array.")
        end
    end
    return c
end

# ----------- STREAM DEFINITIONS -------------
#
struct LinkStream <: AbstractUndirectedStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    E::Dict{AbstractString,Dict{AbstractString,Link}}
end

struct DirectedLinkStream <: AbstractDirectedStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    E::Dict{AbstractString,Dict{AbstractString,Link}}
end

#Base.getindex(ls::LinkStream, name::AbstractString)=haskey(ls.E,name) ? ls.E[name] : []
#Base.getindex(ls::LinkStream, t::Float64)=[l for (k,v) in ls.E for (kk,l) in v if t ∈ l]

struct StreamGraph <: AbstractUndirectedStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    W::Dict{AbstractString,Node}
    E::Dict{AbstractString,Dict{AbstractString,Link}}
end

struct DirectedStreamGraph <: AbstractDirectedStream
    name::AbstractString
    T::Intervals
    V::Set{AbstractString}
    W::Dict{AbstractString,Node}
    E::Dict{AbstractString,Dict{AbstractString,Link}}
end

LinkStream(name::AbstractString) = LinkStream(name, Intervals([]), Set(), Dict())
LinkStream(name::AbstractString,T::Intervals) = LinkStream(name, T, Set(), Dict())

DirectedLinkStream(name::AbstractString) = DirectedLinkStream(name, Intervals([]), Set(), Dict())
DirectedLinkStream(name::AbstractString,T::Intervals) = DirectedLinkStream(name, T, Set(), Dict())

StreamGraph(name::AbstractString) = StreamGraph(name, Intervals([]), Set(), Dict(), Dict())
StreamGraph(name::AbstractString,T::Intervals) = StreamGraph(name, T, Set(), Dict(), Dict())

### NODES ###
nodes(ls::Union{LinkStream,DirectedLinkStream})=ls.V
nodes(ls::Union{LinkStream,DirectedLinkStream},t::Float64)=ls.V
nodes(ls::Union{LinkStream,DirectedLinkStream},t0::Float64,t1::Float64)=ls.V
nodes(s::Union{StreamGraph,DirectedStreamGraph},t::Float64)=[n for (n,interv) in s.W if t ∈ interv]
nodes(s::Union{StreamGraph,DirectedStreamGraph})=[b for (a,b) in s.W]
nodes(s::Union{StreamGraph,DirectedStreamGraph},t0::Float64,t1::Float64)=t0<=t1 ? [n for (n,interv) in s.W if Intervals([(t0,t1)]) ⊆ interv] : []

### LINKS ###
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

### TIMES ###
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

function neighborhood(s::AbstractUndirectedStream, node::AbstractString)
    N=Dict{AbstractString,Intervals}()
    for l in links(s,node)
        if l.from==node
            if haskey(N,l.to)
                N[l.to]=N[l.to] ∪ (times(s,l.to) ∩ l.presence)
            else
                N[l.to]=times(s,l.to) ∩ l.presence
            end
        elseif l.to==node
            if haskey(N,l.from)
                N[l.from]=N[l.from] ∪ (times(s,l.from) ∩ l.presence)
            else
                N[l.from]=times(s,l.from) ∩ l.presence
            end
        end
    end
    Dict{AbstractString,Node}([k=>Node(k,v) for (k,v) in N])
end

function neighborhood(s::AbstractUndirectedStream, node::AbstractString, t::Float64)
    neighbors=AbstractString[]
    for l in links(s,node)
        if t ∈ l
            if l.from==node
                push!(neighbors,l.to)
            elseif l.to==node
                push!(neighbors,l.from)
            end
        end
    end
    neighbors
end   

#Base.getindex(s::StreamGraph, name::AbstractString)=ls.W[name]
#Base.getindex(s::AbstractDirectedStream, from::AbstractString, to::AbstractString)=s.E[from][to]
#Base.getindex(s::AbstractUndirectedStream, from::AbstractString, to::AbstractString)=(haskey(s.E,from)&haskey(s.E[from],to)) ? s.E[from][to] : s.E[to][from]

# ----------- OPERATIONS ON STREAMS -------------
#
∈(t::Float64,s::AbstractStream)=t ∈ s.T
∈(n::Node,s::StreamGraph)=haskey(s.W,n.name) & s.W[n.name] == n
∈(n::Node,s::DirectedStreamGraph)=haskey(s.W,n.name) & s.W[n.name] == n
∈(l::Link,s::AbstractStream)=haskey(s.E,l.from) & haskey(s.E[l.from],l.to) & s.E[l.from][l.to] == l
∈(n::AbstractString,ls::Union{LinkStream,DirectedLinkStream})=n ∈ ls.V
∈(n::AbstractString,s::Union{StreamGraph,DirectedStreamGraph})=(n ∈ s.V) & haskey(s.W,n)

⊆(t::Tuple{Float64,Float64},s::AbstractStream)=t ⊆ s.T
# TO UPDATE -----
⊆(ls1::LinkStream,ls2::LinkStream)=(ls1.T ⊆ ls2.T)&(ls1.V ⊆ ls2.V)&(ls1.E ⊆ ls2.E)
⊆(s1::StreamGraph,s2::StreamGraph)=(s1.T ⊆ s2.T)&(s1.V ⊆ s2.V)&(s1.W ⊆ s2.W)&(s1.E ⊆ s2.E)

∩(ls1::LinkStream,ls2::LinkStream)=LinkStream("$ls1.name n $ls2.name", ls1.T ∩ ls2.T, ls1.V ∩ ls2.V, ls1.E ∩ ls2.E)
∩(s1::StreamGraph,s2::StreamGraph)=StreamGraph("$s1.name n $s2.name", s1.T ∩ s2.T, s1.V ∩ s2.V, s1.W ∩ s2.W, s1.E ∩ s2.E)

∪(ls1::LinkStream,ls2::LinkStream)=LinkStream("$ls1.name u $ls2.name", ls1.T ∪ ls2.T, ls1.V ∪ ls2.V, ls1.E ∪ ls2.E)
∪(s1::StreamGraph,s2::StreamGraph)=StreamGraph("$s1.name u $s2.name", s1.T ∪ s2.T, s1.V ∪ s2.V, s1.W ∪ s2.W, s1.E ∪ s2.E)
# -----

# ----------- ADDING THINGS TO STREAMS -------------
#
function add_node!(ls::Union{LinkStream,DirectedLinkStream}, n::AbstractString)
    push!(ls.V,n)
end

function add_node!(s::Union{StreamGraph,DirectedStreamGraph}, n::Node)
    if n.name ∉ s
        push!(s.V,n.name)
        s.W[n.name] = n
    else
        merge!(s.W[n.name],n)
    end
end

function add_link!(ls::DirectedLinkStream, l::Link)
    if l.from ∉ ls
        add_node!(ls,l.from)
    end
    if l.to ∉ ls
        add_node!(ls,l.to)
    end
    if !haskey(ls.E,l.from)
        ls.E[l.from] = Dict()
    end
    if !haskey(ls.E[l.from],l.to)
        ls.E[l.from][l.to] = l
    else
        merge!(ls.E[l.from][l.to],l)
    end
end

function add_link!(ls::LinkStream, l::Link)
    if l.from ∉ ls
        add_node!(ls,l.from)
    end
    if l.to ∉ ls
        add_node!(ls,l.to)
    end
    if l.to < l.from
        l.from,l.to=l.to,l.from
    end
    if !haskey(ls.E,l.from)
        ls.E[l.from] = Dict()
    end
    if !haskey(ls.E[l.from],l.to)
        ls.E[l.from][l.to] = l
    else
        merge!(ls.E[l.from][l.to],l)
    end
end

function add_link!(s::DirectedStreamGraph, l::Link)
    if l.from ∉ s
        new_from = Node(l.from, l.presence)
        add_node!(s,new_from)
    elseif l.presence ⊈ s.W[l.from].presence
        new_from = Node(l.from, l.presence)
        merge!(s.W[l.from],new_from)
    end
    if l.to ∉ s
        new_to = Node(l.to, l.presence)
        add_node!(s,new_to)
    elseif l.presence ⊈ s.W[l.to].presence
        new_to = Node(l.to, l.presence)
        merge!(s.W[l.to],new_to)
    end
    if !haskey(s.E,l.from)
        s.E[l.from] = Dict()
    end
    if !haskey(s.E[l.from],l.to)
        s.E[l.from][l.to] = l
    else
        merge!(s.E[l.from][l.to],l)
    end
end

function add_link!(s::StreamGraph, l::Link)
    if l.from ∉ s
        new_from = Node(l.from, l.presence)
        add_node!(s,new_from)
    elseif l.presence ⊈ s.W[l.from].presence
        new_from = Node(l.from, l.presence)
        merge!(s.W[l.from],new_from)
    end
    if l.to ∉ s
        new_to = Node(l.to, l.presence)
        add_node!(s,new_to)
    elseif l.presence ⊈ s.W[l.to].presence
        new_to = Node(l.to, l.presence)
        merge!(s.W[l.to],new_to)
    end
    if l.to < l.from
        l.from,l.to=l.to,l.from
    end
    if !haskey(s.E,l.from)
        s.E[l.from] = Dict()
    end
    if !haskey(s.E[l.from],l.to)
        s.E[l.from][l.to] = l
    else
        merge!(s.E[l.from][l.to],l)
    end
end

function record!(s::AbstractStream, t0::Float64, t1::Float64, from::AbstractString, to::AbstractString)
    if (t0,t1) ⊈ s
        throw("Stream $(s.name) is defined over $(s.T). Invalid link between t0=$t0 and t1=$t1.")
    end
    new = Link("$from to $to", Intervals([(t0,t1)]), from, to, 1)
    add_link!(s,new)
end

function record!(s::Union{StreamGraph,DirectedStreamGraph}, t0::Float64, t1::Float64, n::AbstractString)
    if (t0,t1) ⊈ s
        throw("Stream $(s.name) is defined over $(s.T). Invalid link between t0=$t0 and t1=$t1.")
    end
    new = Node(n,Intervals([(t0,t1)]))
    add_node!(s,new)
end

# ----------- READ FROM FILES -------------
#
function parse_line_auv(line::AbstractString, Δ::Float64)
    line = strip(line)
    elts = split(line," ")
    length(elts) != 3 && throw("Format auv expects lines with three elements.")
    t,u,v = elts
    t = parse(Float64,t)
    t0 = t - Δ / 2
    t1 = t + Δ /2
    t0,t1,u,v
end

parse_line_auv(line::AbstractString)=parse_line_auv(line,1.0)

function parse_line_abuv(line::AbstractString)
    line = strip(line)
    elts = split(line," ")
    length(elts) != 4 && throw("Format abuv expects lines with four elements.")
    t0,t1,u,v = elts
    t0 = parse(Float64,t0)
    t1 = parse(Float64,t1)
    t0,t1,u,v
end

parse_line_abuv(line::AbstractString,Δ::Float64)=parse_line_abuv(line)

parsers=Dict("auv"=>parse_line_auv,
             "abuv"=>parse_line_abuv
)

function parse_line(line::AbstractString,format::AbstractString)
    haskey(parsers,format) ? parsers[format](line) : throw("Unknown format $format")
end

function parse_line(line::AbstractString,format::AbstractString,Δ::Float64)
    haskey(parsers,format) ? parsers[format](line,Δ) : throw("Unknown format $format")
end

function load!(s::AbstractStream, f::AbstractString, format::AbstractString)
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line,format)
            record!(s,t0,t1,u,v)
        end
    end
end

function load!(s::AbstractStream, f::AbstractString, format::AbstractString, Δ::Float64)
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line,format,Δ)
            record!(s,t0,t1,u,v)
        end
    end
end

abstract type Event end

struct NodeEvent <: Event
    t::Float64
    arrive::Bool
    object::AbstractString
end

struct LinkEvent <: Event
    t::Float64
    arrive::Bool
    object::Tuple{AbstractString,AbstractString}
end

==(e1::Event,e2::Event)=(e1.t==e2.t)&(e1.arrive==e2.arrive)&(e1.object==e2.object)

function string(e::Event)
    if typeof(e)==LinkEvent
        e.arrive ? "$(e.t) + $(e.object[1]) $(e.object[2])" : "$(e.t) - $(e.object[1]) $(e.object[2])"
    elseif typeof(e)==NodeEvent
        e.arrive ? "$(e.t) + $(e.object)" : "$(e.t) - $(e.object)"
    else
        throw("Unknown type for event object.")
    end
end

function parse_to_events(f::AbstractString,format::AbstractString,Δ::Float64)
    format ∉ ["auv","abuv"] && throw("Only auv and abuv formats can be parsed to events.")
    D=Dict{Tuple{AbstractString,AbstractString},Array{Float64,1}}()
    events=Event[]
    open(f) do file
        for line in eachline(file)
            t0,t1,u,v = parse_line(line,format,Δ)
            if haskey(D,(u,v))
                if t0 > D[(u,v)][2]
                    push!(events,LinkEvent(D[(u,v)][1],true,(u,v)))
                    push!(events,LinkEvent(D[(u,v)][2],false,(u,v)))
                    D[(u,v)]=[t0,t1]
                else
                    D[(u,v)][2]=t1
                end
            else
                D[(u,v)]=[t0,t1]
            end
        end
    end
    for (obj,interv) in D
        push!(events,LinkEvent(interv[1],true,obj))
        push!(events,LinkEvent(interv[2],false,obj))
    end
    sort!(events, by = v -> v.t)
end

function dump(f::AbstractString,events::Vector{Event})
    open(f,"w") do file
        for event in events
            write(file,"$(string(event))\n")
        end
    end
end

# ----------- METRICS OF STREAMS -------------
#
duration(s::AbstractStream)=length(s.T)
duration(W::Dict{AbstractString,Node})=sum([duration(v) for (k,v) in W])

### NODE DURATION ###
node_duration(ls::Union{LinkStream,DirectedLinkStream})=duration(ls)
node_duration(s::Union{StreamGraph,DirectedStreamGraph})=length(s.V)>0 ? sum([duration(n) for (k,n) in s.W])/length(s.V) : 0

### LINK DURATION ###
link_duration(s::AbstractStream)=length(s.V)>1 ? 2*sum([duration(l) for (k,v) in s.E for (kk,l) in v])/(length(s.V)*(length(s.V)-1)) : 0

### CONTRIBUTION ###
contribution(s::AbstractStream, o::StreamObject)=duration(s)!=0 ? duration(o) / duration(s) : 0.0
contribution(ls::Union{LinkStream,DirectedLinkStream},node_name::AbstractString)=1.0
contribution(ls::Union{LinkStream,DirectedLinkStream},node_name::AbstractString,t::Float64)=1.0
contribution(s::Union{StreamGraph,DirectedStreamGraph},node_name::AbstractString)=contribution(s,s.W[node_name])
contribution(s::AbstractDirectedStream, from::AbstractString, to::AbstractString)=haskey(s.E,from)&haskey(s.E[from],to) ? contribution(s,s.E[from][to]) : 0
contribution(s::AbstractUndirectedStream, from::AbstractString, to::AbstractString)=from<=to ? contribution(s,s.E[from][to]) : contribution(s,s.E[to][from])

node_contribution(s::AbstractStream,t::Float64)=length(nodes(s,t))/length(s.V)
link_contribution(s::AbstractStream,t::Float64)=length(links(s,t))/length(s.V ⊗ s.V)

### NUMBER OF NODES ###
number_of_nodes(s::Union{StreamGraph,DirectedStreamGraph})=length(s.W) != 0 ? sum([contribution(s,n) for (k,n) in s.W]) : 0.0
number_of_nodes(ls::Union{LinkStream,DirectedLinkStream})=length(ls.V)

### NUMBER OF LINKS ###
number_of_links(s::AbstractStream)=length(s.E) != 0 ? sum([contribution(s,l) for (k,v) in s.E for (kk,l) in v]) : 0.0

### DENSITY ###
function density(ls::Union{LinkStream,DirectedLinkStream})
    if (length(ls.V)==0) | (length(ls.E)==0)
        return 0.0
    end
    nom=2 * sum([duration(l) for (k,v) in ls.E for (kk,l) in v])
    denom=(length(ls.V)*(length(ls.V)-1)*duration(ls))
    denom != 0 ? nom/denom : 0.0
end

function density(s::Union{StreamGraph,DirectedStreamGraph})
    if (length(s.V)==0) | (length(s.E)==0)
        return 0.0
    end
    denom = sum([length(times(s,u) ∩ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom != 0 ? sum([duration(l) for (k,v) in s.E for (kk,l) in v]) / denom : 0
end

density(ls::Union{LinkStream,DirectedLinkStream}, t::Float64)=length(ls.V)>1 ? 2 * sum([duration(l) for l in links(ls,t)])/(length(ls.V)*(length(ls.V)-1)) : 0

function density(s::Union{StreamGraph,DirectedStreamGraph}, t::Float64)
    Vt=Set{AbstractString}(nodes(s,t))
    length(Vt)!=0 ? length(links(s,t))/length(Vt ⊗ Vt) : 0.0
end

density(ls::Union{LinkStream,DirectedLinkStream},n1::AbstractString,n2::AbstractString)=duration(ls)!=0 ? duration(links(ls,n1,n2))/duration(ls) : 0

function density(s::Union{StreamGraph,DirectedStreamGraph},n1::AbstractString,n2::AbstractString)
    denom=length(times(s,n1) ∩ times(s,n2))
    denom != 0 ? length(times(s,n1,n2))/denom : 0.0
end

function density(s::AbstractStream,n::AbstractString)
    nom=sum([length(times(s,u,n)) for u in s.V if u != n])
    denom=sum([length(times(s,u) ∩ times(s,n)) for u in s.V if u != n])
    denom != 0 ? nom/denom : 0.0
end

### COVERAGE ###
coverage(ls::Union{LinkStream,DirectedLinkStream})=1.0
coverage(s::Union{StreamGraph,DirectedStreamGraph})=((length(s.V)!=0) & (duration(s)!=0)) ? sum([duration(n) for (k,n) in s.W])/(duration(s)*length(s.V)) : 0.0

### COMPACTNESS ###
compactness(ls::Union{LinkStream,DirectedLinkStream})=1.0
function compactness(s::Union{StreamGraph,DirectedStreamGraph})
    throw("Not Yet Implemented...")
end

### UNIFORMITY ###
uniformity(ls::Union{LinkStream,DirectedLinkStream})=1.0
function uniformity(s::Union{StreamGraph,DirectedStreamGraph})
    if length(s.V)==0
        return 0.0
    end
    nom=sum([length(times(s,u) ∩ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom=sum([length(times(s,u) ∪ times(s,v)) for (u,v) in s.V ⊗ s.V])
    denom != 0 ? nom/denom : 0.0
end

### CLUSTERING ###
function node_clustering(s::AbstractUndirectedStream, v::AbstractString)
    nomin=0
    denom=0
    N=Set(AbstractString[])
    for n in keys(neighborhood(s,v))
        push!(N,n)
    end
    for (u,w) in N ⊗ N
        nomin+=length((times(s,v,u) ∩ times(s,v,w)) ∩ times(s,u,w))
        denom+=length(times(s,v,u) ∩ times(s,v,w))
    end
    denom != 0 ? nomin/denom : 0.0
end

function node_clustering(s::AbstractUndirectedStream,v::AbstractString,t::Float64)
    Nt=Set(AbstractString[])
    for n in neighborhood(s,v,t)
        push!(Nt,n)
    end
    nom=sum([1.0 for (u,w) in Nt ⊗ Nt if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)) & (t ∈ times(s,u,w)))])
    denom=sum([1.0 for (u,w) in Nt ⊗ Nt if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)))])
    denom != 0 ? nom/denom : 0.0
end

node_clustering(s::AbstractUndirectedStream)=length(s.V)>0 ? 1.0/length(s.V)*sum([contribution(s,v)*node_clustering(s,v) for v in s.V]) : 0.0

function time_clustering(s::AbstractUndirectedStream,t::Float64)
    nom::Float64=0.0
    denom::Float64=0.0
    for v in s.V
        acc::Float64=0.0
        for (u,w) in s.V ⊗ s.V
            if ((t ∈ times(s,v,u)) & (t ∈ times(s,v,w)))
                acc+=1.0
            end
        end
        nom+=node_clustering(s,v,t) * acc
        denom+=acc
    end
    denom != 0 ? nom/denom : 0.0
end

function time_clustering(s::AbstractUndirectedStream)
    τ = times(s)
    dW = duration(s.W)
    dW != 0 ? 1.0/dW*sum([time_clustering(s,0.5*(t[2]+t[1])) * length(nodes(s,0.5*(t[2]+t[1]))) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

function clustering(s::AbstractUndirectedStream)
    card_TV = duration(s)*length(s.V)
    if card_TV==0
        return 0.0
    end
    τ = times(s)
    acc::Float64 = 0.0
    for v in s.V
        for t in zip(τ[1:end-1],τ[2:end])
            acc+=node_clustering(s,v,0.5*(t[1]+t[2]))*(t[2]-t[1])
        end
    end
    1.0/card_TV*acc
end

### DEGREE ###
degree(s::AbstractUndirectedStream,node::AbstractString)=duration(s)!=0 ? duration(neighborhood(s,node))/duration(s) : 0.0
degree(s::AbstractUndirectedStream,node::AbstractString,t::Float64)=length(neighborhood(s,node,t))
degree(s::AbstractUndirectedStream,t::Float64)=length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v,t) for v in s.V]) : 0.0
degree(s::AbstractUndirectedStream)=length(s.V) != 0 ? 1.0/length(s.V)*sum([degree(s,v) for v in s.V]) : 0.0

average_node_degree(ls::LinkStream)=number_of_nodes(ls)!=0 ? 2.0*number_of_links(ls)/number_of_nodes(ls) : 0.0
average_node_degree(s::StreamGraph)=duration(s.W)!=0 ? 1.0/duration(s.W)*sum([length(times(s,v))*degree(s,v) for v in s.V]) : 0.0

function average_time_degree(s::AbstractStream)
    k = node_duration(s)
    τ = times(s)
    k != 0 ? 1.0/k*sum([node_contribution(s,0.5*(t[2]+t[1]))*degree(s,0.5*(t[2]+t[1]))*(t[2]-t[1]) for t in zip(τ[1:end-1],τ[2:end])]) : 0.0
end

# ----------- STATE -------------
#
mutable struct State
    t0::Float64
    t1::Float64
    nodes::Set{AbstractString}
    links::Set{Tuple{AbstractString,AbstractString}}
end

duration(s::State)=s.t1-s.t0
number_of_nodes(s::State)=length(s.nodes)
number_of_links(s::State)=length(s.links)

# ----------- TRANSITION -------------
#
mutable struct Transition
    tprev::Float64
    t::Float64
    tnxt::Float64
    node_arrivals::Set{AbstractString}
    node_departures::Set{AbstractString}
    link_arrivals::Set{Tuple{AbstractString,AbstractString}}
    link_departures::Set{Tuple{AbstractString,AbstractString}}
end

Δnodes(t::Transition)=length(t.node_arrivals)-length(t.node_departures)
Δlinks(t::Transition)=length(t.link_arrivals)-length(t.link_departures)

function apply!(s::State,τ::Transition)
    # Moving backward
    if s.t0 == τ.t
        s.t0=τ.tprev
        s.t1=τ.t
        length(τ.node_arrivals - s.nodes)>0 && throw("<Backward Move> Absent nodes cannot leave the state.")
        s.nodes=s.nodes - τ.node_arrivals
        length(s.nodes ∩ τ.node_departures)>0 && throw("<Backward Move> Nodes already present in state cannot arrive in Transition.")
        s.nodes=s.nodes ∪ τ.node_departures
        length(τ.link_arrivals - s.links)>0 && throw("<Backward Move> Absent links cannot leave the state.")
        s.links=s.links - τ.link_arrivals
        length(s.links ∩ τ.link_arrivals)>0 && throw("<Backward Move> Links already present in state cannot arrive in Transition.")
        s.links=s.links ∪ τ.link_departures
    # Moving forward
    elseif s.t1 == τ.t
        s.t0=τ.t
        s.t1=τ.tnxt
        length(τ.node_departures - s.nodes)>0 && throw("<Forward Move> Absent nodes cannot leave the state.")
        s.nodes=s.nodes - τ.node_departures
        length(s.nodes ∩ τ.node_arrivals)>0 && throw("<Forward Move> Nodes already present in state cannot arrive in Transition.")                
        s.nodes=s.nodes ∪ τ.node_arrivals
        length(τ.link_departures - s.links)>0 && throw("<Forward Move> Absent links cannot leave the state.")
        s.links=s.links - τ.link_departures
        length(s.links ∩ τ.link_arrivals)>0 && throw("<Forward Move> Links already present in state cannot arrive in Transition.")
        s.links=s.links ∪ τ.link_arrivals 
    else
        throw("Cannot apply transition to given state.")
    end
end

# ----------- TIME CURSOR -------------
#
mutable struct TimeCursor
    S::State
    T::Dict{Float64,Transition}
end

## Move the cursor in the Stream ##
next_transition(tc::TimeCursor)=haskey(tc.T,tc.S.t1) ? tc.T[tc.S.t1] : throw("No transition in TimeMap at t=$(tc.S.t1)")
previous_transition(tc::TimeCursor)=haskey(tc.T,tc.S.t0) ? tc.T[tc.S.t0] : throw("No transition in TimeMap at t=$(tc.S.t0)")
next!(tc::TimeCursor)=haskey(tc.T,tc.S.t1) && apply!(tc.S,next_transition(tc))
previous!(tc::TimeCursor)=haskey(tc.T,tc.S.t0) && apply!(tc.S,previous_transition(tc))

function goto!(tc::TimeCursor,t::Float64)
    while !(tc.S.t0 <= t < tc.S.t1)
        t >= tc.S.t1 ? next!(tc) : previous!(tc)
    end
end

function start!(tc::TimeCursor)
    while haskey(tc.T,tc.S.t0)
        previous!(tc)
    end
    next!(tc)
end

function end!(tc::TimeCursor)
    while haskey(tc.T,tc.S.t1)
        next!(tc)
    end
    previous!(tc)
end

## Node queries on the cursor ##
number_of_nodes(tc::TimeCursor)=number_of_nodes(tc.S)
nodes(tc::TimeCursor)=tc.S.nodes

function nodes(tc::TimeCursor,t::Float64)
    goto!(tc,t)
    if haskey(tc.T,t)
        s1=nodes(tc)
        previous!(tc)
        return s1 ∪ nodes(tc)
    else
        return nodes(tc)
    end
end

number_of_nodes(tc::TimeCursor,t::Float64)=length(nodes(tc,t))

function nodes(tc::TimeCursor,t0::Float64,t1::Float64)
    N=Set{AbstractString}()
    goto!(tc,t0)
    haskey(tc.T,t0) && previous!(tc)
    N=N ∪ nodes(tc)
    while tc.S.t1 < t1
        next!(tc)
        N=N ∪ nodes(tc)
    end
    if haskey(tc.T,t1)
        next!(tc)
        N=N ∪ nodes(tc)
    end
    N
end

number_of_nodes(tc::TimeCursor,t0::Float64,t1::Float64)=length(nodes(tc,t0,t1))

## Link queries on the cursor ##
number_of_links(tc::TimeCursor)=number_of_links(tc.S)
links(tc::TimeCursor)=tc.S.links

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

number_of_links(tc::TimeCursor,t::Float64)=length(links(tc,t))

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

number_of_links(tc::TimeCursor,t0::Float64,t1::Float64)=length(links(tc,t0,t1))

density(tc::TimeCursor)=number_of_nodes(tc) > 1 ? (2*number_of_links(tc))/(number_of_nodes(tc)*(number_of_nodes(tc)-1)) : 0.0

function density(tc::TimeCursor,t::Float64)
    n=number_of_nodes(tc,t)
    m=number_of_links(tc,t)
    n > 1 ? (2*m)/(n*(n-1)) : 0.0
end

function density(tc::TimeCursor,t0::Float64,t1::Float64)
    n=number_of_nodes(tc,t0,t1)
    m=number_of_links(tc,t0,t1)
    n > 1 ? (2*m)/(n*(n-1)) : 0.0
end

function load!(tc::TimeCursor,events::Vector{Event})
    tprev::Float64=events[1].t-0.1
    t::Float64=events[1].t
    tc.S=State(tprev,t,Set(),Set())
    idx::Int64=1
    node_arrivals=Set{AbstractString}()
    node_departures=Set{AbstractString}()
    link_arrivals=Set{Tuple{AbstractString,AbstractString}}()
    link_departures=Set{Tuple{AbstractString,AbstractString}}()
    transitions=Transition[]
    while idx <= length(events)
        while (idx <= length(events)) && (events[idx].t==t)
            if typeof(events[idx])==NodeEvent
                if events[idx].arrive
                    push!(node_arrivals,events[idx].object)
                else
                    push!(node_departures,events[idx].object)
                end
            else
                if events[idx].arrive
                    push!(link_arrivals,events[idx].object)
                else
                    push!(link_departures,events[idx].object)
                end
            end
            idx += 1
        end
        if length(transitions)>0
            transitions[end].tnxt=t
        end
        push!(transitions,Transition(tprev,t,-1,deepcopy(node_arrivals),
                                                deepcopy(node_departures),
                                                deepcopy(link_arrivals),
                                                deepcopy(link_departures)))
        empty!(node_arrivals)
        empty!(node_departures)
        empty!(link_arrivals)
        empty!(link_departures)
        tprev=t
        if idx<=length(events)
            t=events[idx].t
        end
    end
    transitions[end].tnxt=t
    for τ in transitions
        tc.T[τ.t]=τ
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

# ----------- JUMPS -------------
#
struct Jump
    t::Float64
    from::AbstractString
    to::AbstractString
end

struct DurationJump
    t::Float64
    from::AbstractString
    to::AbstractString
    δ::Float64
end

duration(j::DurationJump)=j.δ

# ----------- PATHS -------------
#
mutable struct Path <: AbstractPath
    jumps::Vector{Jump}
end

Path()=Path([])

mutable struct DurationPath <: AbstractPath
    jumps::Vector{DurationJump}
end

DurationPath()=DurationPath([])

start(p::AbstractPath)= length(p.jumps) > 0 ? p.jumps[1].t : 0
finish(p::Path)=length(p.jumps) > 0 ? p.jumps[end].t : 0
finish(p::DurationPath)=length(p.jumps) > 0 ? p.jumps[end].t + p.jumps[end].δ : 0
length(p::AbstractPath)=length(p.jumps)
duration(p::AbstractPath)=finish(p)-start(p)

function is_valid(p::Path)
    if length(p)<=1
        return true
    end
    for cpt in zip(p.jumps[1:end-1],p.jumps[2:end])
        if cpt[1].t > cpt[2].t || cpt[1].to != cpt[2].from
            return false
        end
    end
    return true
end

function is_valid(p::DurationPath)
    if length(p)<=1
        return true
    end
    for cpt in zip(p.jumps[1:end-1],p.jumps[2:end])
        if cpt[1].t + cpt[1].δ > cpt[2].t || cpt[1].to != cpt[2].from
            return false
        end
    end
    return true
end

function +(p1::T,p2::T) where T <: AbstractPath
    if !is_valid(T([p1.jumps[end],p2.jumps[1]]))
        throw("Cannot concat paths.")
    end
    p = deepcopy(p1)
    for jump in p2.jumps
        push!(p.jumps,jump)
    end
    return p
end

function push(p::AbstractPath,jump::Jump)
    p2 = deepcopy(p)
    push!(p2.jumps,jump)
    if is_valid(p2)
        return p2
    else
        throw("Cannot add jump $jump to path because this will break the path feature.")
    end
end

function ⊆(p1::T,p2::T) where T <: AbstractPath
    lp1 = length(p1)
    lp2 = length(p2)
    if lp1 > lp2
        return false
    end
    for i in range(1,lp2-lp1)
        if p2.jumps[i:i+lp1-1] == p1.jumps
            return true
        end
    end
    return false
end