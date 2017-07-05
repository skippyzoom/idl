;+
; Set parameters and keywords for density.
; This function is designed to be called from
; set_kw.pro
;
; TO DO
; -- Use this function to set defaults but allow
;    user to pass custom values through _EXTRA?
;    (e.g. <ret> = set_kw(<name>,max_value=100)).
;    Consider using replace_tag.pro for this.
; -- Handle cases in which user doesn't pass info
;    necessary for a keyword (e.g. imgData for
;    min/max_value). Maybe the user should just
;    pass those things through _EXTRA.
;-
function set_kw_den, imgData=imgData,timestep=timestep
  nSteps = n_elements(timestep)
  imgSize = size(imgData)
  aspect_ratio = 1.0
  ;; position = multi_position(nSteps,edges=[0.10,0.10,0.80,0.80],buffers=[0.05,0.10])
  position = multi_position([1,nSteps],edges=[0.10,0.10,0.80,0.80],buffers=[0.05,0.10])
  title = strcompress(string(timestep,format='(f5.1)'),/remove_all)
  title = "t = "+title+" ms"
  max_abs = max(abs(imgData))
  min_value = -max_abs
  max_value = max_abs
  xmajor = 5
  xminor = 7
  xtickvalues = imgSize[1]*indgen(xmajor)/(xmajor-1)
  xtickname = strcompress(xtickvalues,/remove_all)
  xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
  ymajor = 5
  yminor = 7
  ytickvalues = imgSize[2]*indgen(ymajor)/(ymajor-1)
  ytickname = strcompress(ytickvalues,/remove_all)
  yrange = [ytickvalues[0],ytickvalues[ymajor-1]]
  rgb_table = 5
  image = {axis_style: 2, $
           aspect_ratio: aspect_ratio, $
           position: position, $
           ;; title: title, $
           min_value: min_value, $
           max_value: max_value, $
           xrange: xrange, $
           yrange: yrange, $
           xtickvalues: xtickvalues, $
           ytickvalues: ytickvalues, $
           xtickname: xtickname, $
           ytickname: ytickname, $
           xstyle: 1, $
           ystyle: 1, $
           xtitle: "Zonal [m]", $
           ytitle: "Vertical [m]", $
           xmajor: xmajor, $
           xminor: xminor, $
           ymajor: ymajor, $
           yminor: yminor, $
           xticklen: 0.02, $
           yticklen: 0.02/aspect_ratio, $
           xsubticklen: 0.5, $
           ysubticklen: 0.5, $
           xtickdir: 1, $
           ytickdir: 1, $
           xtickfont_size: 14.0, $
           ytickfont_size: 14.0, $
           font_size: 16.0, $
           font_name: "Times", $
           rgb_table: rgb_table, $
           buffer: 1B}

  img_pos = image.position
  cb_width = 0.03
  cb_height = 0.40
  cb_x0 = max(img_pos[2,*])+0.01
  cb_x1 = cb_x0 + cb_width
  cb_y0 = 0.50-0.50*cb_height
  cb_y1 = 0.50+0.50*cb_height
  global_colorbar = (tag_exist(image,'min_value') and $
                     tag_exist(image,'max_value'))
  position = make_array(4,nSteps,type=4,value=-1)
  if global_colorbar then position[*,0] = [cb_x0,cb_y0,cb_x1,cb_y1] $
  else position = multi_position(nSteps,edges=[[reform(img_pos[2,*])],[reform(img_pos[1,*])]], $
                                 width=0.02,height=img_pos[3,0]-img_pos[1,0])
  major = 7
  tickvalues = 0
  if global_colorbar then $
     tickvalues = (image.max_value-image.min_value)*findgen(major)/(major-1)+ $
                  image.min_value
  tickname = !NULL
  if global_colorbar then $
     tickname = plusminus_labels(tickvalues,format='f5.2')
  title = "$\delta n/n_0 [%]$"
  colorbar = {orientation: 1, $
              title: title, $
              position: position, $
              textpos: 1, $
              tickdir: 1, $
              ticklen: 0.2, $
              major: 7, $
              font_name: "Times", $
              font_size: 14.0}
  if global_colorbar then $
     colorbar = create_struct(colorbar, $
                              'tickvalues',tickvalues, $
                              'tickname',tickname)

  kw = create_struct('image',image,'colorbar',colorbar)
  return, kw
end
