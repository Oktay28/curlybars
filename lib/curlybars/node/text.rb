module Curlybars
  module Node
    Text = Struct.new(:text) do
      def compile
        <<-RUBY
          buffer.safe_concat(#{text.inspect})
        RUBY
      end

      def validate(trees)
        # Nothing to validate here.
      end
    end
  end
end
