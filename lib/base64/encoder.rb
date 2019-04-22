require_relative 'cipher.rb'

module Base64
  class Encoder < Cipher
    def initialize(encoding, opts = {})
      super(encoding)
      @output_mod_sixty = 0
      @skip_padding = (encoding == :rfc2045) ? opts[:skip_padding] : true
    end

    def update(data)
      bytes = nil
      if data.is_a?(Array) && data.all? { |b| b.is_a?(Ingeter) }
        bytes = data
      elsif data.respond_to?(:bytes)
        bytes = data.bytes
      end
      raise 'Data is not array of bytes and not respond to "bytes"' if bytes.nil?

      out_str = ''
      bytes.each do |b|
        @data = @data << 8 | b
        @bit_counter += 8
        out_str << convert_data
      end
      out_str.tr!('+/', '-_') if @encoding == :rfc4648_url_safe
      return out_str
    end

    def final
      result = convert_data
      if @bit_counter > 0
        padding = (6 - @bit_counter) / 2
        last_byte = @data << (6 - @bit_counter)
        result << (last_byte + offset_to_ascii(last_byte))
        result << ('=' * padding) unless @skip_padding
      end
      result.tr!('+/', '-_') if @encoding == :rfc4648_url_safe
      return result
    end

    private

    def offset_to_ascii(b)
      return b < 26 ? 65 :
      b < 52 ? 71 :
      b < 62 ? -4 :
      b < 63 ? -19 :
      -16
    end

    def convert_data
      out_str = ''
      while @bit_counter >= 6
        mask_len = @bit_counter - 6
        raise 'Bitmask OOB' if mask_len >= BITMASKS.length # Just in case my math sucks

        out_byte = @data >> mask_len
        @data &= BITMASKS[mask_len]
        @bit_counter -= 6
        offset = offset_to_ascii(out_byte)
        b64_byte = out_byte + offset
        out_str << b64_byte
        @output_mod_sixty = (@output_mod_sixty + 1) % 60
        out_str << "\n" if @encoding == :rfc2045 && @output_mod_sixty == 0
      end
      return out_str
    end
  end
end
