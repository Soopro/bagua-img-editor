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

# ---------------------------------------
# Utils
# ---------------------------------------

isHTMLElement = (o) ->
  if not o
    return false
  is_obj = o and typeof o == 'object' and o != null
  is_obj_type = o.nodeType is 1 and typeof o.nodeName is 'string'
  result =  is_obj and is_obj_type
  return result

int = (number, type)->
  if type == 'ceil' or type == -1
    return Math.ceil(number)
  else if type == 'floor' or type == 1
    return Math.floor(number)
  try
    return Math.round(number)
  catch
    parseInt(number)

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


getStyleSheet = (element, pseudo)->
  if window.getComputedStyle
    return window.getComputedStyle(element, pseudo)
  if element.currentStyle
    return element.currentStyle

# ---------------------------------------
# Module
# ---------------------------------------

baguaImageEditor = ->
  # ---------------- Variables --------------
  project_name = 'BaguaImgEditor'
  ver = '0.1.0'
  now = Date.now()

  $options = 
    corner_size: 16
    crop_min_size: 32
  
  $reisze_timer_id = null
  
  $current_img = null
  $current_corner = null
  
  $img_editor = null
  $img_crop_area = null
  
  
  IMG_EDITOR_ID = 'img-editor-id'
  IMG_CROP = 'img-crop-area'
  IMG_CORNER = 'img-crop-corner'
  IMG_CANVAS = 'img-editor-canvas'
  IMG_CANVAS_BG = 'img-editor-cavnas-bg'
  
  ORIENTATION = 
    'qian': 
      pos: [0, 0]
    'kan': 
      pos: [0.5, 0]
    'gen': 
      pos: [1, 0]
    'zhen': 
      pos: [1, 0.5]
    'xun': 
      pos: [1, 1]
    'li': 
      pos: [0.5, 1]
    'kun': 
      pos: [0, 1]
    'dui': 
      pos: [0, 0.5]
 
  
