module Curlybars
  module Node
    Template = Struct.new(:items) do
      def compile
        compiled_items = (items || []).map do |item|
          "buffer.safe_concat(#{item.compile})"
        end.join("\n")

        <<-RUBY
          Module.new do
            def self.exec(contexts, hbs)
              buffer = ActiveSupport::SafeBuffer.new
              #{compiled_items}
              buffer
            end
          end.exec(contexts, hbs)
        RUBY
      end
    end
  end
end
