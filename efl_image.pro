;+
; Create images for eppic_first_look.pro
;
; DATA: 
;   The data to plot. May be 2-D or 3-D.
; NAME: 
;   The name of the data quantity.
; PATH: 
;   The fully qualified path where this 
;   routine will save the images.
; CENTER: 
;   The central index to use when extracting
;   2-D planes from 3-D data. Ignored in 2-D.
; RGB_TABLE: 
;   The color table to use for images. See the
;   online help for image.pro for more info.
; FONT_NAME:
;   The font name to use for labels. See the
;   online help for text.pro for more info.
; FONT_SIZE: 
;   The font size to use for labels. See the
;   online help for text.pro for more info.
;-
pro efl_image, data, $
               name=name, $
               path=path, $
               center=center, $
               rgb_table=rgb_table, $
               font_name=font_name, $
               font_size=font_size

  ;;==Defaults and guards
  if n_elements(name) eq 0 then name = 'eppic_data'
  if n_elements(path) eq 0 then path = './'
  if n_elements(center) eq 0 then center = [0,0,0]
  if n_elements(rgb_table) eq 0 then rgb_table = 0
  if n_elements(font_name) eq 0 then font_name = 'DejaVuSans'
  if n_elements(font_size) eq 0 then font_size = 11

  ;;==Get dimensions of data
  dims = size(data)
  n_dims = dims[0]
  nt = dims[n_dims]
  switch n_dims-1 of 
     3: nz = dims[3]
     2: ny = dims[2]
     1: nx = dims[1]
  endswitch  

  ;;==Create images
  case n_dims-1 of 
     2: begin
        img = image(reform(data[*,*,0]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"-t0.png"
        img = image(reform(data[*,*,nt-1]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"-tf.png"
     end
     3: begin
        img = image(reform(data[*,*,center[2],0]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"_xy-t0.png"
        img = image(reform(data[*,*,center[2],nt-1]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"_xy-tf.png"

        img = image(reform(data[*,center[1],*,0]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"_xz-t0.png"
        img = image(reform(data[*,center[1],*,nt-1]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"_xz-tf.png"

        img = image(reform(data[center[0],*,*,0]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"_yz-t0.png"
        img = image(reform(data[center[0],*,*,nt-1]),/buffer,rgb_table=rgb_table)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=path+path_sep()+name+"_yz-tf.png"
     end
     else: print, "[EPPIC_FIRST_LOOK] Data may be 2-D or 3-D. No image created."
  endcase

end
