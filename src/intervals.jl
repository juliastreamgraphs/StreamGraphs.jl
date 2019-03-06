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

