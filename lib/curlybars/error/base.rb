module Curlybars::Error
  class Base < StandardError
    attr_reader :id, :position

    def initialize(id, message, position)
      super(message)
      @id = id
      @position = position
      return if position.file_name.nil?
      location = "%s:%d:%d" % [position.file_name, position.line_number, position.line_offset]
      set_backtrace([location])
    end
  end
end