# ---------------- Handlers --------------

  init_crop_area_hanlder = ->
    start_x = null
    start_y = null
    
    area_left = 0
    area_top = 0
    area_bottom = 0
    area_right = 0
    
    area_width = 0
    area_height = 0
    
    $img_crop_area.addEventListener 'mousedown', (e)->
      if $current_corner
        return
      start_y = e.clientY
      start_x = e.clientX

      area_left = parseInt($img_crop_area.style.left) or 0
      area_top = parseInt($img_crop_area.style.top) or 0
      area_bottom = parseInt($img_crop_area.style.bottom) or 0
      area_right = parseInt($img_crop_area.style.right) or 0
      
      area_width = parseInt($img_crop_area.style.width)
      area_height = parseInt($img_crop_area.style.height)

      document.addEventListener 'mousemove', dragging
      document.addEventListener 'mouseup', dragstop
      e.preventDefault()
      e.stopPropagation()
      
    dragging = (e)->
      new_top = max(area_top + e.clientY - start_y, 0)
      new_left = max(area_left + e.clientX - start_x, 0)
      new_right = max($img_editor.clientWidth - new_left - area_width, 0)
      new_bottom = max($img_editor.clientHeight - new_top - area_height, 0)

      if (new_top + area_height) > $img_editor.clientHeight
        new_top = $img_editor.clientHeight - area_height
      
      if (new_left + area_width) > $img_editor.clientWidth
        new_left = $img_editor.clientWidth - area_width
      
      
      $img_crop_area.style.top = px(new_top)
      $img_crop_area.style.left = px(new_left)
      $img_crop_area.style.right = px(new_right)
      $img_crop_area.style.bottom = px(new_bottom)
      
      pos_crop_area()
      e.preventDefault()
      e.stopPropagation()
      
    dragstop = (e)->
      document.removeEventListener 'mousemove', dragging
      document.removeEventListener 'mouseup', dragstop
      e.preventDefault()
      e.stopPropagation()

  init_drag_corner_hanlders = ->
    start_x = null
    start_y = null
    
    area_left = 0
    area_top = 0
    area_bottom = 0
    area_right = 0
    
    limit_left = 0
    limit_top = 0
    limit_right = 0
    limit_bottom = 0
    
    max_width = 0
    max_height = 0
    
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'
    
    for corner in corners
      corner.addEventListener 'mousedown', (e)->
        if not e.target.hasAttribute(IMG_CORNER)
          return
        $current_corner = e.target
        start_x = e.clientX
        start_y = e.clientY
        area_left = parseInt($img_crop_area.style.left) or 0
        area_top = parseInt($img_crop_area.style.top) or 0
        area_bottom = parseInt($img_crop_area.style.bottom) or 0
        area_right = parseInt($img_crop_area.style.right) or 0
        
        max_width = $img_editor.clientWidth
        max_height = $img_editor.clientHeight
        
        min_size = $options.crop_min_size
        
        limit_left = max_width-area_right-min_size
        limit_right = max_width-area_left-min_size
        limit_top = max_height-area_bottom-min_size
        limit_bottom = max_height-area_top-min_size
        
        document.addEventListener 'mousemove', dragging
        document.addEventListener 'mouseup', dragstop
        e.preventDefault()
        e.stopPropagation()
        
    dragging = (e)->
      return unless $img_crop_area
      
      move_x = e.clientX - start_x
      move_y = e.clientY - start_y

      ori = $current_corner.getAttribute(IMG_CORNER)

      top = null
      left = null
      right = null
      bottom = null
      
      if ori == 'qian'
        left = between(area_left + move_x, 0, limit_left)
        top = between(area_top + move_y, 0, limit_top)
      else if ori == 'kan'
        top = between(area_top + move_y, 0, limit_top)
      else if ori == 'gen'
        top = between(area_top + move_y, 0, limit_top)
        right = between(area_right - move_x, 0, limit_right)
      else if ori == 'zhen'
        right = between(area_right - move_x, 0, limit_right)
      else if ori == 'xun'
        right = between(area_right - move_x, 0, limit_right)
        bottom = between(area_bottom - move_y, 0, limit_bottom)
      else if ori == 'li'
        bottom = between(area_bottom - move_y, 0, limit_bottom)
      else if ori == 'kun'
        left = between(area_left + move_x, 0, limit_left)
        bottom = between(area_bottom - move_y, 0, limit_bottom)
      else if ori == 'dui'
        left = between(area_left + move_x, 0, limit_left)
      
      $img_crop_area.style.left = px(left) if left isnt null
      $img_crop_area.style.top = px(top) if top isnt null
      $img_crop_area.style.bottom = px(bottom) if bottom isnt null
      $img_crop_area.style.right = px(right) if right isnt null

      pos_crop_area()
      
      e.preventDefault()
      e.stopPropagation()
      
    dragstop = (e)->
      $current_corner = null
      document.removeEventListener 'mousemove', dragging
      document.removeEventListener 'mouseup', dragstop
      e.preventDefault()
      e.stopPropagation()

  resize_handler = (e)->
    pos_crop_area()
    # window.clearTimeout($reisze_timer_id) if $reisze_timer_id
    # $reisze_timer_id = window.setTimeout ->
    #   $img_canvas.style.visibility = ''
    #   $img_canvas_bg.style.visibility = ''
    #   window.clearTimeout($reisze_timer_id)
    # , 500
    

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
    $img_editor.style.maxWidth = "100%"
    $img_editor.style.maxHeight = "100%"
    $img_editor.style.fontSize = 0
    $current_img = set_image($img_editor)
    window.addEventListener('resize', resize_handler) if window
    
  set_image = (img_editor)->
    image = document.createElement('img')
    image.style.maxWidth = '100%'
    image.style.maxHeight = '100%'
    image.style.pointerEvents = 'none'
    image.style.zoom = 1
    image.style.opacity = 0.5
    image.style.zIndex = 1
    img_editor.appendChild(image)
    return image
    
  set_crop = (img_editor, curr_img)->
    crop = document.createElement('DIV')
    crop.setAttribute(IMG_CROP, now)
    crop.style.position = 'absolute'
    crop.style.top = '0'
    crop.style.left = '0'
    crop.style.right = '0'
    crop.style.bottom = '0'
    crop.style.zIndex = 99
    img_editor.appendChild(crop)

    index = 0
    for ori,dim of ORIENTATION
      corner = document.createElement('DIV')
      corner.setAttribute(IMG_CORNER, ori)
      corner.style.position = 'absolute'
      corner.style.width = px($options.corner_size)
      corner.style.height = px($options.corner_size)
      corner.style.cursor = 'pointer'
      corner.style.zIndex = 99-index
      corner.style.backgroundColor = 'blue'
      crop.appendChild(corner)
      index++
  
    return crop

  
  pos_crop_area = ->
    corner_offset = int($options.corner_size / 2)
    corners = $img_crop_area.querySelectorAll '['+IMG_CORNER+']'

    left = parseInt($img_crop_area.style.left) or 0
    right = parseInt($img_crop_area.style.right) or 0
    top = parseInt($img_crop_area.style.top) or 0
    bottom = parseInt($img_crop_area.style.bottom) or 0
    
    width = $img_editor.clientWidth-left-right
    height = $img_editor.clientHeight-top-bottom
    $img_crop_area.style.width = px(width)
    $img_crop_area.style.height = px(height)
    
    for corner in corners
      ori = corner.getAttribute(IMG_CORNER)
      dim = ORIENTATION[ori]
      corner.style.left = px(int(width * dim.pos[0]) - corner_offset)
      corner.style.top = px(int(height * dim.pos[1]) - corner_offset)
    return
    
  load = (img_src)->
    if not $img_editor
      throw project_name+': Image Editor not inited!'

    if typeof img_src isnt 'string'
      throw project_name+': Invalid image!'
  
    $current_img.src = img_src
    $current_img.onload = (e)->
      $img_crop_area = set_crop($img_editor, $current_img)
      init_drag_corner_hanlders()
      init_crop_area_hanlder()
      pos_crop_area()


  # ---------------- Output --------------

  output = 
    init: init
    load: load
  
  return output
    


unless window.baguaImageEditor
  window.baguaImageEditor = baguaImageEditor