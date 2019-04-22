require_relative 'cipher.rb'

module Base64
  class Decoder < Cipher
    def initialize()
      super(nil)
    end

    def update(data)
      bytes = nil
      if data.is_a?(String)
        bytes = data.tr("\n=", '').tr('-_', '+/').bytes
      elsif data.is_a?(Array) && data.all? { |b| b.is_a?(Ingeter) }
        bytes = data
      elsif data.respond_to?(:bytes)
        bytes = data.bytes
      end
      raise 'Data is not array of bytes and not respond to "bytes"' if bytes.nil?

      out_str = ''
      out_str.force_encoding('ASCII-8BIT')
      bytes.each do |b|
        six_bit_val = b64_to_bin(b)
        @data = @data << 6 | six_bit_val
        @bit_counter += 6
        out_str << convert_data
      end
      return out_str
    end

    private

    def b64_to_bin(b64_char)
      c = nil
      if b64_char == 43
        c = 62
      elsif b64_char == 47
        c = 63
      elsif b64_char > 47 && b64_char < 58 # 0-9
        c = b64_char + 4
      elsif b64_char > 64 && b64_char < 91 # A-Z
        c = b64_char - 65
      elsif b64_char > 96 && b64_char < 123 # a-z
        c = b64_char - 71
      end
      return c
    end

    def convert_data
      out_str = ''
      out_str.force_encoding('ASCII-8BIT')
      while @bit_counter >= 8
        mask_len = @bit_counter - 8
        raise 'Bitmask OOB' if mask_len >= BITMASKS.length # Just in case my math sucks

        out_byte = @data >> mask_len
        @data &= BITMASKS[mask_len]
        @bit_counter -= 8
        out_str << out_byte
      end
      return out_str
    end
  end
end
