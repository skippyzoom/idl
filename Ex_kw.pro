;+
; Script to set graphics keyword preferences for E-field x component
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

@default_kw.scr

dsize = size(Ex)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

image_kw['min_value'] = -max(abs(Ex[*,*,1:*]))
image_kw['max_value'] = +max(abs(Ex[*,*,1:*]))
image_kw['rgb_table'] = 5
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$\delta E_x$ [V/m]'
