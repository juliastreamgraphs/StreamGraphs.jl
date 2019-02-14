
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
import Base: length, match

########################################
# Exports

export 

		# Stream components
		Intervals, Node, Link, StreamObject, AbstractStream, 
		LinkStream, StreamGraph,

		# functions
		count, length, merge, push, clean, from_match, to_match, 
		match, get_idx,

		# Operators
		==, ≈, ∈, ∪, ∩, ⊆

#######################################
# Includes

include("base.jl")

end
