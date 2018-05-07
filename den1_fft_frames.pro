;+
; Script for making frames from the FFT of a plane of EPPIC den1 data.
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

;;==Load graphics keywords for FFT images
@default_image_kw
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
image_kw['dimensions'] = [2000,2000]
colorbar_kw['title'] = 'Power [dB]'

;;==Set up file name(s)
if n_elements(file_description) eq 0 then $
   file_description = ''
if keyword_set(rms_range) then $
   filename = expand_path(path+path_sep()+'frames')+ $
              path_sep()+'den1_fft'+ $
              '-'+file_description+ $
              '-rms_'+ $
              string(params.nout*rms_range[0,*],format='(i06)')+ $
              '_'+ $
              string(params.nout*rms_range[1,*],format='(i06)') $
              '.'+get_extension(frame_type) $
else $
   filename = expand_path(path+path_sep()+'frames')+ $
              path_sep()+'den1_fft'+ $
              '-'+file_description+ $
              '-'+time.index+ $
              '.'+get_extension(frame_type)

;;==Create image frame(s) of den1 spatial FFT
data_graphics, fdata[x0:xf-1,y0:yf-1,*], $
               kxdata[x0:xf-1],kydata[y0:yf-1], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
