# -*- Mode: coffee; tab-width: 2 -*-

sys = require 'sys'
path = require 'path'
jasmine = require 'jasmine'
Bot = require 'lib/bot'

describe 'Bot', ->
  bot = null
  irc = null

  beforeEach ->
    irc =
      connect: (callback) ->
        callback()

    plugin_dir = path.join(__dirname, '..', 'resources', 'plugins')
    bot = new Bot {channels: ['#test1', '#test2'], plugin_dir: plugin_dir}, irc

  it 'joins channels upon connection', ->
    irc.join = jasmine.createSpy()
    irc.addListener = new Function

    runs ->
      bot.connect()

    waits 4000

    runs ->
      expect(irc.join.callCount).toEqual(2)
      expect(irc.join.argsForCall[0]).toEqual(['#test1'])
      expect(irc.join.argsForCall[1]).toEqual(['#test2'])

  it 'adds listeners upon connection', ->
    irc.connect = new Function
    irc.addListener = jasmine.createSpy()
    bot.trigger = new Function

    bot.connect()

    expect(irc.addListener).toHaveBeenCalled()

  it 'says a message to all given targets', ->
    irc.privmsg = jasmine.createSpy()

    bot.say 'foo', '#ch1', '#ch2', '#ch3'

    expect(irc.privmsg.callCount).toEqual(3)
    expect(irc.privmsg.argsForCall[0]).toEqual(['#ch1', 'foo', true])
    expect(irc.privmsg.argsForCall[1]).toEqual(['#ch2', 'foo', true])
    expect(irc.privmsg.argsForCall[2]).toEqual(['#ch3', 'foo', true])

  it 'says a message to all joined channels if no targets are given', ->
    irc.privmsg = jasmine.createSpy()

    bot.say 'foo'

    expect(irc.privmsg.callCount).toEqual(2)
    expect(irc.privmsg.argsForCall[0]).toEqual(['#test1', 'foo', true])
    expect(irc.privmsg.argsForCall[1]).toEqual(['#test2', 'foo', true])

  it 'puts and action to all given targets', ->
    irc.privmsg = jasmine.createSpy()

    bot.action 'yawns', '#ch1'

    expect(irc.privmsg.callCount).toEqual(1)
    expect(irc.privmsg.mostRecentCall.args).toEqual(['#ch1', '\001ACTION yawns\001', true])

  it 'joins the given channels', ->
    irc.join = jasmine.createSpy()

    bot.join '#ch1', '#ch2'

    expect(irc.join.callCount).toEqual(2)
    expect(irc.join.argsForCall[0]).toEqual(['#ch1'])
    expect(irc.join.argsForCall[1]).toEqual(['#ch2'])

  # TODO: trigger tests

  it 'loads and validates the given plugin when it exists', ->
    bot.validate_plugin = jasmine.createSpy()
    dummy = bot.load_plugin 'dummy'

    expect(dummy.name).toEqual('dummy')
    expect(dummy.path).toEqual(path.join(__dirname, '..', 'resources', 'plugins', 'dummy.js'))
    expect(bot.validate_plugin).toHaveBeenCalled()

  it 'throws an exception when attempting to load a non-existing plugin', ->
    fn = ->
      bot.load_plugin('bogus')

    expect(fn).toThrow("No such plugin 'bogus'")