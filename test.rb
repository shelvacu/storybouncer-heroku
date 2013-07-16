require './templatecopy'
session = {}
session[:logged] = false
puts template('test'){'lol'}
