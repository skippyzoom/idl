;+
; Script for making movies from a plane of EPPIC denft1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set graphics ranges
x0 = nx/2
xf = nx/2+nx/8
y0 = ny/2-nx/8
yf = ny/2+nx/8

;;==Condition data for (kx,ky,t) images
dc_mask = 3
mask_index = [[nx/2-dc_mask,nx/2+dc_mask], $
              [ny/2-dc_mask,ny/2+dc_mask], $
              [0,n_elements(time.index)]]
fdata = condition_fft(denft1, $
                      /magnitude, $
                      shift = [nx/2,ny/2,0], $
                      mask_index = mask_index, $
                      missing = 1e-6, $
                      /finite, $
                      /normalize, $
                      /to_dB)
fdata = mirror_denft_plane(fdata)

;;==Set up kx and ky vectors for images
xdata = 2*!pi*fftfreq(nx,dx)
xdata = shift(xdata,nx/2)
ydata = 2*!pi*fftfreq(ny,dy)
ydata = shift(ydata,ny/2)

;;==Declare file type
movie_type = '.mp4'

;;==Declare specific graphics keywords
@denft1_kw

;;==Create image movie of den1 data
filename = expand_path(path+path_sep()+'movies'+ $
           path_sep()+'denft1')+ $
           '.'+get_extension(movie_type)
;; data_graphics, fdata[x0:xf-1,y0:yf-1,*], $
;;                xdata[x0:xf-1],ydata[y0:yf-1], $
;;                /make_movie, $
;;                filename = filename, $
;;                image_kw = image_kw, $
;;                colorbar_kw = colorbar_kw
data_graphics, fdata[x0:xf-1,y0:yf-1,*], $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
