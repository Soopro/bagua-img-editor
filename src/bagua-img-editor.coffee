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
  project_name = 'BaguaImgEditor'
  ver = '0.1.0'
  now = Date.now()

  $options = 
    corner_size: 16
    crop_min_size: 32

  $img_editor = null
  $img_canvas = null
  $img_crop_area = null
  $current_corner = null
  
  IMG_EDITOR_ID = 'img-editor-id'
  IMG_CROP = 'img-crop-area'
  IMG_CANVAS = 'img-cavnas'
  IMG_CORNER = 'img-crop-corner'
  IMG_CANVAS = 'img-editor-canvas'
  
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
      
      pos_crop_area(false)
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
    $img_canvas = set_canvas($img_editor)
    $img_bg_canvas = set_canvas($img_editor)
    $img_crop_area = set_crop($img_editor)

    init_drag_corner_hanlders()
    init_crop_area_hanlder()
    pos_crop_area()
  
  set_canvas = (img_editor)->
    canvas = document.createElement('CANVAS')
    canvas.setAttribute(IMG_CANVAS, now)
    canvas.style.position = 'absolute'
    canvas.style.width = '100%'
    canvas.style.height = '100%'
    img_editor.appendChild(canvas)

    
  set_crop = (img_editor)->
    crop = document.createElement('DIV')
    crop.setAttribute(IMG_CROP, now)
    crop.style.position = 'absolute'
    crop.style.top = '0'
    crop.style.left = '0'
    crop.style.right = '0'
    crop.style.bottom = '0'
    crop.style.backgroundColor = 'green'
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
  
  load_to_canvas = (canvas, image, grayscale)->
    canvasContext = canvas.getContext('2d')
    pos_x = canvas.width - image.width
    pos_y = canvas.height - image.height
    canvasContext.drawImage(image, pos_x, pos_y)
    
    if not grayscale
      return
      img_pixels = canvasContext.getImageData(0, 0, image.width, image.height)
      while y < imageData.height
        while x < imageData.width
          i = y * 4 * imgPixels.width + x * 4
          rgb = (imgPixels.data[i]+imgPixels.data[i+1]+imgPixels.data[i+2])
          avg = rgb / 3
          imgPixels.data[i] = avg
          imgPixels.data[i + 1] = avg
          imgPixels.data[i + 2] = avg
          x++
        y++
      canvasContext.putImageData(
        img_pixels, 0, 0, 0, 0, img_pixels.width, img_pixels.height
      )

    return canvas.toDataURL()
    
  load = (image)->
    if typeof image is 'string'
      image = document.querySelector(image)
    else if not isHTMLElement(image)
      throw project_name+': Invalid image!'
    
  
  # ---------------- Output --------------

  output = 
    init: init
  
  return output
    
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
  if root.getComputedStyle
    return root.getComputedStyle(element, pseudo)
  if element.currentStyle
    return element.currentStyle

unless root.supImageEditor
  root.supImageEditor = supImageEditor