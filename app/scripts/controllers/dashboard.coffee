'use strict'

###*
 # @ngdoc function
 # @name shortwaveApp.controller:DashboardCtrl
 # @description
 # # DashboardCtrl
 # Controller of the shortwaveApp
###
angular.module('shortwaveApp')
  .controller 'DashboardCtrl', ($scope, $rootScope, $timeout, $filter, $firebase, $firebaseSimpleLogin, $location, user, User, Channels, ChannelUtils, Message, $upload) ->

    # Store a reference to the s3 queue
    s3QueueRef = $rootScope.rootRef.child 's3Queue'
    # Location of the s3 bucket
    bucketUrl = 'https://wavelength-bucket.s3.amazonaws.com'

    # Responsible for switching the channel on the directives
    $rootScope.$on 'updateChannel', (ev, newChannel) =>
      # Set the new channel in firebase
      ChannelUtils.setViewing newChannel
      # Change the channel
      $scope.currentChannel = newChannel
      # Focus on the text input
      $scope.focusInput()

    $scope.showCreate = ->
      $scope.createVisible = true

    $scope.hideCreate = ->
      $scope.createVisible = false

    $scope.logout = ->
      auth = new FirebaseSimpleLogin $rootScope.rootRef, (err) ->
        alert 'logged out'
      auth.logout()

      $location.path '/'

    $scope.focusInput = ->
      $timeout -> $rootScope.$broadcast 'focusOn', 'compose'



    # Init

    # Focus on the compose bar when the controller loads
    $scope.focusInput()

    # Object to handle file uploads
    $scope.uploads = {}


    # Handle file selects
    $scope.onFileSelect = (files) ->

      console.log 'files selected!', files

      for file in files
        # Get an upload request for this file
        requestUpload file

    requestUpload = (file) ->
      requestRef = s3QueueRef.child('request').push()
      console.log "the owner is #{User.user.$id}"
      requestRef.set
        owner: User.user.$id 
      console.log "made request for #{file.name}"
      # Listen for the response
      resultRef = s3QueueRef.child "result/#{requestRef.name()}"
      resultRef.on 'value', (snap) =>
        if snap.val()
          console.info "got policy for #{file.name} back from server", snap.val()
          # Stop listening to this result ref
          resultRef.off()

          # Upload the file
          uploadFile snap.name(), file, snap.val()

    uploadFile = (id, file, policy) ->
      $upload.upload
        url: bucketUrl
        method: 'POST'
        data:
          key: id
          AWSAccessKeyId: 'AKIAJWLORAVT7M4V7IJA'
          acl: 'public-read'
          policy: policy.policy
          signature: policy.signature
          "Content-Type": file.type or 'application/octet-stream'
          "Content-Length": file.size
          filename: file.name
        file: file
      .progress (ev) ->
        # Update the progress object
        console.log "progress for #{id}: #{ev.loaded/ev.total}"
        $scope.uploads[id] = (ev.loaded/ev.total) * 100
      .success (data, status) ->
        # Clear the progress object
        delete $scope.uploads[id]
        console.log 'upload success', data, status
        console.log "checking type #{file.type}"
        # Build the path
        url = "#{bucketUrl}/#{id}"
        # Depending on the type of the file, send an appropriate message
        if file.type.indexOf('image') isnt -1
          # Send an image type message
          Message.image url, $scope.currentChannel
        else
          console.error 'unknown type'
          # Send a url type message
          Message.text url, $scope.currentChannel

      .error (data) ->
        console.error 'upload error', data
            
        # $scope.uploader.uploadAll()


    # # Initialize the uploader
    # imgur = '5ee37787905afcd'
    # $scope.uploader = new FileUploader
    #   url: 'https://api.imgur.com/3/image'
    #   method: 'POST'

    #   headers:
    #     'Authorization': "Client-ID #{imgur}"
    #   autoUpload: true
    #   alias: 'image'

    # # Only accept images
    # $scope.uploader.filters.push
    #   name: 'imageFilter'
    #   fn: (item, opts) ->
    #     type =  item.type.slice(item.type.lastIndexOf('/') + 1)
    #     type in ['jpg','png','jpg','jpeg','bmp','gif']

    # # Callbacks
    # $scope.uploader.onWhenAddingFileFailed = (item, filter, options) ->
    #   console.error 'error adding file', item, filter, options

    # $scope.uploader.onAfterAddingFile = (fileItem) ->
    #   # Make a request for an s3 policy
    #   requestRef = s3QueueRef.child('request').push()
    #   console.log "the owner is #{User.user.$id}"
    #   requestRef.set
    #     owner: User.user.$id 
    #   # Listen for the response
    #   resultRef = s3QueueRef.child "result/#{requestRef.name()}"
    #   resultRef.on 'value', (snap) ->
    #     if snap.val()
    #       console.info 'got policy back from server', snap.val()
    #       resultRef.off()
    #       console.log 'should be uploading here', fileItem
    #   # $scope.uploader.uploadAll()

    # # $scope.uploader.onBeforeUploadItem = (fileItem) ->
    # #   console.log 'preparing to upload item', fileItem

    # # $scope.uploader.onProgressItem = (fileItem, progress) ->
    # #   console.log 'got progess for item', fileItem, progress

    # $scope.uploader.onProgressAll = (progress) ->
    #   console.info "upload progress: #{progress}"


    # $scope.uploader.onSuccessItem = (fileItem, res, status, headers) ->
    #   console.info 'successfully uploaded item - sending message'
    #   # File upload was a success, post an image message with this url
    #   Message.text res.data.link, $scope.currentChannel

    # $scope.uploader.onErrorItem = (fileItem, res, status, headers) ->
    #   console.error 'error uploading item', fileItem, res, status, headers

    # # $scope.uploader.onCompleteItem = (fileItem, res, status, headers) ->
    # #   console.log 'finished uploading item', fileItem, res, status, headers

    # $scope.uploader.onCompleteAll = ->
    #   console.info 'all uploads done'



    # Handle user pastes
    $scope.paste = (ev) ->
      # Get the pasted items
      items = ev.clipboardData or ev.originalEvent.clipboardData.items
      console.info 'user pasted something', JSON.stringify items

      for item in items
        if item.type in ['image/png','image/jpeg','image/gif']
          console.info 'uploading user-pasted image'
          blob = items[0].getAsFile()

          # Make a new file uploader item with this data
          $scope.uploader.addToQueue blob
