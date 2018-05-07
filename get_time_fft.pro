function get_time_fft, data, $
                       lun=lun, $
                       n_fft=n_fft, $
                       _EXTRA=ex

  ;;==Default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get dimensions of input array
  dsize = size(data)
  ndims = dsize[0]
  nx = dsize[1]
  ny = dsize[2]
  case ndims of 
     3: begin
        nt = dsize[3]

        ;;==Default n_fft
        if n_elements(n_fft) eq 0 then n_fft = [nx,ny,nt]

        ;;==Calculate the spatial FFT of the data
        fftdata = make_array(n_fft,type=6,value=0)
        for it=0,nt-1 do $
           fftdata[*,*,it] = fft(data[*,*,it])

        ;;-->RMS over time here?

        ;;==Condition the data
        fsize = size(fftdata)
        nkx = fsize[1]
        nky = fsize[2]
        ntf = fsize[3]
        if n_elements(ex) ne 0 then $
           fftdata = condition_fft(fftdata,_EXTRA=ex)

        return, fftdata
     end
     4: begin
        nz = dsize[3]
        nt = dsize[4]

        ;;==Default n_fft
        if n_elements(n_fft) eq 0 then n_fft = [nx,ny,nz,nt]

        ;;==Calculate the spatial FFT of the data
        fftdata = make_array(n_fft,type=6,value=0)
        for it=0,nt-1 do $
           fftdata[*,*,*,it] = fft(data[*,*,*,it])

        ;;-->RMS over time here?

        ;;==Condition the data
        fsize = size(fftdata)
        nkx = fsize[1]
        nky = fsize[2]
        nkz = fsize[3]
        ntf = fsize[4]
        if n_elements(ex) ne 0 then $
           fftdata = condition_fft(fftdata,_EXTRA=ex)

        return, fftdata
     end
     else: begin
        printf, lun,"[GET_TIME_FFT] Input array may be (2+1)-D or (3+1)-D."
        return, !NULL
     end
  endcase

end
