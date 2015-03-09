module Curlybars
  module Node
    Unless = Struct.new(:expression, :template) do
      def compile
        <<-RUBY
          unless rendering.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{template.compile})
          end
        RUBY
      end

      def validate(branches)
        [
          expression.validate(branches),
          template.validate(branches)
        ]
      end
    end
  end
end
