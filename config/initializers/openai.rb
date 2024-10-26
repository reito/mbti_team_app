# # config/initializers/openai.rb
# OpenAI.configure do |config|
#     config.access_token = ENV["OPENAI_API_KEY"]
#   end
require 'openai'

client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
