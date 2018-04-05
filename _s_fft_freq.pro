;+
; Script to read a data plane, calculate the full FFT, and make an image
; of the two relevant k-w spectra.
;-
;;==Declare the distribution
den = 'den1'

;;==Set the path to here
path = './'

;;==Read simulation parameters
params = set_eppic_params(path=path)

;;==Calculate max number of time steps
nt_max = calc_timesteps(path=path)

;;==Set up time-step info
time = time_strings(params.nout*lindgen(nt_max), $
                    dt=params.dt,scale=1e3,precision=2)

;;==Extract a plane of density data
plane = read_data_plane(name, $
                        timestep = fix(time.index), $
                        axes = 'xy', $
                        data_type = 4, $
                        data_isft = 0B, $
                        ranges = [0,1,0,1,0,1], $
                        rotate = 3, $
                        info_path = path, $
                        data_path = path+path_sep()+'parallel')

;;==Extract the data array for speed
fdata = plane.remove('f')
dx = plane.remove('dx')
dy = plane.remove('dy')
plane = !NULL

;;==Get dimensions of data array
fsize = size(fdata)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;==Set up spectral array
nkx = nx
nky = ny
nw = next_power2(nt)
fftarr = make_array(nkx,nky,nw,type=6,value=0)
fftarr[0:nx-1,0:ny-1,0:nt-1] = fdata

;;==Condition data for (kx,ky,w) images
fdata = abs(fftarr)
dc_mask = 3
fdata[nkx/2-dc_mask:nkx/2+dc_mask, $
      nky/2-dc_mask:nky/2+dc_mask,nw/2] = min(fdata) $     
fdata /= max(fdata)
fdata = 10*alog10(fdata^2)

;;==Set up kx, ky, and w vectors
xdata = 2*!pi*fftfreq(nkx,dx)
xdata = shift(xdata,nkx/2)
ydata = 2*!pi*fftfreq(nky,dy)
ydata = shift(ydata,nky/2)
wdata = 2*!pi*fftfreq(nw,dt)
wdata = shift(wdata,nw/2)

;;==Make frames(s)
kw = set_graphics_kw(data = fdata, $
                     context = name+'_fft')
img = image(fdata[*,nky/2,*],xdata,wdata, $
            /buffer, $
            _EXTRA = kw.image.tostruct())
clr = colorbar(target = img, $
               _EXTRA = kw.colorbar.tostruct())
filename = name+'_kx-w.pdf'
image_save, img, filename = filename
img = image(fdata[nkx/2,*,*],ydata,wdata, $
            /buffer, $
            _EXTRA = kw.image.tostruct())
clr = colorbar(target = img, $
               _EXTRA = kw.colorbar.tostruct())
filename = name+'_ky-w.pdf'
image_save, img, filename = filename
