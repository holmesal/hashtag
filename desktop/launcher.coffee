semver = require 'semver'
request = require 'request'

repoOwner = 'reactiveui'
repoName = 'reactiveui'
{EventEmitter} = require 'events'

# Go check for the latest release
# alert 'omg alive'

# Get the version of the current release

class Launcher extends EventEmitter

  info: (stuff) ->
    console.info stuff
    p = document.createElement 'p'
    p.innerHTML = stuff
    document.body.appendChild p

  constructor: ->

    # This event basically means go run the app
    @on 'continue', (timeout) ->
      unless timeout
        timeout = 0
      # Load the existing app
      setTimeout ->
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
    catch err
      # console.error err
      @info "Current version does not exist, so this must be the first run."
      @currentVersion = 'v0.0.0'

  getLatestVersion: ->
    @info 'getting latest version from github...'
    request 
      url: "https://api.github.com/repos/#{repoOwner}/#{repoName}/releases"
      json: true
      headers: 
        'User-Agent': 'Shortwave'
        'Accept': 'application/vnd.github.v3+json'
    , (err, res, body) =>
      unless err or res.statusCode isnt 200
        latestRelease = body[0]
        @info 'got release from github!'
        console.log latestRelease
        @latestVersion = latestRelease.tag_name
        # If newer, start updateing
        @info "checking if #{@latestVersion} > #{@currentVersion}"
        if semver.gt @latestVersion, @currentVersion
          @info 'got newer version, downloading'
          @download latestRelease.assets_url
        else
          @info 'currently running newest version, skipping'
      else
        # TODO - catch no-internet errors here
        @info "error getting latest release from github"
        console.error err
        @info "status: #{res?.statusCode}"
        @emit 'continue', 5000

  download: (asset_url) ->
    @info "would be downloading here"
    @emit 'continue', 2000


new Launcher