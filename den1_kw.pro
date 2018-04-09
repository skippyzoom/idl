;+
; Script to set graphics keyword preferences for den1
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

@default_kw

dsize = size(den1)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

image_kw['min_value'] = -max(abs(den1[*,*,1:*]))
image_kw['max_value'] = +max(abs(den1[*,*,1:*]))
image_kw['rgb_table'] = 5
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$\phi$ [V]'
