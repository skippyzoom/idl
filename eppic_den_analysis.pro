;+
; This routine makes images from EPPIC den data. 
; Other images that require den should go here.
;-
pro eppic_den_analysis, info

  ;;==Loop over available distributions
  n_dist = info.params.ndist
  for id=0,n_dist-1 do begin
     dist_name = 'den'+strcompress(id,/remove_all)

     ;;==Read data
     data = (load_eppic_data(dist_name,path=info.path,timestep=info.timestep))[dist_name]

     ;;==Get data dimensions
     data_size = size(data)
     n_dims = data_size[0]
     nt = data_size[n_dims]
     switch n_dims-1 of
        3: nz = data_size[3]
        2: ny = data_size[2]
        1: nx = data_size[1]
     endswitch

     ;;==Check dimensions
     if n_dims gt 2 then begin

        ;;==Set imaging flag
        image_data_exists = 0B

        ;;==Transpose data
        xyzt = info.xyz
        case n_dims of
           4: begin
              if n_elements(info.xyz) eq 2 then xyzt = [info.xyz,[2,3]] $
              else xyzt = [info.xyz,3]
           end
           3: begin
              if n_elements(info.xyz) gt 2 then xyzt = [info.xyz[0:1],2]
           end
           else: xyzt = indgen(n_dims)
        endcase
        data = transpose(data,xyzt)

        ;;==Loop over 2-D image planes
        n_planes = (n_dims eq 4) ? n_elements(info.planes) : 1
        for ip=0,n_planes-1 do begin

           case n_dims of 
              4: begin

                 ;;==Set up 2-D image
                 case 1B of 
                    strcmp(info.planes[ip],'xy') || strcmp(info.planes[ip],'yx'): begin
                       imgplane = reform(data[*,*,info.zctr,*])
                       xdata = info.xvec
                       ydata = info.yvec
                       xrng = info.xrng
                       yrng = info.yrng
                    end
                    strcmp(info.planes[ip],'xz') || strcmp(info.planes[ip],'zx'): begin
                       imgplane = reform(data[*,info.yctr,*,*])
                       xdata = info.xvec
                       ydata = info.zvec
                       xrng = info.xrng
                       yrng = info.zrng
                    end
                    strcmp(info.planes[ip],'yz') || strcmp(info.planes[ip],'zy'): begin
                       imgplane = reform(data[info.xctr,*,*,*])
                       xdata = info.yvec
                       ydata = info.zvec
                       xrng = info.yrng
                       yrng = info.zrng
                    end
                 endcase

                 ;;==Update imaging flag
                 image_data_exists = 1B

                 ;;==Save string for filenames
                 plane_string = '_'+info.planes[ip]

              end
              3: begin

                 ;;==Set up 2-D image
                 imgplane = reform(data)
                 xdata = info.xvec
                 ydata = info.yvec
                 xrng = info.xrng
                 yrng = info.yrng

                 ;;==Update imaging flag
                 image_data_exists = 1B

                 ;;==Save string for filenames
                 plane_string = ''

              end
              else: print, "[EPPIC_DEN_IMAGES] Currently set up for 2 or 3 spatial dimensions."
           endcase

           if image_data_exists then begin

              ;;==Create images of densities
              density_images, imgplane,xdata,ydata,xrng,yrng,dist_name,info,image_string=plane_string

           endif ;;--image_data_exists
        endfor   ;;--n_planes
     endif $     ;;--n_dims gt 2
     else print, "[EPPIC_DEN_IMAGES] Could not create an image."

  endfor ;;n_dist
end
