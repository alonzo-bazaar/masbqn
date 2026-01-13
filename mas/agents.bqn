⟨⟨white, black, red, blue⟩⇐color⟩←r←•Import "../rayed.bqn"

# settings for the simulation
config ← {
    # init settings
    numAgents ⇐ 10
    
    # simulation settings
    ## collective of neightbours for the average
    neighWeight ⇐ 0.01
    ## min dist between two agents to count as neighbours
    minDist ⇐ 0.4
    
    # display settings
    drawRadius ⇐ 5
}

# init logic functions

# returns a 𝕩‿2 shaped array, so 𝕩 (x,y) pairs
# with x and y uniformly distributed between 0 and 1
RandomPairs ← {𝕊𝕩: 1000÷˜𝕩‿2 ⥊ (2×𝕩) •rand.Range 1000}


# update logic functions
Norm  ← √∘(+´)∘(×˜¨)
Dist  ← Norm∘-

# takes element, minimum distance, and an array
# returns array of neighbours of element in array
# where neighbours are defined as whatever's below the minimum distance
Neigh ← {e‿md𝕊arr: {md⊸>˘ (e⊸Dist)˘ 𝕩}⊸/ arr}

# splits arr into elements equal to arr and elements not equal to arr
SplitEq ← { elt𝕊arr: (elt)⋈(elt⊸≢˘⊸/arr)}

# takes agent and agent vector
# returns new position of the agent as a weighted average of
# - its current position
# - the position of its neighbours (agents closer than config.minDist)
UpdateAgent ← { agent𝕊agents:
    nw‿md ← ⟨config.neighWeight, config.minDist⟩
    self‿n ← agent SplitEq (agent‿md Neigh agents)
    
	# if neighbour list is empty then just return original position
	self 0⊸=∘(≠∘⊢)◶{(𝕨×1-nw) + (nw×(+˝÷≠)𝕩)}‿⊣ n
}

# takes array of agents
# returns array of agents that have all been updated according to UpdateAgents
UpdateAgents ← {𝕊agents:
    (UpdateAgent⟜agents)˘agents
}

# return array 4‿? shaped array with x1‿y1‿x2‿y2 cells
# where x1 y1, and x2 y2 are the coordinates of two neighbouring agents
# for all pairs of neighbouring agents in the array
# (output meant to be used to draw lines)
NeighbourPairs ← {
    𝕊agents:
	md ← config.minDist

	# to avoid detecting both a->b and b->a as neighbour pairs
	# we only compare agents with agents that come after
	# to do this we act on suffices of the agents array

	nes ← ¯1⊸↓ ↓ agents # nonempty suffices of the agents vector
	na ← (⊏ {𝕨‿(𝕨‿md Neigh 𝕩)} 1⊸↓)¨ nes  # (agent‿neighbours) "alist", or adjacency list
	∾´ {𝕊a‿b: a⊸∾˘ b}¨ na

	# {𝕊a‿b: a⊸∾˘ b} takes an alist element and turns it into
	# an array of coords to draw links from that agent to its neighbours
	# do that for all agents then ∾´ em up
}

# display functions

# we will simulate agents in a unit square for later convenience
# raylib takes integer coordinates in numbers of pixels

# normalize simulation coordinates (in unit square) to window coordinates
# takes an input in normalized coordinates and turns it into window coordinates
# 
# given that simulation area is currently square,
# and that we want to keep the aspect ratio
# we only scale only by the smaller of the two window dimension
DispCoord ← {
    𝕊coords:
    min ← ⌊´ r.window.GetSize@
    ⌊ min⊸× coords
}

# we display the simulation in a square regardless of window aspect ratio
# so it's best to mark out the are we're gonna display in
DrawArena ← {
		  𝕊@:
          min ← ⌊´ r.window.GetSize@
		  64‿64‿64‿255 r.draw.Rectangle [0‿0, min‿min]
}

agents ← {
     RandomPairs config.numAgents
}

# display logic
PerFrame ← {
    dr ← config.drawRadius
    DrawArena@
    {white r.draw.Circle ⟨(⌊¨𝕩)⋄dr⟩}˘DispCoord agents
    
    # segnati il baricentro per vedere come evolve
    # e/o vedere se ci convergono 
    baricenter ← (+˝÷≠) agents
    red r.draw.Circle ⟨DispCoord baricenter ⋄ dr⟩
    
    # disegna connessioni tra vari agenti
	segments ← NeighbourPairs agents
	{𝕊x1‿y1‿x2‿y2: blue r.draw.Line [x1‿y1 ⋄ x2‿y2]}˘ DispCoord segments
    
    agents UpdateAgents↩
    
    100|𝕩+1
}r.draw._withCanvas⟜black

PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Automata"
