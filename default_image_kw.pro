;+
; Script for setting default keywords for EPPIC image. 
;
; The purpose of this script is to save time when setting up graphics
; keywords in a new script and to ensure uniformity for certain
; keywords that don't need to change between data quantities.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
img_pos = [0.10,0.10,0.80,0.80]
clr_pos = [0.82,0.10,0.84,0.80]

image_kw = dictionary('axis_style', 1, $
                      'position', img_pos, $
                      'xmajor', 5, $
                      'xminor', 1, $
                      'ymajor', 5, $
                      'yminor', 1, $
                      'xstyle', 1, $
                      'ystyle', 1, $
                      'xsubticklen', 0.5, $
                      'ysubticklen', 0.5, $
                      'xtickdir', 1, $
                      'ytickdir', 1, $
                      'font_name', 'Times')
colorbar_kw = dictionary('orientation', 1, $
                         'textpos', 1, $
                         'font_name', 'Times', $
                         'position', clr_pos)
text_kw = dictionary('font_name', 'Times', $
                     'font_size', 24, $
                     'font_color', 'black', $
                     'normal', 1B, $
                     'alignment', 0.0, $
                     'vertical_alignment', 0.0, $
                     'fill_background', 1B, $
                     'fill_color', 'white')
