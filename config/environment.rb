# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Rsense::Application.initialize!

require 'will_paginate'

TIME = 1
NUMBER = 2
LOCATION = 3
TEXT = 4