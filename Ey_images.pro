;+
; Script for making image frames of E-field y component.
;
; Note that this is the logical y component for the given plane.
; In other words, it is the 'y' component in the 'xy' plane, the
; 'z' component in the 'xz' plane, or the 'z' component in the
; 'yz' plane.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Declare frame type
frame_type = '.pdf'

;;==Add a description to the file name
;;  (e.g., 'full', 'center512', 'right_half' to distinguish different
;;  sets of ranges)
file_description = 'full'

;;==Declare image ranges
x0 = 0
xf = nx
y0 = 0
yf = ny

;;==Load graphics keywords for Ey
@default_image_kw
dsize = size(Ey)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx
image_kw['min_value'] = -max(abs(Ey[*,*,1:*]))
image_kw['max_value'] = +max(abs(Ey[*,*,1:*]))
image_kw['rgb_table'] = 5
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$\delta E_y$ [V/m]'

;;==Create image frame(s) of Ey data
if n_elements(file_description) eq 0 then $
   file_description = ''
filename = expand_path(path+path_sep()+'frames')+ $
           path_sep()+'efield_'+strmid(axes,1,1)+ $
           '-'+file_description+ $
           '-'+time.index+ $
           '.'+get_extension(frame_type)
data_graphics, Ey[x0:xf-1,y0:yf-1,*], $
               xdata[x0:xf-1],ydata[y0:yf-1], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
