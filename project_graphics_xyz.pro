;+
; Create spatial graphics from project context
;-
pro project_graphics_xyz, context,name,class

  ;;-->Eventually want to select routines based on graphics_class
  pgxyz_img, context,name
  pgxyz_rms, context,name

end
