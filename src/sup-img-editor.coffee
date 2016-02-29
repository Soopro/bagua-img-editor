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
    start_x = null
    start_y = null
    
    area_left = 0
    area_top = 0
    area_width = 0
    area_height = 0
    
    $img_crop_area.addEventListener 'mousedown', (e)->
      start_y = e.clientY
      start_x = e.clientX
      area_left = parseInt($img_crop_area.style.left) or 0
      area_top = parseInt($img_crop_area.style.top) or 0
      area_width = $img_crop_area.clientWidth
      area_height = $img_crop_area.clientHeight
      console.log area_width
      document.addEventListener 'mousemove', dragging
      document.addEventListener 'mouseup', dragstop

    dragging = (e)->
      new_top = max(area_top + e.clientY - start_y, 0)
      new_left = max(area_left + e.clientX - start_x, 0)

      if (new_top + area_height) > $img_editor.clientHeight
        new_top = $img_editor.clientHeight - area_height
      
      if (new_left + area_width) > $img_editor.clientWidth
        new_left = $img_editor.clientWidth - area_width
      
      console.log area_width
      new_right = new_left + area_width
      new_bottom = new_top + area_height

      $img_crop_area.style.top = px(new_top)
      $img_crop_area.style.left = px(new_left)
      $img_crop_area.style.bottom = px(new_bottom)
      $img_crop_area.style.right = px(new_right)

    dragstop = (e)->
      document.removeEventListener 'mousemove', dragging
      document.removeEventListener 'mouseup', dragstop


  init_drag_corner_hanlders = ->
    start_x = null
    start_y = null
    area_left = 0
    area_top = 0
    area_bottom = 0
    area_right = 0
    
    max_width = 0
    max_height = 0
    
    current_corner = null
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'
    
    for corner in corners
      corner.addEventListener 'mousedown', (e)->
        current_corner = e.target
        start_x = e.clientX
        start_y = e.clientY
        area_left = parseInt($img_crop_area.style.left) or 0
        area_top = parseInt($img_crop_area.style.top) or 0
        area_bottom = parseInt($img_crop_area.style.bottom) or 0
        area_right = parseInt($img_crop_area.style.right) or 0
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

      ori = current_corner.getAttribute(IMG_CORNER)
      dim = ORIENTATION[ori]
      
      if ori == 'qian'
        left = between(area_left + move_x, 0, max_width)
        top = between(area_top + move_y, 0, max_height)
      else if ori == 'kan'
        top = between(area_top + move_y, 0, max_height)
      else if ori == 'gen'
        top = between(area_top + move_y, 0, max_height)
        right = between(area_right - move_x, 0, max_width)
      else if ori == 'zhen'
        right = between(area_right - move_x, 0, max_width)
      else if ori == 'xun'
        right = between(area_right - move_x, 0, max_width)
        bottom = between(area_bottom - move_y, 0, max_height)
      else if ori == 'li'
        bottom = between(area_bottom - move_y, 0, max_height)
      else if ori == 'kun'
        left = between(area_left + move_x, 0, max_width)
        bottom = between(area_bottom - move_y, 0, max_height)
      else if ori == 'dui'
        left = between(area_left + move_x, 0, max_width)

      $img_crop_area.style.left = px(left) if left
      $img_crop_area.style.top = px(top) if top
      $img_crop_area.style.bottom = px(bottom) if bottom
      $img_crop_area.style.right = px(right) if right
      
      # top = min(
      #   max(area_top+move_y, 0),
      #   $img_editor.clientHeight-$options.crop_min_size
      # )
      #
      # left = min(
      #   max(area_left+move_x, 0),
      #   $img_editor.clientWidth-$options.crop_min_size
      # )
      # width = max(max_width - left, $options.crop_min_size)
      # height = max(max_height - top, $options.crop_min_size)
      #
      # if dim.drag[0]
      #   $img_crop_area.style.left = px(left) if dim.drag[0] > 0
      #   # $img_crop_area.style.width = px(width)
      #
      # if dim.drag[1]
      #   $img_crop_area.style.top = px(top) if dim.drag[1] > 0
      #   # $img_crop_area.style.height = px(height)

      pos_crop_area()
      
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
    pos_crop_area()
    
    
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
  
  pos_crop_area = ->
    _width = $img_crop_area.clientWidth
    _height = $img_crop_area.clientHeight
    corner_offset = int($options.corner_size / 2)
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'
    for corner in corners
      ori = corner.getAttribute(IMG_CORNER)
      dim = ORIENTATION[ori]
      corner.style.left = px(int(_width * dim.pos[0]) - corner_offset)
      corner.style.top = px(int(_height * dim.pos[1]) - corner_offset)
    
    left = parseInt($img_crop_area.style.left)
    right = parseInt($img_crop_area.style.right)
    top = parseInt($img_crop_area.style.top)
    bottom = parseInt($img_crop_area.style.bottom)
    $img_crop_area.style.width = px($img_editor.clientWidth - left - right)
    $img_crop_area.style.height = px($img_editor.clientHeight - top - bottom)
    
    
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

between = (number, min_number, max_number)->
  return min(max(number, min_number), max_number)

unless root.supImageEditor
  root.supImageEditor = supImageEditor