# ------------------------------->
# Sup Image Editor
#
# Author : Redy Ru
# Email : redy.ru@gmail.com
# License : MIT
# Description: A Image Editor for resize and crop images.

# ---- Usage ----
# On your html create a editor:
# <div sup-image-editor></div>
# ------------------------------->

is_exports = typeof exports isnt "undefined" and exports isnt null
root = if is_exports then exports else this



supImageEditor = ->
# ---------------- Variables --------------
  ver = '0.1.0'
  now = Date.now()
  
  $options = 
    corner_size: 16
    crop_min_size: 64

  $img_editor = null
  $img_crop_area = null
  
  $current_dragging_corner = null
  
  IMG_EDITOR_ID = 'img-editor-id'
  IMG_CROP = 'img-crop-area'
  IMG_CORNER = 'img-crop-corner'
  IMG_CANVAS = 'img-editor-canvas'
  
  ORIENTATION = 
    'qian': [0,0]
    'kan': [0.5,0]
    'gen': [1,0]
    'zhen': [1,0.5]
    'xun': [1,1]
    'li': [0.5,1]
    'kun': [0,1]
    'dui': [0,0.5]

  
  
# ---------------- Handlers --------------

  init_crop_area_hanlder = ->
    startTop = null
    startLeft = null
    start_x = null
    start_y = null

    $img_crop_area.addEventListener 'mousedown', (e)->
      start_y = e.clientY
      start_x = e.clientX
      startTop = parseInt($img_crop_area.style.top) or 0
      startLeft = parseInt($img_crop_area.style.left) or 0
      document.addEventListener 'mousemove', dragging
      document.addEventListener 'mouseup', dragstop

    dragging = (e)->
      new_top = max(startTop + e.clientY - start_y, 0)
      new_left = max(startLeft + e.clientX - start_x, 0)
      if (new_top + $img_crop_area.clientHeight) > $img_editor.clientHeight
        new_top = $img_editor.clientHeight - $img_crop_area.clientHeight

      if (new_left + $img_crop_area.clientWidth) > $img_editor.clientWidth
        new_left = $img_editor.clientWidth - $img_crop_area.clientWidth

      $img_crop_area.style.top = px(new_top)
      $img_crop_area.style.left = px(new_left)

    dragstop = (e)->
      document.removeEventListener 'mousemove', dragging
      document.removeEventListener 'mouseup', dragstop


  init_drag_corner_hanlders = ->
    startWidth = null
    startHeight = null
    start_x = null
    start_y = null
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'
    
    for corner in corners
      corner.addEventListener 'mousedown', (e)->
        $current_dragging_corner = corner
        start_x = e.clientX
        start_y = e.clientY
        startWidth = $img_crop_area.clientWidth or 10
        startHeight = $img_crop_area.clientHeight or 10
        document.addEventListener 'mousemove', dragging
        document.addEventListener 'mouseup', dragstop
        e.preventDefault()
        e.stopPropagation()
        
    dragging = (e)->
      return unless $img_crop_area
      limit_left = parseInt($img_crop_area.style.left) or 0
      limit_top = parseInt($img_crop_area.style.top) or 0
      new_width = min(startWidth + e.clientX - start_x,
                      $img_editor.clientWidth - limit_left)
      new_height = min(startHeight + e.clientY - start_y,
                       $img_editor.clientHeight- limit_top)
      $img_crop_area.style.width = px(max(new_width, $options.crop_min_size))
      $img_crop_area.style.height = px(max(new_height, $options.crop_min_size))
      pos_corners()
      e.preventDefault()
      e.stopPropagation()
      
    dragstop = (e)->
      document.removeEventListener 'mousemove', dragging
      document.removeEventListener 'mouseup', dragstop
      e.preventDefault()
      e.stopPropagation()

# ---------------- Functions --------------
  init = (editor, opt)->
    
    if typeof editor is 'string'
      $img_editor = document.querySelector('[name='+ editor + ']')
    else if isHTMLElement(editor)
      $img_editor = editor
    
    if not $img_editor
      console.error 'Init image editor failed!!'
      return
    
    if typeof opt is "object"
      for k,v of opt
        $options[k] = v
    
    $img_editor.setAttribute(IMG_EDITOR_ID, now)
    $img_crop_area = set_crop($img_editor)
    init_drag_corner_hanlders()
    init_crop_area_hanlder()
    pos_corners()
    
    
  set_crop = (img_editor)->
    crop = document.createElement('DIV')
    crop.setAttribute(IMG_CROP, now)
    crop.style.position = 'absolute'
    crop.style.top = '0'
    crop.style.left = '0'
    crop.style.width = '100%'
    crop.style.height = '100%'
    crop.style.backgroundColor = 'green'
    img_editor.appendChild(crop)

    for ori,dim of ORIENTATION
      corner = document.createElement('DIV')
      corner.setAttribute(IMG_CORNER, ori)
      corner.style.position = 'absolute'
      corner.style.width = px($options.corner_size)
      corner.style.height = px($options.corner_size)
      corner.style.cursor = 'pointer'
      corner.style.backgroundColor = 'blue'
      crop.appendChild(corner)
  
    return crop
  
  pos_corners = ->
    _width = $img_crop_area.clientWidth
    _height = $img_crop_area.clientHeight
    corner_offset = int($options.corner_size / 2)
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'
    for corner in corners
      ori = corner.getAttribute(IMG_CORNER)
      dim = ORIENTATION[ori]
      corner.style.left = px(int(_width * dim[0]) - corner_offset)
      corner.style.top = px(int(_height * dim[1]) - corner_offset)

    
  output = 
    init: init
  
  return output
    

isHTMLElement = (o) ->
  if not o
    return false
  is_obj = o and typeof o == 'object' and o != null
  is_obj_type = o.nodeType is 1 and typeof o.nodeName is 'string'
  result =  is_obj and is_obj_type
  return result

int = (number, ceil)->
  if not ceil
    return Math.floor(number)
  else
    return Math.ceil(number)

px = (number)->
  if typeof number is 'number'
    return number+'px'
  else
    return number

max = (number1, number2)->
  if number1 > number2
    return number1
  else
    return number2

min = (number1, number2)->
  if number1 < number2
    return number1
  else
    return number2
    
unless root.supImageEditor
  root.supImageEditor = supImageEditor