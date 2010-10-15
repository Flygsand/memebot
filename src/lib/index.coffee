# -*- Mode: coffee; tab-width: 2 -*-

sys = require 'sys'
fs = require 'fs'
path = require 'path'

require 'underscore'
IRC = require 'irc-js'
Log = require 'log'

run = ->

  #
  # config
  #
  validate = (cfg) ->
    throw 'could not read configuration' unless cfg
    missing = _(['server', 'channels']).without(_.keys(cfg)...)
    throw "missing required configuration option(s): #{missing.join(', ')}" unless _(missing).isEmpty()

  defaultize = (cfg) ->
    cfg ?= {}
    user = _.extend {}, {username: 'memebot', realname: 'memebot', hostname: 'localhost', servername: 'localhost'}, cfg.user
    dir = _.extend {}, {data: './data'}, cfg.dir
    return _.extend {}, {nick: 'memebot', dir: dir, user: user}, cfg

  @config = JSON.parse(fs.readFileSync(path.join(process.cwd(), 'config', 'common.json')))
  validate @config
  @config = defaultize @config


  #
  # IRC connection
  #
  @irc = new IRC(@config)
  on_connect = =>
    for ch in @config.channels ? []
      @irc.join ch

  @irc.connect ->
    setTimeout(on_connect, 3000)


  #
  # logging
  #
  @log = new Log('notice')


  #
  # Setup & teardown
  #
  Bot = require path.join(__dirname, 'bot')
  @bot = new Bot(@config, @irc, @log)
  @bot.load()

  process.on 'SIGINT', =>
    @bot.unload() if @bot
    process.exit(0)

# go!
run()