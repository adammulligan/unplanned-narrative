require 'sinatra'
require 'token_phrase'

get '/' do
  TokenPhrase.generate(' ', :numbers => false)
end
