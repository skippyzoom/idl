;+
; Script for making movies from a plane of EPPIC den1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Read a plane of den1 data
@den1_read_plane

;;==Load graphics keywords for den1
@den1_kw

;;==Create image movies of den1 data
filename = path+path_sep()+'movies'+ $
           path_sep()+'den1-'+time.index+'.mp4'
data_graphics, den1,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

;;==Calculate the spatial FFT of the den1 plane
fdata = den1
@fft_2D_time

;;==Load graphics keywords for FFT images
@fft_kw

;;==Create image movies of den1 spatial FFT
filename = path+path_sep()+'movies'+ $
           path_sep()+'den1_fft-'+time.index+'.mp4'
data_graphics, fdata,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

