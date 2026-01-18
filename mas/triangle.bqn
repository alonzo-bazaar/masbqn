# file made only to see a triangle fuck itself up
# not related to repo, just a demonstration of me not knowing
# how to call r.draw.Triangle
⟨⟨white, black, red, green, blue⟩ ⇐color⟩←r←•Import "../rayed-bqn/rayed.bqn"

# translate normalized coordinates (with box x and y ∊ (0, 1))
# into window coordinates (I'm drawing everything in a square area)
DispCoord ← {𝕊nc:
    min ← ⌊´ r.window.GetSize@
    ⌊ min × nc
}

# mark the square area I'm drawing everyting in
DrawArena ← { 𝕊@:
          min ← ⌊´ r.window.GetSize@
		  64‿64‿64‿255 r.draw.Rectangle [0‿0, min‿min]
}

# normalization function for shit passed as struct of arrays
Nd ← {(√+˝×˜𝕩)⊸(÷˜)˘ 𝕩}

DrawBoids ← { 𝕊bs:
    h ← 160 # triangle height
    w ← 80 # triangle width
    x_y ← DispCoord 2↑bs
    ndx_dy ← Nd 2↓bs # normalized

    tips ←  ⌊x_y + h ×  ndx_dy
    left ← 	⌊x_y + w × ⌽ ¯1⊸×⌾⊏ndx_dy
    right ← ⌊x_y - w × ⌽ ¯1⊸×⌾⊏ndx_dy

    {red r.draw.Circle 𝕩‿10}˘ ⍉tips
    {green  r.draw.Circle 𝕩‿10}˘ ⍉right
    {blue   r.draw.Circle 𝕩‿10}˘ ⍉left

    {white r.draw.Triangle(3‿2⥊𝕩)}˘ ⍉tips∾left∾right
}

Boids ← { 𝕊t:
    theta ← 2×π× 400÷˜ 400|t
	# I'm using a struct of arrays representation for the triangles
	# so the data may be passed a bit weird between functions
	⍉≍[0.5, 0.5, •math.Sin theta, •math.Cos theta]
}

time ← 0

PerFrame ← {
    DrawArena@
    DrawBoids Boids time
	time 1⊸+↩

    100|𝕩+1
}r.draw._withCanvas⟜black

PerFrame•_While_(¬r.window.ShouldClose)∘0 r.window._openAs "Boid"
