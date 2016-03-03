# ---------------------------------------
# For testing
# ---------------------------------------

angular.module 'App', [
  'baguaImageEditor'
]
.controller "appCtrl", [
  '$scope'
  '$rootScope'
  (
    $scope
    $rootScope
  ) ->
    current_img_editor = null
    $scope.img_src = null
    $scope.img_percent = 1
    $scope.img_aspect = null
    $scope.img_url = 'sample.png'
    
    $scope.switch = ->
      urls = [
        'sample.png',
        'sample_small.gif',
        'sample_long.jpg',
        'sample_larger.jpg'
      ]
      idx = urls.indexOf($scope.img_url)
      urls.splice(idx, 1)
      src_url = urls[Math.floor(Math.random()*urls.length)]
      $scope.img_url = src_url

    $scope.has_editor = ->
      Boolean(current_img_editor)
    
    $scope.scale_capture = ->
      $scope.scale()
      $scope.capture()

    $scope.scale = ->
      if not current_img_editor
        return
      $scope.img_aspect = current_img_editor.scale($scope.img_percent)
      $scope.img_percent = $scope.img_aspect.ratio
      
    $scope.capture = ->
      if not current_img_editor
        return
      dataurl = current_img_editor.capture()
      $scope.img_src = dataurl
      media = 
        name: 'sample.jpg'
        lastModified: new Date()
        lastModifiedDate: new Date()
      new_media = current_img_editor.blob(media, dataurl)
      console.log new_media

    clean_bagua = $rootScope.$on 'bagua.loaded', (e, img_editor, reload)->
      current_img_editor = img_editor
      $scope.img_aspect = img_editor.aspect()
      $scope.$apply()

    $scope.$on '$destroy', ->
      current_img_editor.destroy() if current_img_editor
      clean_bagua() if clean_bagua
]