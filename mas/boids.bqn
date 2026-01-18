# utilities
RandArr ← 1000⊸(⊣÷˜•rand.Range˜)

N2	←	(+´)∘(×˜˘)∘-	# norm squared
N	←	√N2				# norm
D2	←	N2-				# distance squared
D	←	N-				# distance

_debug ← {
	𝔽_𝕣𝕩 :
	•Out "𝕩 is: [" ∾ (•Repr 𝕩)∾"]"
	res ← 𝔽𝕩
	•Out "result is: [" ∾ (•Repr res)∾"]"
	res
	;
	𝕨𝔽_𝕣𝕩:
	•Out "𝕨 is: [" ∾ (•Repr 𝕨)∾"]"
	•Out "𝕩 is: [" ∾ (•Repr 𝕩)∾"]"
	res ← 𝕨𝔽𝕩
	•Out "result is: [" ∾ (•Repr res)∾"]"
	res
}

# boids
nboids ← 200 
boids ← { x_y ← RandArr 2‿nboids
	      dx_dy ← 10 ÷˜ 0.5-˜RandArr 2‿nboids
	      x_y ∾ dx_dy 
	  	}

# simulation functions and utils
# Neighbour Indices
# return array of arrays where every element neigh_i of the result
# is an array of indices of neighbours of x_i‿y_i where xi = i⊑x, yi = i⊑y

# TODO: for large boid arrays Dist2⌜˜ is probably a bad idea
# for if it does allocate an (≠⍉boids)‿(≠⍉boids) shaped array
# and is not fused away somehow... das a lot of memory

# NOTE: 0‿0⊸⍉ picks the diagonal
# I still have no idea how that works, but it does
Nis ← {d 𝕊 bs: # distance and boids
    xy←2↑bs
    dq ← d×d
    /¨ <˘ 0¨⌾(0‿0⊸⍉) dq > D2⌜˜ <˘ ⍉ xy 
}

# Neighbours
Ns ← {d 𝕊 bs: # distance and boids
    (⊏⌾⍉⟜bs)¨ d Nis bs
}

# Clamp velocity magnitudes
# while keeping direction and orientation
ClampVs ← { 𝕊vs:				    # velocities
    mags ← +˝ ×˜ vs					# magnitudes
	# replace zero magnitdes with dummy value
	# to avoid dividng by zero
	# the value will multiply a zero vector so it's irrelevant
	mags {1¨⌾((𝕩=0)⊸/) 𝕩}↩
	clamp ← 0.00001 ⌈ 0.001 ⌊ mags	# clamped magnitudes
	clamp⊸×˘ ÷⟜mags˘ vs
}

# Centers:
# takes a list of neighbour arrays and returns centers shaped
# like how our boid array is shaped (nboids‿4)
# where first major cell is the average x of neighbours
# (or 0 if no neighbours), then average y, dx, and dy
Cs ← {⍉>(+˝÷1⊸⌈∘≠)˘¨𝕩}

# Update (simulation tick)
Up ← {𝕊 bs:
    bns ← 0.35 Ns bs	# list of boid neighbour arrays
	hn ← 0≠1⊸⊑∘≢¨ bns   # does boid have neighbours
    dncs ← bs - Cs bns	# distance to neighbour centers

    nf ← hn⊸×˘ ¯0.003 × 2↑ dncs	# neighbouring force
    smf ← hn⊸×˘ ¯0.5 × 2↓ dncs	# speed matching force

    brs ← 0.05 Ns bs	# repelled boids
	nr ← 1⊸⊑∘≢¨ brs		# number of repelled

    rf ← nr⊸×˘ 0.03× 2↑ bs - Cs brs 	# repulsive force

    siwf ← 0.003 × (<⟜0.1->⟜0.9)˘ 2↑bs	# "stay in window" force

	nx_y ← 0.05⌈ 0.95⌊ (2⊸↑+2⊸↓)bs		# next pos
	ndx_dy ← ClampVs rf + nf + smf + siwf + 2↓bs  # next vel
	nx_y ∾ ndx_dy
} 

# hic est raylib
⟨⟨white,
  black,
  red,
  green,
  blue⟩ ⇐color⟩←r←•Import "../rayed-bqn/rayed.bqn"

DrawArena ← { 𝕊@:
          min ← ⌊´ r.window.GetSize@
		  64‿64‿64‿255 r.draw.Rectangle [0‿0, min‿min]
}

DispCoord ← {𝕊nc: # normalized coordinates (ie. ∊ (0, 1))
    min ← ⌊´ r.window.GetSize@
    ⌊ min × nc
}

# Normalized:
# takes "struct of arrays" style matrix
# (one major cell per axis of elements)
# and normalizes the elements
Nd ← {(√+˝×˜𝕩)⊸(÷˜)˘ 𝕩}

DrawBoids ← { 𝕊bs:
    h ← 16 # triangle height
    w ← 8 # triangle width
    x_y ← DispCoord 2↑bs
    ndx_dy ← Nd 2↓bs # normalized

    tips ←  ⌊x_y + h ×  ndx_dy
    left ← 	⌊x_y + w × ⌽ ¯1⊸×⌾⊏ndx_dy
    right ← ⌊x_y - w × ⌽ ¯1⊸×⌾⊏ndx_dy

	f ← 2÷˜ 1+ ÷˜⟜↕ ≠⍉tips # fading
	Fade ← {255˘⌾(¯1⊸⊏˘) ⌊𝕩⊸×˘f}
    (Fade red) {𝕨 r.draw.Circle 𝕩‿10}˘ ⍉tips
    (Fade green) {𝕨 r.draw.Circle 𝕩‿6}˘ ⍉right
    (Fade blue) {𝕨 r.draw.Circle 𝕩‿6}˘ ⍉left

    # to be added back once I figure out why do the triangles
	# occasionally disappear

    # {white r.draw.Triangle(3‿2⥊𝕩)}_debug˘ ⍉tips∾right∾left
}

PerFrame ← {
    DrawArena@
    DrawBoids boids
	boids Up↩

    100|𝕩+1
}r.draw._withCanvas⟜black


PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Boid"
