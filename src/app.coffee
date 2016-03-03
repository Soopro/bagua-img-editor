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
    $scope.img_data = null

    $scope.has_editor = ->
      Boolean(current_img_editor)
    
    $scope.capture = ->
      console.log current_img_editor
      if not current_img_editor
        return
      console.log current_img_editor
      $scope.img_data = current_img_editor.capture()
      
    clean_bagua = $rootScope.$on 'bagua.loaded', (e, img_editor)->
      current_img_editor = img_editor
      
    $scope.$on '$destroy', ->
      current_img_editor.destroy()
      clean_bagua()
]