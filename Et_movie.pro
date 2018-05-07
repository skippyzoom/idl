;+
; Script for making image movies of E-field plane angle. 
;
; Note that the two components are the logical 'x' and 'y' components
; in the given plane, as set by the AXES variable. See notes in 
; Ex_images.pro and Ey_images.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Declare file type
if n_elements(movie_type) eq 0 then movie_type = '.mp4'

;;==Add a description to the file name
;;  (e.g., 'full', 'center512', 'right_half' to distinguish different
;;  sets of ranges)
file_description = 'full'

;;==Declare graphics ranges wrt current plane
x0 = 0
xf = nx
y0 = 0
yf = ny

;;==Set up graphics keywords
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

;;==Create image movie of den1 data
if n_elements(file_description) eq 0 then $
   file_description = ''
filename = expand_path(path+path_sep()+'movies')+ $
           path_sep()+'efield_t'+axes+ $
           '-'+file_description+ $
           '.'+get_extension(movie_type)
data_graphics, Et[x0:xf-1,y0:yf-1,*], $
               xdata[x0:xf-1],ydata[y0:yf-1], $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
