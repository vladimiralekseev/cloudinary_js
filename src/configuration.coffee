((root, factory) ->
  if (typeof define == 'function') && define.amd
    define ['util-lodash'],factory
  else if typeof exports == 'object'
    module.exports = factory(require('util-lodash'))
  else
    root.cloudinary ||= {}
    root.cloudinary.Configuration = factory(Util)

)(this,  (Util)->
  ###*
   * Cloudinary configuration class
  ###
  class Configuration

    ###*
    * Defaults configuration.
    * @const {object} Configuration.DEFAULT_CONFIGURATION_PARAMS
    ###
    DEFAULT_CONFIGURATION_PARAMS ={
      secure: window?.location?.protocol == 'https:'
    }

    @CONFIG_PARAMS = [
      "api_key"
      "api_secret"
      "cdn_subdomain"
      "cloud_name"
      "cname"
      "private_cdn"
      "protocol"
      "resource_type"
      "responsive_width"
      "secure"
      "secure_cdn_subdomain"
      "secure_distribution"
      "shorten"
      "type"
      "url_suffix"
      "use_root_path"
      "version"
    ]
    ###*
     * Cloudinary configuration class
     * @constructor Configuration
     * @param {object} options - configuration parameters
    ###
    constructor: (options ={})->
      @configuration = Util.cloneDeep(options)
      Util.defaults( @configuration, DEFAULT_CONFIGURATION_PARAMS)

    ###*
     * Initialize the configuration.
     * The function first tries to retrieve the configuration form the environment and then from the document.
     * @function Configuration#init
     * @return {Configuration} returns this for chaining
     * @see fromDocument
     * @see fromEnvironment
    ###
    init: ()->
      @fromEnvironment()
      @fromDocument()
      @

    ###*
     * Set a new configuration item
     * @function Configuration#set
     * @param {String} name - the name of the item to set
     * @param {*} value - the value to be set
     * @return {Configuration}
     *
    ###
    set:(name, value)->
      @configuration[name] = value
      this

    ###*
     * Get the value of a configuration item
     * @function Configuration#get
     * @param {string} name - the name of the item to set
     * @return {*} the configuration item
    ###
    get: (name)->
      @configuration[name]

    merge: (config={})->
      Util.assign(@configuration, Util.cloneDeep(config))
      this

    ###*
     * Initialize Cloudinary from HTML meta tags.
     * @function Configuration#fromDocument
     * @return {Configuration}
     * @example <meta name="cloudinary_cloud_name" content="mycloud">
     *
    ###
    fromDocument: ->
      meta_elements = document?.querySelectorAll('meta[name^="cloudinary_"]');
      if meta_elements
        for el in meta_elements
          @configuration[el.getAttribute('name').replace('cloudinary_', '')] = el.getAttribute('content')
      this

    ###*
     * Initialize Cloudinary from the `CLOUDINARY_URL` environment variable.
     *
     * This function will only run under Node.js environment.
     * @function Configuration#fromEnvironment
     * @requires Node.js
    ###
    fromEnvironment: ->
      cloudinary_url = process?.env?.CLOUDINARY_URL
      if cloudinary_url?
        uri = require('url').parse(cloudinary_url, true)
        @configuration =
          cloud_name: uri.host,
          api_key: uri.auth and uri.auth.split(":")[0],
          api_secret: uri.auth and uri.auth.split(":")[1],
          private_cdn: uri.pathname?,
          secure_distribution: uri.pathname and uri.pathname.substring(1)
        if uri.query?
          for k, v of uri.query
            @configuration[k] = v
      this

    ###*
    * Create or modify the Cloudinary client configuration
    *
    * Warning: `config()` returns the actual internal configuration object. modifying it will change the configuration.
    *
    * This is a backward compatibility method. For new code, use get(), merge() etc.
    * @function Configuration#config
    * @param {hash|string|true} new_config
    * @param {string} new_value
    * @returns {*} configuration, or value
    *
    * @see {@link fromEnvironment} for initialization using environment variables
    * @see {@link fromDocument} for initialization using HTML meta tags
    ###
    config: (new_config, new_value) ->
      # REVIEW it would be more OO to return a copy of @configuration and not the internal object itself. It will mean that cloudinary.config().foo = "bar" will have no effect.
      switch
        when new_value != undefined
          @set(new_config, new_value)
          @configuration
        when Util.isString(new_config)
          @get(new_config)
        when Util.isPlainObject(new_config)
          @merge(new_config)
          @configuration
        else
          # Backward compatibility - return the internal object
          @configuration

    ###*
     * Returns a copy of the configuration parameters
     * @function Configuration#toOptions
     * @returns {Object} a key:value collection of the configuration parameters
    ###
    toOptions: ()->
      Util.cloneDeep(@configuration)

  Configuration
 )