;+
; Script for making frames from a plane of EPPIC den1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Read a plane of den1 data
@den1_read_plane

;;==Load graphics keywords for den1
@den1_kw

;;==Create image frames of den1 data
filename = path+path_sep()+'frames'+ $
           path_sep()+'den1-'+time.index+'.pdf'
data_graphics, den1,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

;;==Calculate the spatial FFT of the den1 plane
fdata = den1
@fft_2D_time

;;==Load graphics keywords for FFT images
@fft_kw

;;==Create image frames of den1 spatial FFT
filename = path+path_sep()+'frames'+ $
           path_sep()+'den1_fft-'+time.index+'.pdf'
data_graphics, fdata,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

