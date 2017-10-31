;+
; A lightweight routine for checking EPPIC simulation output
; prior to more intensive analysis.
;-
pro quick_look, path
  cd, path
  params = set_eppic_params(path)
  grid = set_grid(path)
  nt_max = calc_timesteps(path,grid)
  data = load_eppic_data(['den1','phi'],path=path)

  img = image(data.phi[*,*,0,0],/buffer,rgb_table=5)
  image_save, img,filename="phi-t0.png"
  img = image(data.phi[*,*,0,nt_max-1],/buffer,rgb_table=5)
  image_save, img,filename="phi-tf.png"

  img = image(data.den1[*,*,0,0],/buffer,rgb_table=5)
  image_save, img,filename="den1-t0.png"
  img = image(data.den1[*,*,0,nt_max-1],/buffer,rgb_table=5)
  image_save, img,filename="den1-tf.png"

  img = image(smooth(data.den1[*,*,0,0],2.0/grid.dx,/edge_wrap),/buffer,rgb_table=5)
  image_save, img,filename="den1_sm-t0.png"
  img = image(smooth(data.den1[*,*,0,nt_max-1],2.0/grid.dx,/edge_wrap),/buffer,rgb_table=5)
  image_save, img,filename="den1_sm-tf.png"
end
