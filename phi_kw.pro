;+
; Script to set graphics keyword preferences for phi
;-

@default_kw.scr

dsize = size(phi)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

image_kw['min_value'] = -max(abs(phi[*,*,1:*]))
image_kw['max_value'] = +max(abs(phi[*,*,1:*]))
ct = get_custom_ct(1)
image_kw['rgb_table'] = [[ct.r],[ct.g],[ct.b]]
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$\delta n/n_0$'
