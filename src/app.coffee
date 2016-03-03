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
    $scope.img_percent = 0.5
    $scope.img_aspect = null
    
    $scope.has_editor = ->
      Boolean(current_img_editor)
    
    $scope.scale_capture = ->
      $scope.scale()
      $scope.capture()
    
    $scope.scale = ->
      if not current_img_editor
        return
      $scope.img_aspect = current_img_editor.scale($scope.img_percent)
      
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

    clean_bagua = $rootScope.$on 'bagua.loaded', (e, img_editor)->
      current_img_editor = img_editor
      $scope.img_aspect = img_editor.aspect()
      $scope.$apply()

    $scope.$on '$destroy', ->
      if current_img_editor
        current_img_editor.destroy()
      clean_bagua()
]