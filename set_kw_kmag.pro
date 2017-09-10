;+
; Set parameters and keywords for |k| spectra.
; Handles either frequency-based or time-based
; interpolated arrays (see calc_kmag.pro). 
; This function is designed to be called from
; set_kw.pro
;
; Deprecate? 09Sep2017 (may)
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
function set_kw_kmag, imgData=imgData,frequency=frequency

  if keyword_set(frequency) then begin
     position = [0.2,0.2,0.6,0.6]
     th0 = 0
     ;; thf = 360
     ;; dth = 60
     thf = 180
     dth = 30
     tRange = th0+indgen(thf-th0)
     xtickvalues = th0+dth*indgen(n_elements(tRange)/dth+1)
     xtickname = strcompress(xtickvalues,/remove_all)
     xmajor = n_elements(xtickvalues)
     xminor = 5
     xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
     ytickvalues = float([-500,-250,0,250,500])
     ;; ytickvalues = float([-600,-300,0,300,600])
     ;; ytickvalues = float([-1000,-500,0,500,1000])
     ytickname = plusminus_labels(ytickvalues,format='(f5.1)')
     ymajor = n_elements(ytickvalues)
     yminor = 4
     yrange = [ytickvalues[0],ytickvalues[ymajor-1]]
     aspect_ratio = (xtickvalues[xmajor-1]-xtickvalues[0])/ $
                    (ytickvalues[ymajor-1]-ytickvalues[0])
     ;; if n_elements(lWant) eq 0 then lWant = 2*!pi/kWant

     image = {axis_style: 2, $
              aspect_ratio: aspect_ratio, $
              position: position, $
              ;; min_value: -60, $
              ;; max_value: -20, $
              ;; min_value: -55, $
              ;; max_value: -25, $
              ;; min_value: -80, $
              ;; max_value: -50, $
              min_value: -30, $
              max_value: 0, $
              xrange: xrange, $
              yrange: yrange, $
              xtickvalues: xtickvalues, $
              ytickvalues: ytickvalues, $
              xtickname: xtickname, $
              ytickname: ytickname, $
              xstyle: 1, $
              ystyle: 1, $
              xtitle: "$\theta$ [deg]", $
              ytitle: "$V_{ph}$ [m/s]", $
              xmajor: xmajor, $
              xminor: xminor, $
              ymajor: ymajor, $
              yminor: yminor, $
              xtickfont_size: 10.0, $
              ytickfont_size: 10.0, $
              xticklen: 0.02, $
              ;; yticklen: 0.02*aspect_ratio, $
              yticklen: 0.02, $
              xsubticklen: 0.2, $
              ysubticklen: 0.2, $
              xtickdir: 1, $
              ytickdir: 1, $
              font_size: 14, $
              font_name: "Times", $
              rgb_table: 13, $
              ;; rgb_table: 39, $
              buffer: 1B}

     colorbar = {orientation: 1, $
                 title: "Power [dB]", $
                 textpos: 1, $
                 tickdir: 1, $
                 ticklen: 0.2, $
                 font_name: "Times", $
                 font_size: 14}
  endif else begin
     position = [0.2,0.2,0.6,0.6]
     th0 = 0
     thf = 360
     dth = 60
     tRange = th0+indgen(thf-th0)
     xtickvalues = th0+dth*indgen(n_elements(tRange)/dth+1)
     xtickname = strcompress(xtickvalues,/remove_all)
     xmajor = n_elements(xtickvalues)
     xminor = 5
     xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
     imgSize = size(imgData)
     ymajor = 4
     timestep = imgSize[imgSize[0]]*indgen(ymajor)/(ymajor-1)
     ytickname = strcompress(string(timestep),/remove_all)
     yminor = 10
     yrange = [ytickvalues[0],ytickvalues[ymajor-1]]
     aspect_ratio = (xtickvalues[xmajor-1]-xtickvalues[0])/ $
                    (ytickvalues[ymajor-1]-ytickvalues[0])
     ;; if n_elements(lWant) eq 0 then lWant = 2*!pi/kWant

     image = {axis_style: 2, $
              aspect_ratio: aspect_ratio, $
              position: position, $
              min_value: -60, $
              max_value: -20, $
              xrange: xrange, $
              yrange: yrange, $
              xtickvalues: xtickvalues, $
              ytickvalues: ytickvalues, $
              xtickname: xtickname, $
              ytickname: ytickname, $
              xstyle: 1, $
              ystyle: 1, $
              xtitle: "$\theta$ [deg]", $
              ytitle: "time [ms]", $
              xmajor: xmajor, $
              xminor: xminor, $
              ymajor: ymajor, $
              yminor: yminor, $
              xtickfont_size: 10.0, $
              ytickfont_size: 10.0, $
              xticklen: 0.02, $
              yticklen: 0.02/aspect_ratio, $
              xsubticklen: 0.5, $
              ysubticklen: 0.5, $
              xtickdir: 1, $
              ytickdir: 1, $
              font_size: 14, $
              font_name: "Times", $
              rgb_table: 13, $
              buffer: 1B}

     colorbar = {orientation: 1, $
                 title: "Power [dB]", $
                 textpos: 1, $
                 tickdir: 1, $
                 ticklen: 0.2, $
                 font_name: "Times", $
                 font_size: 14}
  endelse

  kw = create_struct('image',image,'colorbar',colorbar)
  return, kw
end

