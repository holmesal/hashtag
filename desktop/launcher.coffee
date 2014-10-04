semver = require 'semver'
request = require 'request'

repoOwner = 'reactiveui'
repoName = 'reactiveui'
{EventEmitter} = require 'events'

rm = require 'rimraf'
mv = require 'mv'
fs = require 'fs'
AdmZip = require 'adm-zip'

bucket = 'https://shortwave-releases.s3-us-west-1.amazonaws.com'

# Go check for the latest release
# alert 'omg alive'

# Get the version of the current release

class Launcher extends EventEmitter

  info: (stuff) ->
    console.info stuff
    if document?
      p = document.createElement 'p'
      p.innerHTML = stuff
      document.body.appendChild p

  constructor: ->

    # This event basically means go run the app
    @on 'continue', (timeout) ->
      unless timeout
        timeout = 0
      # Load the existing app
      setTimeout =>
        @info 'launching...'
        if window?
          window.location = "app://localhost/dist/index.html"
      , timeout

    # Get the current version
    @getCurrentVersion()

    # Get the newest remote version
    @getLatestVersion()

  getCurrentVersion: ->
    try
      pjson = require "./dist/package.json"
      @currentVersion = pjson.version
      @info "build #{@currentVersion}"
    catch err
      # console.error err
      @info "Current version does not exist, so this must be the first run."
      @currentVersion = 'v0.0.0'

  getLatestVersion: ->
    @info "getting latest version number..."
    request 
      url: "#{bucket}/package.json"
      json: true
    , (err, res, pack) =>
      unless err or res.statusCode isnt 200
        # This is the package.json
        @latestVersion = pack.version
        # latestRelease = body[0]
        @info 'got latest version!'
        # console.log latestVersion
        # @latestVersion = latestRelease.tag_name
        # If newer, start updateing
        # @info "checking if #{@latestVersion} > #{@currentVersion}"
        if semver.gt @latestVersion, @currentVersion
          @info "downloading #{@latestVersion}"
          @download()
        else
          @info 'currently running newest version, skipping'
          @emit 'continue', 3000
      else
        # TODO - catch no-internet errors here
        @info "error getting latest version number"
        console.error err
        @info "status: #{res?.statusCode}"
        @emit 'continue', 5000


  download: ->
    url = "#{bucket}/dist.zip"

    # Remove any existing zip file
    rm 'dist.zip', =>
      # Download the new zip file
      stream = fs.createWriteStream 'dist.zip'
      request.get url
      .pipe stream

      # @unpack()

      stream.on 'close', =>
        @info 'stream closed!'
        @info 'finished downloading!'
        # verify this zip, then unpack it
        @prepare()

  prepare: ->
    @info "preparing to unpack..."

    try
      @zip = new AdmZip 'dist.zip'

      # Move the current dist folder to a backup
      # Delete any existing backups
      rm 'backup', =>
        # Does the dist folder already exist?
        fs.exists 'dist', (exists) =>
          if exists
            # Move stuff
            mv 'dist', 'backup', 
              mkdirp: true
            , (err) =>
              throw new Error err if err 
              @info 'dist/ was moved to backup/'
              @unpack()
          else
            # Unpack right away
            @unpack()

      # entries = zip.getEntries()

      # for entry in entries
      #   @info entry.toString()
    catch
      @info 'error - bad zip! aborting update...'
      @emit 'continue', 5000

  unpack: ->
    @info "unpacking zip..."
    # Wow, I hope this is synchronous
    @zip.extractAllTo 'dist', true # overwrite any existing
    # Go!
    @info "unpacked!"
    @info fs.readdirSync 'dist'
    @emit 'continue', 3000


new Launcher