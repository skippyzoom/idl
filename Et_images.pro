;+
; Script for making image frames of E-field plane angle. 
;
; Note that the two components are the logical 'x' and 'y' components
; in the given plane, as set by the AXES variable. See notes in 
; Ex_images.pro and Ey_images.pro.
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

;;==Load graphics keywords for Et
@default_image_kw
dsize = size(Et)
nx = dsize[1]
ny = dsize[2]
data_aspect = float(ny)/nx
image_kw['min_value'] = -!pi
image_kw['max_value'] = +!pi
ct = get_custom_ct(2)
image_kw['rgb_table'] = [[ct.r],[ct.g],[ct.b]]
image_kw['xtitle'] = 'Zonal [m]'
image_kw['ytitle'] = 'Vertical [m]'
image_kw['xticklen'] = 0.02
image_kw['yticklen'] = 0.02*data_aspect
colorbar_kw['title'] = '$tan^{-1}(\delta E)$ [rad.]'

;;==Create image frame(s) of Et data
if n_elements(file_description) eq 0 then $
   file_description = ''
filename = expand_path(path+path_sep()+'frames')+ $
           path_sep()+'efield_t'+axes+ $
           '-'+file_description+ $
           '-'+time.index+ $
           '.'+get_extension(frame_type)
data_graphics, Et[x0:xf-1,y0:yf-1,*], $
               xdata[x0:xf-1],ydata[y0:yf-1], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
