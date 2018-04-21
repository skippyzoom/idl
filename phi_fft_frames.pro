;;==Calculate the spatial FFT of the phi plane
fdata = phi
@fft_2D_time

;;==Load graphics keywords for FFT images
@fft_kw

;;==Create image frames of phi spatial FFT
filename = path+path_sep()+'frames'+ $
           path_sep()+'phi_fft-'+time.index+'.pdf'
data_graphics, fdata,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
