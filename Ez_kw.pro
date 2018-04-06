;+
; Script to set graphics keyword preferences for E-field z component
;-

@default_kw.scr

dsize = size(fdata)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

img_pos = [0.10,0.10,0.80,0.80]
clr_pos = [0.82,0.10,0.84,0.80]

image_kw['min_value'] = -max(abs(fdata[*,*,1:*]))
image_kw['max_value'] = +max(abs(fdata[*,*,1:*]))
image_kw['rgb_table'] = 5
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image['xticklen'] = 0.02
image['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$\delta E_z$ [V/m]'
