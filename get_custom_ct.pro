;+
; Store custom color tables here.
;
; AVAILABLE TABLES:
; 0: red-white-blue + black at bottom
; 1: red-white-blue + black at bottom
; 2: black-red-green-blue-black
; 3: black-red-green-blue-white
;-
function get_custom_ct, number,count=count

  ;;==Build the list of available tables
  tables = list()
  tables.add, dictionary('i', [0,  1,128,255], $
                         'r', [0,  0,255,255], $
                         'g', [0,255,255,  0], $
                         'b', [0,  0,255,  0])
  tables.add, dictionary('i', [0,  1,128,255], $
                         'r', [0,  0,255,255], $
                         'g', [0,  0,255,  0], $
                         'b', [0,255,255,  0])
  tables.add, dictionary('i', [0, 64,128,192,255], $
                         'r', [0,  0,  0,255,  0], $
                         'g', [0,  0,255,  0,  0], $
                         'b', [0,255,  0,  0,  0])
  tables.add, dictionary('i', [0, 64,128,192,255], $
                         'r', [0,  0,  0,255,255], $
                         'g', [0,  0,255,  0,255], $
                         'b', [0,255,  0,  0,255])

  ;;==Return the number of available tables
  if keyword_set(count) then return, tables.count() $

  else begin
     ;;==Fill in the color-table dictionary
     ct = dictionary(['r','g','b'])
     ct.r = interpol(tables[number].r, tables[number].i, findgen(256))
     ct.g = interpol(tables[number].g, tables[number].i, findgen(256))
     ct.b = interpol(tables[number].b, tables[number].i, findgen(256))
  
     ;;==Return the requested color table as a struct
     return, ct.tostruct()
  endelse

end
