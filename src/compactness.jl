"""
	compactness(ls)

Return the compactness of the given link stream, which is always 1.
"""
function compactness(ls::Union{LinkStream,DirectedLinkStream})
	return 1.0
end

"""
	compactness(s)

Return the compactness of the given stream graph.
"""
function compactness(s::Union{StreamGraph,DirectedStreamGraph})
    throw("Not Yet Implemented...")
end
