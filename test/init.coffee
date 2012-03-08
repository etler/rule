$ ->

  rule.bind $ '#template .list'
  itemRule.bind $ '#template .item'

  ($ 'body').append rule.build
    list: [{c: 'hello'}, {b: 'world'}, {}]