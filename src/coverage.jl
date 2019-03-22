"""
	coverage(ls)

Return the coverage of the given link stream.
By definition, the coverage of a link stream is 1.
"""
coverage(ls::Union{LinkStream,DirectedLinkStream})=1.0

"""
	coverage(s)

Return the coverage of the given stream graph:
```math
cov \\left( S \\right) = \\frac{\\left| W \\right|}{\\left| T \\times V \\right|}
```
Note: For stream graphs with no node and/or no duration, this
function returns 0.

### Reference
- Matthieu Latapy, Tiphaine Viard and Clémence Magnien Social 
  Networks Analysis and Mining, 8: 61, 2018. "Stream Graphs and 
  Link Streams for the Modeling of Interactions over Time".
  [(arXiv)](https://arxiv.org/pdf/1710.04073.pdf)
"""
function coverage(s::Union{StreamGraph,DirectedStreamGraph})
	if ((length(s.V)!=0) && (duration(s)!=0))
		sum([duration(n) for (k,n) in s.W])/(duration(s)*length(s.V))
	else
		0.0
	end
end

