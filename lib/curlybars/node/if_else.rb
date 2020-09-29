module Curlybars
  module Node
    IfElse = Struct.new(:expression, :if_template, :else_template) do
      def compile
        # NOTE: the following is a heredoc string, representing the ruby code fragment
        # outputted by this node.
        <<-RUBY
          if rendering.to_bool(rendering.cached_call(#{expression.compile}))
            #{if_template.compile}
          else
            #{else_template.compile}
          end
        RUBY
      end

      def validate(branches)
        [
          expression.validate(branches),
          if_template.validate(branches),
          else_template.validate(branches)
        ]
      end

      def cache_key
        [
          expression,
          if_template,
          else_template
        ].map(&:cache_key).push(self.class.name).join("/")
      end
    end
  end
end
