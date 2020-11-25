require "./spec_helper"

describe Crinja do
  it ".render" do
    Crinja.render("Hello {{ name }}!", {name: "World"}).should eq "Hello World!"
  end

  it "renders a simple template without any template syntax" do
    render("Hello World").should eq("Hello World")
  end

  it "renders a simple variable expression" do
    render("Hello, {{ name }}!", {"name" => "John"}).should eq("Hello, John!")
  end

  it "renders a simple hello world with name" do
    render("Hello, {{ user.name | lower | upper }}!", {"user" => {"name" => "John"}}).should eq("Hello, JOHN!")
  end

  it "renders a simple attribute accessor" do
    render("Hello, {{ users[id].name | upper }}!", {"users" => {"john" => {"name" => "John"}}, "id" => "john"}).should eq("Hello, JOHN!")
  end

  it "renders simple literals" do
    render(%("Hello, {{ "World" ~ "\\" " }}{{ 2 }} {{ "A" | lower }}ll{{ "}}" }}!), {"name" => "John"}, autoescape: true).should eq("\"Hello, World&quot; 2 all}}!")
  end

  it "renders if tag" do
    render(%("Hello, {% if world %}World{% else %}Everyone{% endif %}!), {"world" => true}).should eq("\"Hello, World!")
  end

  it "renders else tag" do
    render(%("Hello, {% if world %}World{% else %}Everyone{% endif %}!), {"world" => false}).should eq("\"Hello, Everyone!")
  end

  it "respects comments" do
    render(%(Hello, \n{#- foob\nbar -#}\nWorld!)).should eq("Hello, \nWorld!")
  end

  it "renders simple test" do
    render(%({% if 4 is even %}even{% else %}odd{% endif %})).should eq("even")
  end
end
