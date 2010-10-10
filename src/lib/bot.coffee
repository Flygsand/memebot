# -*- Mode: coffee; tab-width: 2 -*-

require 'underscore'
sys = require 'sys'
fs = require 'fs'
path = require 'path'
IRC = require 'irc-js'
nosqlite =
  connect: (path, callback) ->
    db =
      find: (table, query, callback) ->
        callback(null, [sys.inspect(query)])
      save: (table, objects, callback) ->
        callback(null, 'success')

    callback(db)

class Bot
  constructor: (config, irc, db) ->
    @config = config
    @irc = irc
    @db = db
    @plugins = {}
    for name in @config.plugins
      this.load_plugin name

  connect: ->
    for ev_type in ['privmsg']
      @irc.addListener ev_type, this.trigger.bind(this, {type: ev_type})

    on_connect = =>
      this.join @config.channels... if @config.channels instanceof Array
    @irc.connect ->
      setTimeout on_connect, 3000

  disconnect: ->
    @irc.quit()

  say: (message, targets...) ->
    targets = @config.channels unless targets.length > 0

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
    event.source = if data.params[0] == @config.nick then data.person.nick else data.params[0]
    event.text = data.params[data.params.length - 1].toLowerCase()
    event.data = data

    for name, p of @plugins
      p.trigger event, this

  load_plugin: (name) ->
    return false if name in @plugins

    plugin_path = path.join(@config.plugin_dir, name)
    try
      plugin = require plugin_path
    catch error
      throw "No such plugin '#{name}'"

    @plugins[name] = plugin()

    if module.unCacheModule
      fs.watchFile plugin_path, ->
        sys.puts plugin_path
        module.unCacheModule plugin_path
        reload_plugin plugin.info.name

    return plugin

  unload_plugin: (name) ->
    return false unless name in @plugins

    plugin = @plugins[name]
    fs.unWatchFile path.join(@config.plugin_dir, name)
    delete @plugins[name]

    return plugin

  reload_plugin: (name) ->
    this.unload_plugin name
    this.load_plugin name

  error: (e) ->
    this.say "error: #{e}"

  info: ->
    {version: '0.9'}

Bot::run = (config) ->
  validate = (cfg) ->
    missing = _(['server', 'channels']).without(_.keys(cfg)...)
    throw "Missing required configuration option(s): #{missing.join(', ')}" unless _(missing).isEmpty()

  defaultize = (cfg) ->
    cfg ?= {}
    user = _.extend {}, {username: 'memebot', realname: 'memebot', hostname: 'localhost', servername: 'localhost'}, cfg.user
    return _.extend {}, {nick: 'memebot', plugin_dir: path.join(__dirname, 'plugins'), db: './tmp/memebot.db', user: user}, cfg

  config = if _.isFunction config then config() else config
  validate(config)
  config = defaultize config

  nosqlite.connect config.db, (db) ->
    new Bot(config, new IRC(config), db).connect()

module.exports = Bot