;+
; A lightweight routine for checking EPPIC simulation output
; prior to more intensive analysis. 
;
; KEEP THIS ROUTINE SIMPLE
; -- Use as few levels of subroutines as possible.
; -- Use IDL-distribution routines as much as possible.
; -- Use only well-tested homemade routines.
; -- Avoid doing complicated analysis.
;    For example: It's okay to calculate an FFT for the
;    sake of plotting a basic spectrum but don't further
;    use that spectrum to calculate V_phase versus |k|. 
;    Do that in a more robust analysis pipeline.
;-
pro quick_look, path,directory=directory

  ;;==Navigate to working directory
  cd, path

  ;;==Echo working directory
  print, "[QUICK_LOOK] In ",path

  ;;==Read in simulation parameters
  params = set_eppic_params(path)
  grid = set_grid(path)
  nt_max = calc_timesteps(path,grid)

  ;;==Read in simulation data
  data = load_eppic_data(['den1','phi'],path=path)

  ;;==Set up graphics keywords
  font_name = 'Times'
  font_size = 10

  ;;==Make a special directory for these graphics
  if n_elements(directory) eq 0 then directory = './'
  spawn, 'mkdir -p '+directory

  ;;==Create images of electrostatic potential
  case params.ndim_space of 
     2: begin
        img = image(reform(data.phi[*,*,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi-t0.png"
        img = image(reform(data.phi[*,*,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi-tf.png"
     end
     3: begin
        img = image(reform(data.phi[*,*,grid.nz/2,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi_xy-t0.png"
        img = image(reform(data.phi[*,*,grid.nz/2,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi_xy-tf.png"

        img = image(reform(data.phi[*,grid.ny/2,*,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi_xz-t0.png"
        img = image(reform(data.phi[*,grid.ny/2,*,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi_xz-tf.png"

        img = image(reform(data.phi[grid.nx/2,*,*,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi_yz-t0.png"
        img = image(reform(data.phi[grid.nx/2,*,*,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"phi_yz-tf.png"
     end
  endcase

  ;;==Create images of ion density
  case params.ndim_space of 
     2: begin
        img = image(reform(data.den1[*,*,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1-t0.png"
        img = image(reform(data.den1[*,*,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1-tf.png"
     end
     3: begin
        img = image(reform(data.den1[*,*,grid.nz/2,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xy-t0.png"
        img = image(reform(data.den1[*,*,grid.nz/2,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xy-tf.png"

        img = image(reform(data.den1[*,grid.ny/2,*,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xz-t0.png"
        img = image(reform(data.den1[*,grid.ny/2,*,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xz-tf.png"

        img = image(reform(data.den1[grid.nx/2,*,*,0]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_yz-t0.png"
        img = image(reform(data.den1[grid.nx/2,*,*,nt_max-1]),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_yz-tf.png"
     end
  endcase

  ;;==Create images of smoothed ion density
  case params.ndim_space of 
     2: begin
        img = image(reform(smooth(data.den1[*,*,0],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_sm-t0.png"
        img = image(reform(smooth(data.den1[*,*,nt_max-1],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_sm-tf.png"
     end
     3: begin
        img = image(reform(smooth(data.den1[*,*,grid.nz/2,0],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xy_sm-t0.png"
        img = image(reform(smooth(data.den1[*,*,grid.nz/2,nt_max-1],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xy_sm-tf.png"

        img = image(reform(smooth(data.den1[*,grid.ny/2,*,0],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xz_sm-t0.png"
        img = image(reform(smooth(data.den1[*,grid.nz/2,*,nt_max-1],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_xz_sm-tf.png"

        img = image(reform(smooth(data.den1[grid.nx/2,*,*,0],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_yz_sm-t0.png"
        img = image(reform(smooth(data.den1[grid.nx/2,*,*,nt_max-1],2.0/grid.dx,/edge_wrap)),/buffer,rgb_table=5)
        txt = text(0.1,0.1,path,target=img,font_name=font_name,font_size=font_size)
        image_save, img,filename=directory+path_sep()+"den1_yz_sm-tf.png"
     end
  endcase

end
