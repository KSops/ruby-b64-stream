# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'b64_stream'
  s.version     = '0.0.1'
  s.date        = '2019-04-11'
  s.summary     = 'Streamable encoder/decoder for base64'
  s.description = ''
  s.authors     = ['Kyle Sakai']
  s.email       = 'kyle.sakai0@gmail.com'
  s.files       = [
    'lib/b64_stream.rb',
    'lib/base64/cipher.rb',
    'lib/base64/consts.rb',
    'lib/base64/decoder.rb',
    'lib/base64/encoder.rb',
    'lib/base64/stream.rb',
    'test/test.rb'
  ]
  s.homepage    = 'http://rubygems.org/gems/b64_stream'
  s.license     = 'MIT'
end
