require 'sinatra'
require 'token_phrase'

class UnplannedNarrative < Sinatra::Base
  get '/' do
    TokenPhrase.generate(' ', :numbers => false)
  end
end
