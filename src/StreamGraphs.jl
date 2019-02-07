
"""
Module for studying stream graphs and link streams.
"""

module StreamGraphs

#######################################
# Imports

import Base.≈
import Base.==
import Base.∈
import Base.∪
import Base.∩
import Base.⊆
import Base: length

########################################
# Exports

export Intervals, Node, SNode, DNode, Link, StreamObject, Stream, LinkStream, StreamGraph
export count, length, merge, push, clean, from_match, to_match
export ==, ≈, ∈, ∪, ∩, ⊆


#######################################
# Includes

include("base.jl")

end
