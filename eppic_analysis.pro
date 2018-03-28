;+
; A script to analyze EPPIC data
;-
;;==Declare the simulation run path
run = 'run007'
project = 'parametric_wave'
path = get_base_dir()+path_sep()+project+path_sep()+run

;;==Declare the data quantity to analyze
data_name = 'den1'

;;==Read simulation parameters
params = set_eppic_params(path=path)

;;==Calculate max number of time steps
nt_max = calc_timesteps(path=path)

;;==Create the time-step array
;; timestep = params.nout*lindgen(nt_max)
timestep = params.nout*[0,1,nt_max/2,nt_max-1]

;;==Declare normalized data ranges
ranges = [0.0,1.0,0.0,1.0]

;;==Extract a data plane
plane = eppic_data_plane(data_name, $
                         timestep = timestep, $
                         axes = 'xy', $
                         data_type = 4, $
                         data_isft = 0B, $
                         ranges = ranges, $
                         rotate = 3, $
                         info_path = path, $
                         data_path = path+path_sep()+'parallel')

;;==Extract arrays
fdata = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')

;;==Get dimensions of data plane
fsize = size(fdata)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;-->TO DO: Put spectral analysis stuff here
;; nkx = max([nx,ny])
;; nky = max([nx,ny])
nkx = nx
nky = ny
tmp = fdata
fdata = make_array(nkx,nky,nt,type=6,value=0)
;; fdata[0:nx-1,0:ny-1,*] = tmp
fdata[nkx/2-nx/2:nkx/2+nx/2-1,nky/2-ny/2:nky/2+ny/2-1,*] = tmp
tmp = !NULL
for it=0,nt-1 do $
   fdata[*,*,it] = fft(fdata[*,*,it],/overwrite)
fsize = size(fdata)
nkx = fsize[1]
nky = fsize[2]
fdata = abs(fdata)
fdata = shift(fdata,[nkx/2,nky/2,0])
fdata[nkx/2-3:nkx/2+3,nky/2-3:nky/2+3,*] = min(fdata)
fdata /= max(fdata)
fdata = 10*alog10(fdata^2)
kx = 2*!pi*fftfreq(nkx,dx)
kx = shift(kx,nkx/2)
xdata = kx
ky = 2*!pi*fftfreq(nky,dy)
ky = shift(ky,nky/2)
ydata = ky

@make_image
;; @make_movie
