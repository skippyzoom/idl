;+
; Script to set graphics keyword preferences for E-field magnitude
;-

@default_kw.scr

dsize = size(Er)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

image_kw['min_value'] = 0
image_kw['max_value'] = max(Er[*,*,1:*])
image_kw['rgb_table'] = 3
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$|\delta E|$ [V/m]'
