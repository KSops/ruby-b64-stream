# frozen_string_literal: true

module Base64
  class Cipher
    BITMASKS = [0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 1023].freeze

    attr_accessor :encoding

    def initialize(encoding)
      @encoding = encoding
      @data = 0
      @bit_counter = 0
    end

    def update(data) end

    def final
      return ''
    end

    protected

    attr_accessor :data
    attr_accessor :bit_counter

    def convert_data() end
  end
end
