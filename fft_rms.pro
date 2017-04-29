;+
; Compute the spatial FFT of data, then calculate
; the temporal RMS array. The result will be a 
; purely spatial array.
;
; KEYWORDS
; -- fftPlane: The spatial plane of a 3-D data 
;    array in which to calculate the FFT. This
;    routine ignores the fftPlane keyword if
;    data is physically 2-D or if nfftDims = 3.
;    Not case sensitive. Defaults to 'xy' 
; -- nfftDims: The dimension of the array passed
;    to the FFT routine. If the input array is 
;    physically 2-D (i.e. one logical dimension
;    is singular) then this keyword has no effect.
;    If the input array is physically 3-D, this
;    keyword determines whether to calculate the
;    spatial FFT in a 2-D slice or in the full
;    3-D volume. Defaults to 2.
; -- origin: A 3-element array of coordinates 
;    that define the origin of the 3-D volume
;    for the sake of extracting 2-D from a 3-D
;    input array. Defaults to [nx/2,ny/2,nz/2],
;    where size(<input array>) determines nx,ny,nz.
;
; HISTORY
; -- 13Apr2017: Started (may)
;-

function fft_rms, data, $
                  ;; overwrite=overwrite, $
                  fftPlane=fftPlane, $
                  nfftDims=nfftDims, $
                  origin=origin

  if n_elements(data) eq 0 then $
     message, "Please supply data array"
  dataSize = size(reform(data))
  ndim = dataSize[0]-1
  nx = dataSize[1]
  ny = dataSize[2]
  nz = (ndim eq 3) ? dataSize[3] : 1
  ;; nz = 1
  ;; if ndim eq 3 then nz = dataSize[3]
  nt = dataSize[dataSize[0]]

  if n_elements(nfftDims) eq 0 then nfftDims = 2
  if n_elements(fftPlane) eq 0 then fftPlane = 'xy'
  if n_elements(origin) eq 0 then origin = [nx/2,ny/2,nz/2]

  ;; if nfftDims eq 2 then begin
  ;;    case ndim of
  ;;       2: fftdata = fft_custom(data[*,*,0,*], $
  ;;                               /skip_time_fft, $
  ;;                               /center)
  ;;       3: begin
  ;;          case 1B of
  ;;             strcmp(fftPlane,'xy',/fold_case): $
  ;;                fftdata = fft_custom(data[*,*,origin[2],*], $
  ;;                                     /skip_time_fft, $
  ;;                                     /center)
  ;;             strcmp(fftPlane,'xz',/fold_case): $
  ;;                fftdata = fft_custom(data[*,origin[1],*,*], $
  ;;                                     /skip_time_fft, $
  ;;                                     /center)
  ;;             strcmp(fftPlane,'yz',/fold_case): $
  ;;                fftdata = fft_custom(data[origin[0],*,*,*], $
  ;;                                     /skip_time_fft, $
  ;;                                     /center)
  ;;          endcase
  ;;       end
  ;;    endcase         
  ;; fftdata = reform(fftdata)
  ;; fftrms = rms(fftdata,dim=3)
  ;; endif else begin
  ;;    fftdata = fft_custom(data,/skip_time_fft,/center)
  ;;    fftrms = rms(fftdata,dim=4)
  ;; endelse

  case ndim of
     2: begin
        fftdata = fft_custom(reform(data), $
                             /skip_time_fft, $
                             ;; overwrite = overwrite, $
                             /center)
        fftdata = reform(fftdata)
        fftrms = rms(fftdata,dim=3)
     end
     3: begin
        if nfftDims eq 2 then begin
           case 1B of
              strcmp(fftPlane,'xy',/fold_case): $
                 fftdata = fft_custom(data[*,*,origin[2],*], $
                                      /skip_time_fft, $
                                      ;; overwrite = overwrite, $
                                      /center)
              strcmp(fftPlane,'xz',/fold_case): $
                 fftdata = fft_custom(data[*,origin[1],*,*], $
                                      /skip_time_fft, $
                                      ;; overwrite = overwrite, $
                                      /center)
              strcmp(fftPlane,'yz',/fold_case): $
                 fftdata = fft_custom(data[origin[0],*,*,*], $
                                      /skip_time_fft, $
                                      ;; overwrite = overwrite, $
                                      /center)
           endcase
           fftdata = reform(fftdata)
           fftrms = rms(fftdata,dim=3)
        endif else begin
           fftdata = fft_custom(data, $
                                /skip_time_fft, $
                                ;; overwrite = overwrite, $
                                /center)
           fftrms = rms(fftdata,dim=4)
        endelse
     end
  endcase

       

  return, fftrms
end
