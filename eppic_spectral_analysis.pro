;+
; This routine makes images from EPPIC spectral data. 
;-
pro eppic_spectral_analysis, info

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract currect quantity name
     data_name = info.data_names[id]
     
     ;;==Read data
     data = (load_eppic_data(data_name,path=info.path,timestep=info.timestep))[data_name]

     ;;==Check successful read
     data_is_spatial = 0B
     if size(data,/n_dim) eq 0 then begin

        ;;==Extract the name of the non-FT quantity
        pos = strpos(data_name,'ft')
        data_name = strmid(data_name,0,pos)+strmid(data_name,pos+2)

        ;;==Read data
        data = (load_eppic_data(data_name,path=info.path,timestep=info.timestep))[data_name]

        ;;==Check successful read
        data_is_spatial = (size(data,/n_dim) ne 0) ? 1B : 0B

     endif
     
     ;;==Get data size and dimensions
     data_size = size(data)
     n_dims = data_size[0]
     nt = data_size[n_dims]
     nz = 1
     ny = 1
     nx = 1
     switch n_dims-1 of
        3: nz = data_size[3]
        2: ny = data_size[2]
        1: nx = data_size[1]
     endswitch

     ;;==Check dimensions
     if n_dims gt 2 then begin

        ;;==Make physically 3-D data logically 4-D data
        data_is_2D = 0B
        if n_dims eq 3 then begin
           data_is_2D = 1B
           data = reform(data,[nx,ny,1,nt])
           n_dims = size(data,/n_dim)
           info.planes = 'xy'
        endif

        ;;==Transpose data
        xyzt = info.xyz
        tmp = indgen(n_dims)
        n_xyzt = n_elements(xyzt)
        if n_xyzt lt 4 then xyzt = [xyzt,tmp[n_xyzt,*]]
        data = transpose(data,xyzt)

        ;;==Get new dimensions
        data_size = size(data)
        nz = data_size[3]
        ny = data_size[2]
        nx = data_size[1]

        ;;==Loop over 2-D image planes
        for ip=0,n_elements(info.planes)-1 do begin

           ;;==Set up 2-D image
           case 1B of 
              strcmp(info.planes[ip],'xy') || strcmp(info.planes[ip],'yx'): begin
                 imgplane = reform(data[*,*,info.zctr,*])
                 xdata = (2*!pi/(info.xdif*nx))*(findgen(nx)-0.5*nx)
                 ydata = (2*!pi/(info.ydif*ny))*(findgen(ny)-0.5*ny)
                 xrng = info.xrng
                 yrng = info.yrng
              end
              strcmp(info.planes[ip],'xz') || strcmp(info.planes[ip],'zx'): begin
                 imgplane = reform(data[*,info.yctr,*,*])
                 xdata = (2*!pi/(info.xdif*nx))*(findgen(nx)-0.5*nx)
                 ydata = (2*!pi/(info.zdif*nz))*(findgen(nz)-0.5*nz)
                 xrng = info.xrng
                 yrng = info.zrng
              end
              strcmp(info.planes[ip],'yz') || strcmp(info.planes[ip],'zy'): begin
                 imgplane = reform(data[info.xctr,*,*,*])
                 xdata = (2*!pi/(info.ydif*ny))*(findgen(ny)-0.5*ny)
                 ydata = (2*!pi/(info.zdif*nz))*(findgen(nz)-0.5*nz)
                 xrng = info.yrng
                 yrng = info.zrng
              end
           endcase

           ;;==Save string for filenames
           if data_is_2D then plane_string = '' $
           else plane_string = '_'+info.planes[ip]

           ;;==Transform spatial data
           if data_is_spatial then begin
              for it=0,nt-1 do begin
                 imgplane[*,*,it] = real_part(fft(imgplane[*,*,it],/overwrite))
              endfor              
              data_name += 'fft'
           endif

           ;;==Create images of Fourier-transformed densities
           if strcmp(data_name,'den',3) then begin
              denft_images, imgplane,xdata,ydata,xrng,yrng,data_name,info,image_string=plane_string
           endif

        endfor   ;;--planes
     endif $     ;;--n_dims
     else print, "[EPPIC_PHI_IMAGES] Could not create an image."

  endfor ;;--data_names


end
