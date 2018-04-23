;+
; Script for making movies from a plane of EPPIC denft1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

@default_kw

dsize = size(denft1)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx

image_kw['min_value'] = -30
image_kw['max_value'] = 0
image_kw['rgb_table'] = 5
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$Power [dB]$'

;;==Condition data for (kx,ky,t) images
fdata = abs(denft1)
dc_mask = 3
fdata[nkx/2-dc_mask:nkx/2+dc_mask, $
      nky/2-dc_mask:nky/2+dc_mask,*] = min(fdata)
fdata /= max(fdata)
fdata = 10*alog10(fdata^2)

;;==Set up kx and ky vectors for images
xdata = 2*!pi*fftfreq(nkx,dx)
xdata = shift(xdata,nkx/2)
ydata = 2*!pi*fftfreq(nky,dy)
ydata = shift(ydata,nky/2)
