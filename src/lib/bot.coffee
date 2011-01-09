# -*- Mode: coffee; tab-width: 2 -*-
#
sys = require 'sys'
fs = require 'fs'
path = require 'path'

log = require 'log'
_ = require 'underscore'

process.on 'uncaughtException', (err) ->
  console.log err.message
  console.log err.stack

class Bot
  constructor: (config, irc, log) ->
    @config = config
    @irc = irc
    @log = log
    @plugins = {}
    @listeners = []

  load: ->
    for name in @config.plugins
      @load_plugin name

    for type in ['privmsg', 'join']
      callback = _.bind(@trigger, this, {type: type})
      @listeners.push {type: type, callback: callback}
      @irc.addListener type, callback

    @irc.addListener 'join', (e) =>
      try
        channel = e.params[0]
        if channel and e.person.nick == @config.nick # the bot's own join
          for name, plugin of @plugins
            plugin.onjoin channel if plugin.onjoin
      catch error
        @log.error error.message
        @log.error error.stack

  unload: ->
    for listener in @listeners
      @irc.removeListener listener.type, listener.callback

    @listeners = []

    for name in _.keys(@plugins)
      @unload_plugin name

  say: (message, targets...) ->
    targets = @config.channels unless targets.length > 0

    for target in targets
      @irc.privmsg target, message, true

  action: (action, targets...) ->
    @say "\001ACTION #{action}\001", targets...

  part: (channels...) ->
    for ch in channels
      @irc.part ch

  join: (channels...) ->
    for ch in channels
      @irc.join ch

  trigger: (event, data) ->
    try
      event.user = data.person.nick
      event.source = if data.params[0] == @config.nick then data.person.nick else data.params[0]
      event.text = data.params[data.params.length - 1].toLowerCase()
      event.data = data

      for name, plugin of @plugins
        plugin.trigger event
    catch error
      @log.error error.message
      @log.error error.stack

  load_plugin: (name) ->
    try
      @unload_plugin name
      plugin = require path.join(__dirname, 'plugins', name)
      plugin = plugin()
      plugin.bot = this
      plugin.name = name
      plugin.onload() if plugin.onload
      @plugins[name] = plugin
    catch error
      @log.error "Error loading plugin '#{name}\n#{error.stack}'"

  unload_plugin: (name) ->
    return false unless @plugins[name]

    plugin = @plugins[name]
    plugin.onunload() if plugin.onunload
    delete @plugins[name]
    delete plugin.bot
    delete plugin

  error: (e) ->
    @say "error: #{e}"

  info: ->
    {version: '0.99'}

module.exports = Bot