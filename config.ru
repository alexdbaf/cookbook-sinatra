require './app'
require_relative 'controllers/lists_controller'

use lists_controller
run Sinatra::Application
