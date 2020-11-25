require "./spec_helper"

describe "autoescape" do
  it "renders template *.html" do
    render_file("hello_world.html", {
      "variable"  => "Value with <unsafe> data",
      "item_list" => [1, 2, 3, 4, 5, 6],
    }, autoescape: true).should eq(rendered_file("hello_world.html"))
  end

  it "renders template *.xml" do
    env = Crinja.new
    env.config.autoescape.disabled_extensions = ["txt"]
    env.config.autoescape.default = false
    Crinja::Template.new("{{ variable }}", env, filename: "hello_world.XML").render({
      "variable" => "Value with <unsafe> data",
    }).should eq("Value with &lt;unsafe&gt; data")
  end

  it "renders template *.xml.jinja" do
    env = Crinja.new
    env.config.autoescape.disabled_extensions = ["txt"]
    env.config.autoescape.default = false
    Crinja::Template.new("{{ variable }}", env, filename: "hello_world.xml.jinja").render({
      "variable" => "Value with <unsafe> data",
    }).should eq("Value with &lt;unsafe&gt; data")
  end

  it "renders template *.xml.j2" do
    env = Crinja.new
    env.config.autoescape.disabled_extensions = ["txt"]
    Crinja::Template.new("{{ variable }}", env, filename: "hello_world.xml.j2").render({
      "variable" => "Value with <unsafe> data",
    }).should eq("Value with &lt;unsafe&gt; data")
  end

  it "renders template *.txt" do
    env = Crinja.new
    env.config.autoescape.disabled_extensions = ["txt"]
    Crinja::Template.new("{{ variable }}", env, filename: "hello_world.txt").render({
      "variable" => "Value with <unsafe> data",
    }).should eq("Value with <unsafe> data")
  end

  it "renders template *.txt.jinja" do
    env = Crinja.new
    env.config.autoescape.disabled_extensions = ["txt"]
    Crinja::Template.new("{{ variable }}", env, filename: "hello_world.txt.jinja").render({
      "variable" => "Value with <unsafe> data",
    }).should eq("Value with <unsafe> data")
  end

  it "renders template *.txt.j2" do
    env = Crinja.new
    env.config.autoescape.disabled_extensions = ["txt"]
    Crinja::Template.new("{{ variable }}", env, filename: "hello_world.TXT.J2").render({
      "variable" => "Value with <unsafe> data",
    }).should eq("Value with <unsafe> data")
  end
end
