module Base64
  class Stream
    def initialize(io, cipher)
      @io = io
      @cipher = cipher
      @buffer = ''
      @buffer_pos = -1
      @cipher_finalized = false
    end

    def eof?
      @cipher_finalized && end_of_buffer?
    end

    def getc
      # While it seems like these should be consolidated to cut down on branching,
      # there should be two checks for end_of_buffer? in case finalization produces an empty buffer
      load_next_chunk if end_of_buffer? && !@cipher_finalized
      return @io&.getc if end_of_buffer?

      @buffer_pos += 1
      @buffer[@buffer_pos]
    end

    private

    def end_of_buffer?
      @buffer_pos >= @buffer.length - 1
    end

    def load_next_chunk
      return if @cipher_finalized

      @buffer = ''
      @buffer_pos = -1
      while @buffer.empty? && !@io&.eof?
        @buffer = @cipher.update(@io.getc)
      end
      if @buffer.empty?
        @buffer = @cipher.final
        @cipher_finalized = true
      end
    end
  end
end
