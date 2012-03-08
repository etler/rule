{exec} = require 'child_process'

task 'build', 'build rule.js', ->
  exec 'coffee --compile rule.coffee'

task 'test', 'build rule.js ', ->
  exec 'coffee -j test/rule.js -c rule.coffee test/template.coffee test/init.coffee'
