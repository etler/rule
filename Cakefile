{exec} = require 'child_process'

option '-w', '--watch', 'watch scripts for changes and rerun commands'

task 'build', 'build rule.js', (options) ->
  child = exec 'coffee '+(if options.watch is true then '-w ' else '')+'--compile rule.coffee'
  child.stdout.on 'data', (data) -> console.log data

task 'test', 'build rule.js ', (options) ->
  invoke 'build'
  child = exec 'coffee '+(if options.watch is true then '-w ' else '')+'-j test/test.js -c test/test.coffee'
  child.stdout.on 'data', (data) -> console.log data