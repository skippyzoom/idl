;+
; Script for making frames from a plane of EPPIC den1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Declare frame type
frame_type = '.pdf'

;;==Add a description to the file name
;;  (e.g., 'full', 'center512', 'right_half' to distinguish different
;;  sets of ranges)
file_description = 'center512'

;;==Declare image ranges
x0 = nx/2-256
xf = nx/2+256
y0 = ny/2-256
yf = ny/2+256

;;==Load graphics keywords for den1
@default_image_kw
dsize = size(den1)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(yf-y0)/float(xf-x0)
image_kw['min_value'] = -max(abs(den1[*,*,1:*]))
image_kw['max_value'] = +max(abs(den1[*,*,1:*]))
image_kw['rgb_table'] = 5
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
image_kw['title'] = 't = '+time.stamp
image_kw['xshowtext'] = 0
image_kw['yshowtext'] = 0
image_kw['font_size'] = 18.0
colorbar_kw['title'] = '$\delta n/n_0$'
colorbar_kw['font_size'] = 12.0
colorbar_kw['major'] = 5
colorbar_kw['minor'] = 3

;;==Create image frame(s) of den1 data
if n_elements(file_description) eq 0 then $
   file_description = ''
filename = expand_path(path+path_sep()+'frames')+ $
           path_sep()+'den1'+ $
           '-'+file_description+ $
           '-'+time.index+ $
           '.'+get_extension(frame_type)
data_graphics, den1[x0:xf-1,y0:yf-1,*], $
               xdata[x0:xf-1],ydata[y0:yf-1], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
