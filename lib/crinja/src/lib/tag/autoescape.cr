# If you want you can activate and deactivate the autoescaping from within the templates.
#
# ```
# {% autoescape true %}
#     Autoescaping is active within this block
# {% endautoescape %}
#
# {% autoescape false %}
#     Autoescaping is inactive within this block
# {% endautoescape %}
# ```
#
# After an endautoescape the behavior is reverted to what it was before.
#
# See [Jinja2 Template Documentation](http://jinja.pocoo.org/docs/2.9/templates/#autoescape-overrides) for details.
class Crinja::Tag::Autoescape < Crinja::Tag
  name "autoescape", "endautoescape"

  def interpret_output(renderer : Crinja::Renderer, tag_node : TagNode)
    env = renderer.env
    args = ArgumentsParser.new(tag_node.arguments, env.config)
    expression = args.parse_expression

    is_activated = env.evaluate(expression).truthy?

    previous_value = env.context.autoescape?

    begin
      env.context.autoescape = is_activated

      renderer.render(tag_node.block)
    ensure
      env.context.autoescape = previous_value
    end
  end
end
