
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

export Intervals, Node, SNode
export ==
export ≈
export ∈
export ∪
export ∩
export ⊆
export count
export length
export merge
export push
export clean

#######################################
# Includes

include("base.jl")

end
