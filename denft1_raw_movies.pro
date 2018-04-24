;+
; Script for making movies from a plane of EPPIC denft1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set graphics ranges
x0 = nx/2-128
xf = nx/2+128
y0 = ny/2
yf = ny/2+128

;;==Condition data for (kx,ky,t) images
fdata = abs(denft1)
fdata = shift(fdata,[nx/2,ny/2,0])
dc_mask = 3
fdata[nx/2-dc_mask:nx/2+dc_mask, $
      ny/2-dc_mask:ny/2+dc_mask,*] = min(fdata)
fdata /= max(fdata)
fdata = 10*alog10(fdata^2)

;;==Set up kx and ky vectors for images
xdata = 2*!pi*fftfreq(nx,dx)
xdata = shift(xdata,nx/2)
ydata = 2*!pi*fftfreq(ny,dy)
ydata = shift(ydata,ny/2)

;;==Load movie defaults
@raw_movies_defaults

;;==Load default graphics keywords
@default_graphics_kw

;;==Declare specific graphics keywords
dsize = size(denft1)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx
image_kw['min_value'] = -60
image_kw['max_value'] = 0
image_kw['rgb_table'] = 39
image_kw['xtitle'] = 'Zonal [m$^{-1}$]'
image_kw['ytitle'] = 'Vertical [m$^{-1}$]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
image_kw['dimensions'] = 3*[nx,ny]
image_kw['xrange'] = [-!pi,+!pi]
image_kw['yrange'] = [   0,+!pi]
colorbar_kw['title'] = '$Power [dB]$'

;;==Create image movie of denft1 data
filename = path+path_sep()+'movies'+ $
           path_sep()+'denft1'+name_info+'.mp4'
data_graphics, fdata[x0:xf-1,y0:yf-1,*], $
               xdata[x0:xf-1],ydata[y0:yf-1], $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
