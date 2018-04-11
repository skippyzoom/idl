;+
; Script for making movies from a plane of EPPIC phi data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Read a plane of phi data
@phi_read_plane

;;==Load graphics keywords for phi
@phi_kw

;;==Create image movies of phi data
filename = path+path_sep()+'movies'+ $
           path_sep()+'phi-'+time.index+'.pdf'
data_graphics, phi,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

;;==Calculate the spatial FFT of the phi plane
fdata = phi
@fft_2D_time

;;==Load graphics keywords for FFT images
@fft_kw

;;==Create image movies of phi spatial FFT
filename = path+path_sep()+'movies'+ $
           path_sep()+'phi_fft-'+time.index+'.pdf'
data_graphics, fdata,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw

