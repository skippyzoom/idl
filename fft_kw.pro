;+
; Script to set graphics keyword preferences for FFTs
;-

@default_kw.scr

dsize = size(fdata)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

image_kw['min_value'] = -30
image_kw['max_value'] = 0
image_kw['rgb_table'] = 39
image_kw['xtitle'] = '$k_{Zon}$ [m$^{-1}$]'
image_kw['ytitle'] = '$k_{Ver}$ [m$^{-1}$]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = 'Power [dB]'
