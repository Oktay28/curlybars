module Curlybars
  module Node
    UnlessElse = Struct.new(:expression, :unless_template, :else_template) do
      def compile
        <<-RUBY
          unless hbs.to_bool(#{expression.compile}.call)
            buffer.safe_concat(#{unless_template.compile})
          else
            buffer.safe_concat(#{else_template.compile})
          end
        RUBY
      end
    end
  end
end
