;;==Set defaults
if n_elements(name_info) eq 0 then name_info = ''

;;==Calculate the spatial FFT of the den1 plane
fdata = den1
@fft_2D_time

;;==Load graphics keywords for FFT images
@fft_kw

;;==Create image frames of den1 spatial FFT
filename = path+path_sep()+'frames'+ $
           path_sep()+'den1_fft-'+time.index+ $
           name_info+'.pdf'
data_graphics, fdata,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
