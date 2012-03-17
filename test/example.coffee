rule = new Rule
  'select':
    '=': -> if not @options? then ''
    'option': -> option for option in @options
  '<': 'test'
template = $('''<div><select><option></option></select></div>''')
rule.template = template
$('body').append rule.render({})
