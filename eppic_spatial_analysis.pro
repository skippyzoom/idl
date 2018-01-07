;+
; This routine makes images from EPPIC spatial data. 
;-
pro eppic_spatial_analysis, info

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract currect quantity name
     data_name = info.data_names[id]
     
     ;;==Read data
     data = (load_eppic_data(data_name,path=info.path,timestep=info.timestep))[data_name]

     ;;==Get data dimensions
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

        ;;==Loop over 2-D image planes
        for ip=0,n_elements(info.planes)-1 do begin

           ;;==Set up 2-D image
           case 1B of 
              strcmp(info.planes[ip],'xy') || strcmp(info.planes[ip],'yx'): begin
                 imgplane = reform(data[*,*,info.zctr,*])
                 xdata = info.xvec
                 ydata = info.yvec
                 xrng = info.xrng
                 yrng = info.yrng
                 dx = info.params.dx
                 dy = info.params.dy
                 Ex0 = info.params.Ex0_external
                 Ey0 = info.params.Ey0_external
              end
              strcmp(info.planes[ip],'xz') || strcmp(info.planes[ip],'zx'): begin
                 imgplane = reform(data[*,info.yctr,*,*])
                 xdata = info.xvec
                 ydata = info.zvec
                 xrng = info.xrng
                 yrng = info.zrng
                 dx = info.params.dx
                 dy = info.params.dz
                 Ex0 = info.params.Ex0_external
                 Ey0 = info.params.Ez0_external
              end
              strcmp(info.planes[ip],'yz') || strcmp(info.planes[ip],'zy'): begin
                 imgplane = reform(data[info.xctr,*,*,*])
                 xdata = info.yvec
                 ydata = info.zvec
                 xrng = info.yrng
                 yrng = info.zrng
                 dx = info.params.dy
                 dy = info.params.dz
                 Ex0 = info.params.Ey0_external
                 Ey0 = info.params.Ez0_external
              end
           endcase

           ;;==Save string for filenames
           if data_is_2D then plane_string = '' $
           else plane_string = '_'+info.planes[ip]

           ;;==Create images of densities
           if strcmp(data_name,'den',3) then begin
              density_images, imgplane,xdata,ydata,xrng,yrng,data_name,info,image_string=plane_string
           endif

           if strcmp(data_name,'phi') then begin
              ;;==Create images of electrostatic potential
              potential_images, imgplane,xdata,ydata,xrng,yrng,info,image_string=plane_string

              ;;==Create image of electric field
              efield_images, imgplane,xdata,ydata,xrng,yrng,dx,dy,Ex0,Ey0,nt,info,image_string=plane_string

              ;;==Create rms plots of electric field
           endif
        endfor   ;;--planes
     endif $     ;;--n_dims
     else print, "[EPPIC_PHI_IMAGES] Could not create an image."

  endfor ;;--data_names

end
