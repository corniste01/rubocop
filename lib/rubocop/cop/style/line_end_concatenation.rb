# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for string literal concatenation at
      # the end of a line.
      #
      # @example
      #
      #   # bad
      #   some_str = 'ala' +
      #              'bala'
      #
      #   # good
      #   some_str = 'ala' \
      #              'bala'
      #
      class LineEndConcatenation < Cop
        MSG = 'Use \\ instead of + to concatenate those strings.'

        def on_send(node)
          add_offense(node, :selector) if offending_node?(node)
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            # replace + with \
            corrector.replace(node.loc.selector, '\\')
          end
        end

        private

        def offending_node?(node)
          receiver, method, arg = *node

          # TODO: Report Emacs bug.
          return false unless :+ == method

          return false unless string_type?(receiver.type)

          return false unless string_type?(arg.type)

          plus_at_line_end?(node.loc.expression.source)
        end

        def plus_at_line_end?(expression)
          # check if the first line of the expression ends with a +
          expression =~ /.+\+\s*$/
        end

        def string_type?(node_type)
          [:str, :dstr].include?(node_type)
        end
      end
    end
  end
end
