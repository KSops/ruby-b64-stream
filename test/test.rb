require 'minitest/autorun'
require 'b64_stream'

class Base64StreamTest < Minitest::Test
  STRING_LENGTH_TEST_DATA = ['a', 'ab', 'abc'].freeze

  def test_rfc2045_padding_1
    input = 'a'
    b64_str = full_encode(input, :rfc2045)
    assert(
      b64_str.end_with?('==') && b64_str[-3] != '=',
      "Input with length 1 should be padded with '==', but result is #{b64_str}"
    )
    decoded = full_decode(b64_str)
    assert(
      decoded.bytes == input.bytes,
      'Decoded value not equal to input'
    )
  end

  def test_rfc2045_padding_2
    input = 'ab'
    b64_str = full_encode(input, :rfc2045)
    assert(
      b64_str.end_with?('=') && b64_str[-2] != '=',
      "Input with length 2 should be padded with '=', but result is #{b64_str}"
    )
    decoded = full_decode(b64_str)
    assert(
      decoded.bytes == input.bytes,
      'Decoded value not equal to input'
    )
  end

  def test_rfc2045_padding_3
    input = 'abc'
    b64_str = full_encode(input, :rfc2045)
    assert(
      b64_str[-1] != '=',
      "Input with length 3 should be padded with '=', but result is #{b64_str}"
    )
    decoded = full_decode(b64_str)
    assert(
      decoded.bytes == input.bytes,
      'Decoded value not equal to input'
    )
  end

  def test_rfc4648_no_padding
    STRING_LENGTH_TEST_DATA.each do |str|
      b64_str = full_encode(str, :rfc4648)
      assert(
        b64_str[-1] != '=',
        "rfc4648 should have no padding, but result is #{b64_str}"
      )
      decoded = full_decode(b64_str)
      assert(
        decoded.bytes == str.bytes,
        'Decoded value not equal to input'
      )
    end
  end

  def test_url_safe_no_padding
    STRING_LENGTH_TEST_DATA.each do |str|
      b64_str = full_encode(str, :rfc4648_url_safe)
      assert(
        b64_str[-1] != '=',
        "rfc4648_url_safe should have no padding, but result is #{b64_str}"
      )
      decoded = full_decode(b64_str)
      assert(
        decoded.bytes == str.bytes,
        'Decoded value not equal to input'
      )
    end
  end

  def test_rfc2045_linebreak
    obj = Object.new

    def obj.getc
      @counter ||= 0
      @counter += 1
      return @counter > 255 ? nil : 'a'
    end

    def obj.eof?
      @counter ||= 0
      return @counter >= 255
    end

    b64_str = full_cipher(obj, Base64::Encoder.new(:rfc2045))
    counter = 0
    b64_str.each_char do |c|
      counter += 1
      counter = 0 if c == "\n"
      assert(counter < 75, 'RFC2045 max line length is 74')
    end
  end

  def test_url_safe_escapes
    some_data_with_edge_characters = full_decode('ABC+/abc')
    url_safe_str = full_encode(some_data_with_edge_characters, :rfc4648_url_safe)
    assert(
      url_safe_str.include?('-_'),
      "rfc4648_url_safe should escape, but string is: #{url_safe_str}"
    )
    decoded = full_decode(url_safe_str)
    assert(
      decoded.bytes == some_data_with_edge_characters.bytes,
      'Decoded value not equal to input'
    )
  end

  def full_encode(str, encoding)
    full_cipher(str, Base64::Encoder.new(encoding))
  end

  def full_decode(str)
    full_cipher(str, Base64::Decoder.new)
  end

  def full_cipher(data, cipher)
    input = data.is_a?(String) ? StringIO.new(data, 'rb') : data
    stream = Base64::Stream.new(input, cipher)
    output = ''
    c = stream.getc
    while !c.nil?
      output << c
      is_eof = stream.eof?
      c = stream.getc
      assert(!is_eof, 'Stream is EOF before getting nil') unless c.nil?
    end
    assert(stream.eof?, 'Stream should be EOF')
    return output
  end
end
