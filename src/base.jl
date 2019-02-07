abstract type StreamObject end
abstract type Node <: StreamObject end
abstract type Stream end

# ----------- TUPLES -------------
#
# Equality between tuples of float64 is defined at 10^-6 rouding error
≈(a::Tuple{Float64,Float64},b::Tuple{Float64,Float64};atol::Real=10^-6)=≈(a[1],b[1],atol=atol)&&≈(a[2],b[2],atol=atol)
function ≈(a::Array{Tuple{Float64,Float64}},b::Array{Tuple{Float64,Float64}};atol::Real=10^-6)
    if length(a) != length(b)
        return false
    end
    return all([x[1]≈x[2] for x in zip(a,b)])
end

# ----------- INTERVALS -------------
#
"""
Structure implementing lists of intervals.
These structures are extremely useful when working with stream graphs.
"""
mutable struct Intervals
    list::Array{Tuple{Float64,Float64},1}
end

"""
Equality between two lists of intervals
NOTE: Use approx here because of rounding errors in intervals.
"""
==(i1::Intervals,i2::Intervals)=i1.list≈i2.list

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
    l = []
    n = 1
    components = vcat(i1.list,i2.list)
    sort!(components)
    push!(l, components[1])
    popfirst!(components)
    for c in components
        modif = false
        if length(l) == 0
            push!(l,c)
            continue
        end
        if c[2] <= l[end][2]
            l[end] = (l[end][1],c[2])
            modif = true
        end
        if c[1] <= l[end][2]
            l[end] = (c[1], l[end][2])
            modif = true
        end   
        if !modif
            pop!(l)
        end
        if n != length(components)
            push!(l,c)
        end
        n = n + 1
    end
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

# ----------- STATIC NODE DEFINITIONS -------------
#
"""SNode implements static nodes which have no dynamic."""
mutable struct SNode <: Node
    name::AbstractString
end

"""Two static nodes are equal if their names are the same."""
==(a::SNode,b::SNode)=a.name==b.name

# ----------- DYNAMIC NODE DEFINITIONS -------------
#
"""DNode implements dynamic nodes."""
mutable struct DNode <: Node
    name::AbstractString
    presence::Intervals
end

"""Two dynamic nodes are equal if their names and presence are the same."""
==(a::DNode,b::DNode)=(a.name==b.name)&(a.presence==b.presence)

"""A dynamic node is included in another if its presence is included in the other node's presence."""
⊆(a::StreamObject,b::StreamObject)=a.presence ⊆ b.presence
⊆(i::Intervals,o::StreamObject)=i ⊆ o.presence
⊆(i::Tuple{Float64,Float64},o::StreamObject)=i ⊆ o.presence
∈(t::Float64,n::StreamObject)=t ∈ n.presence
∩(a::StreamObject,b::StreamObject)=a.presence ∩ b.presence
∪(a::StreamObject,b::StreamObject)=a.presence ∪ b.presence

# ----------- LINK DEFINITIONS -------------
#
mutable struct Link <: StreamObject
    name::AbstractString
    presence::Intervals
    from::Node
    to::Node
    weight::Float64
end

==(l1::Link,l2::Link)=(l1.name==l2.name)&(l1.presence==l2.presence)&(l1.from==l2.from)&(l1.to==l2.to)&(l1.weight==l2.weight)
from_match(l1::Link,l2::Link)=(l1.from==l2.from)
to_match(l1::Link,l2::Link)=(l1.to==l2.to)
