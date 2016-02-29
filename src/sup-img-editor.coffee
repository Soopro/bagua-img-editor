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
    crop_min_size: 32

  $img_editor = null
  $img_crop_area = null
  
  $current_dragging_corner = null
  
  IMG_EDITOR_ID = 'img-editor-id'
  IMG_CROP = 'img-crop-area'
  IMG_CORNER = 'img-crop-corner'
  IMG_CANVAS = 'img-editor-canvas'
  
  ORIENTATION = 
    'qian': 
      pos: [0, 0]
      drag: [1, 1]
    'kan': 
      pos: [0.5, 0]
      drag: [0, 1]
    'gen': 
      pos: [1, 0]
      drag: [-1, 1]
    'zhen': 
      pos: [1, 0.5]
      drag: [-1, 0]
    'xun': 
      pos: [1, 1]
      drag: [-1, -1]
    'li': 
      pos: [0.5, 1]
      drag: [0, -1]
    'kun': 
      pos: [0, 1]
      drag: [1, -1]
    'dui': 
      pos: [0, 0.5]
      drag: [1, 0]

  
  
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
    area_left = 0
    area_top = 0
    area_width = 0
    area_height = 0
    max_width = 0
    max_height = 0
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'
    
    for corner in corners
      corner.addEventListener 'mousedown', (e)->
        $current_dragging_corner = e.target
        start_x = e.clientX
        start_y = e.clientY
        area_left = parseInt($img_crop_area.style.left) or 0
        area_top = parseInt($img_crop_area.style.top) or 0
        area_width = $img_crop_area.offsetWidth
        area_height = $img_crop_area.offsetHeight
        max_width = $img_editor.clientWidth - area_left
        max_height = $img_editor.clientHeight - area_top
        
        document.addEventListener 'mousemove', dragging
        document.addEventListener 'mouseup', dragstop
        e.preventDefault()
        e.stopPropagation()
        
    dragging = (e)->
      return unless $img_crop_area
      
      move_x = e.clientX - start_x
      move_y = e.clientY - start_y

      ori = $current_dragging_corner.getAttribute(IMG_CORNER)
      dim = ORIENTATION[ori]
      
      move_x = move_x*dim.drag[0] if dim.drag[0]
      move_y = move_y*dim.drag[1] if dim.drag[1]

      top = min(
        max(area_top+move_y, 0),
        $img_editor.clientHeight-$options.crop_min_size
      )
      
      left = min(
        max(area_left+move_x, 0),
        $img_editor.clientWidth-$options.crop_min_size
      )
      width = max(area_width - left, $options.crop_min_size)
      height = max(area_height - top, $options.crop_min_size)

      if dim.drag[0]
        $img_crop_area.style.left = px(left) if dim.drag[0] > 0
        $img_crop_area.style.width = px(width)

      if dim.drag[1]
        $img_crop_area.style.top = px(top) if dim.drag[1] > 0
        $img_crop_area.style.height = px(height)

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
    crop.style.right = '0'
    crop.style.bottom = '0'
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
      corner.style.left = px(int(_width * dim.pos[0]) - corner_offset)
      corner.style.top = px(int(_height * dim.pos[1]) - corner_offset)

    
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