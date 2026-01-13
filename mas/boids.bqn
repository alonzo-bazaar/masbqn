# utilities
RandArr ← 1000⊸(⊣÷˜•rand.Range˜)

Norm2	←	(+´)∘(×˜˘)∘-	# norm squared
Norm	←	√Norm2			# norm
Dist2	←	Norm2-			# distance squared
Dist	←	Norm-			# distance

_debug ← {
	•Out "𝕨 is"∾•Repr 𝕨
	•Out "𝕩 is"∾•Repr 𝕩
	𝕨𝔽𝕩
}

# boids
nboids ← 20
boids ← RandArr nboids‿4	# major cells are ⟨x, y, dx, dy⟩
boids ÷⟜1000 ⌾(¯2⊸↑˘)↩		# lower speed for safety, this is a rather scuffed run

# given arrays x y indicating positions
# return array of arrays (thus boxed)
# where every element neigh_i of the result
# is an array of indices of neighbours of x_i‿y_i
# where xi = i⊑x, yi = i⊑y

# TODO: for large boid arrays Dist2⌜˜ is probably a bad idea
# 
# for if it does allocate an (≠⍉boids)‿(≠⍉boids) shaped array
# and is not fused away somehow... das a lot of memory

# 0‿0⍉ picks the diagonal and I still have no idea how that works, but it does
NeighInds ← {d 𝕊 boids:
	xy←2↑⌾⍉boids
	d2 ← d×d
	/¨ <˘ 0¨⌾(0‿0⊸⍉) d2 > Dist2⌜˜ <˘ xy 
}

Neighs ← {d 𝕊 boids:
	⊏⟜(<˘boids)¨ d NeighInds boids
}

Centers ← +´¨ ÷ 1⊸⌈∘(≠¨)

ClampVs ← { 𝕊vs: # velocities
    mods ← +˝ ×˜⌾⥊ ⍉vs
	clamped ← 0.00001 ⌈ 0.001 ⌊ mods
	clamped × vs÷mods
}

Update ← {𝕊 boids:
    # neightbours
    ns   ← 0.1  Neighs boids
    dncs ← boids - >4⊸↑¨ Centers ns
    nf   ← ¯0.008 × 2⊸↑˘ dncs
    nf   (0≠≠¨ns)⊸×↩
    smf  ← ¯0.3 × ¯2⊸↑˘ dncs
    smf   (0≠≠¨ns)⊸×↩

    rs   ← 0.05 Neighs boids
    rf   ← 0.05 × 2⊸↑˘ boids - >4⊸↑¨ Centers rs
    rf   (≠¨rs)⊸×↩

    x‿y‿dx‿dy ← <˘ ⍉boids
    siwf      ← ⍉ 0.003 × ((x>0.9) -˜ x<0.1) ≍ ((y>0.9) -˜ y<0.1)

    nx      ← 0.08 ⌈ 0.92 ⌊ x + dx
    ny      ← 0.08 ⌈ 0.92 ⌊ y + dy
    ndx‿ndy ← <˘ ⍉ ClampVs nf + smf + + rf + siwf + ¯2⊸↑˘boids
    ⍉> nx‿ny‿ndx‿ndy
}

# hic est raylib
⟨⟨white, black, red, blue⟩⇐color⟩←r←•Import "../rayed-bqn/rayed.bqn"
DrawArena ← { 𝕊@:
          min ← ⌊´ r.window.GetSize@
		  64‿64‿64‿255 r.draw.Rectangle [0‿0, min‿min]
}
DispCoord ← {
    𝕊coords:
    min ← ⌊´ r.window.GetSize@
    ⌊ min⊸× coords
}

DrawBoid ← { 𝕊boid:
    dr ← 5
	x‿y ← DispCoord 2↑boid
	dx‿dy ← Norm2⊸÷˜ 2↓boid	

    {white r.draw.Circle ⟨(⌊¨𝕩)⋄dr⟩} x‿y
}

PerFrame ← {
    DrawArena@
    DrawBoid˘boids
   			 
	boids Update↩
    100|𝕩+1
}r.draw._withCanvas⟜black


PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Boid"
