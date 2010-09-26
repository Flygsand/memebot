# -*- Mode: coffee; tab-width: 2 -*-

require 'underscore'
sys = require 'sys'
fs = require 'fs'
path = require 'path'
IRC = require 'irc-js'

class Bot
  constructor: (opts, irc) ->
    this.validate_opts(opts)

    @plugins = {}
    @opts = this.opts_with_defaults(opts)
    @irc = irc

  connect: ->
    @irc ?= new IRC @opts ? {}
    for ev_type in ['privmsg']
      @irc.addListener ev_type, this.trigger.bind(this, {type: ev_type})

    on_connect = =>
      this.join @opts.channels... if @opts.channels instanceof Array
    @irc.connect ->
      setTimeout on_connect, 3000

  disconnect: ->
    @irc.quit()

  say: (message, targets...) ->
    targets = @opts.channels unless targets.length > 0

    for target in targets
      @irc.privmsg target, message, true

  action: (action, targets...) ->
    this.say "\001ACTION #{action}\001", targets...

  part: (channels...) ->
    for ch in channels
      @irc.part ch

  join: (channels...) ->
    for ch in channels
      @irc.join ch

  trigger: (event, data) ->
    event.user = data.person.nick
    event.source = if data.params[0] == @opts.nick then data.person.nick else data.params[0]
    event.text = data.params[data.params.length - 1].toLowerCase()
    event.data = data

    for name, p of @plugins
      p.trigger event, this

  load_plugin: (name) ->
    return false if name in @plugins

    try
      init = require path.join(@opts.plugin_dir, name)
    catch error
      throw "No such plugin '#{name}'"

    plugin = init()
    this.validate_plugin plugin

    @plugins[plugin.name] = plugin

    if module.unCacheModule
      fs.watchFile plugin.path, ->
        module.unCacheModule plugin.path
        reload_plugin plugin.name

    return plugin

  unload_plugin: (name) ->
    return false unless name in @plugins

    plugin = @plugins[name]
    fs.unWatchFile plugin.path
    delete @plugins[name]

    return plugin

  reload_plugin: (name) ->
    this.unload_plugin name
    this.load_plugin name

  validate_plugin: (plugin) ->
    throw 'Plugin metadata missing' unless plugin.name and plugin.path

  validate_opts: (opts) ->
    missing = _(['server', 'channels']).without(_.keys(opts)...)
    throw "Missing required options #{missing.join(', ')}" unless _(missing).isEmpty()

  opts_with_defaults: (opts) ->
    opts ?= {}
    user = _.extend({}, {username: 'memebot', realname: 'memebot', hostname: 'localhost', servername: 'localhost'}, opts.user)
    return _.extend({}, {nick: 'memebot', user: user}, opts)

  error: (e) ->
    this.say "error: #{e}"

  info: ->
    {version: '0.9'}

module.exports = Bot