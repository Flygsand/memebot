# -*- Mode: coffee; tab-width: 2 -*-

sys = require 'sys'
path = require 'path'
fs = require 'fs'
{spawn, exec} = require 'child_process'

run_quietly = (command, args, callback) ->
  proc = spawn command, args
  proc.addListener 'exit', callback if callback?
  proc

run = (command, args, callback) ->
  proc = run_quietly command, args, callback
  proc.stdout.addListener 'data', (buffer) -> sys.print buffer
  proc.stderr.addListener 'data', (buffer) -> sys.debug buffer

compile = (dir, args, callback) ->
  args ?= []
  run_quietly 'mkdir', ['build'], ->
    run 'cp', ['-rf', dir, '-t', 'build'], ->
      run 'coffee', args.concat(['-o', path.join('build', dir), '-c', dir]), callback

task 'dependencies', 'install dependencies', ->
  run 'npm', ['install', 'underscore', 'log', 'http://github.com/mtah/nstore/tarball/master', 'http://github.com/mtah/IRC-js/tarball/master', 'http://github.com/mtah/jasmine-node/tarball/master']

task 'compile', 'compile to javascript', ->
  compile 'src'

task 'watch', 'watch for file modifications and automatically recompile', ->
  compile 'src', ['--watch']

task 'spec', 'run specs', ->
  compile 'src', [], ->
    compile 'spec', ['--no-wrap'], ->
      require.paths.push path.join('build', 'src'), path.join('build', 'src', 'vendor'), __dirname
      require('jasmine').executeSpecsInFolder path.join('build', 'spec'), (runner, log) ->
        process.exit runner.results().failedCount

task 'run', 'run bot', ->
  compile 'src', [], ->
    run 'node', ['./build/src/lib/index.js']

task 'clean', 'clean up build residue', ->
  run 'rm', ['-rf', 'build']