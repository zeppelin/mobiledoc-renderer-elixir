defmodule MobileDoc.DomTest do
  use ExUnit.Case
  alias MobileDoc.Dom.Element
  alias MobileDoc.Dom.Document

  test "text node to string" do
    result = Element.to_s({nil, nil, "hello"})
    assert result == "hello"
  end

  test "simple element to string" do
    result = Element.to_s({"p", nil, "hello"})
    assert result == "<p>hello</p>"
  end

  test "simple element with no content" do
    result = Element.to_s({"p", nil, nil})
    assert result == "<p></p>"
  end

  test "nested elements to string" do
    result = Element.to_s({"p", nil, [
      {"b", nil, "hello"}
    ]})
    assert result == "<p><b>hello</b></p>"
  end

  test "attributes to string" do
    result = Element.to_s({"p", ["class", "hi", "id", "ahoy"], "hello"})
    assert result == "<p class=\"hi\" id=\"ahoy\">hello</p>"
  end

  test "void tag element with attribute to string" do
    result = Element.to_s({"input", ["value", "hello"], nil})
    assert result == "<input value=\"hello\">"
  end

  test "create/1 returns an empty element with the tagname" do
    result = Document.create_element "p"
    assert result == {"p", [], []}
  end

  test "create_text_node" do
    result = Document.create_text_node "hello"
    assert result == {nil, [], "hello"}
  end

  test "appendchild" do
    parent = Document.create_element "div"
    p = Document.create_element "p"
    result = parent |> Element.append_child(p) |> Element.append_child(p)

    assert result == {"div", [], [
      {"p", [], []},
      {"p", [], []}
    ]}
  end

  test "set_attribute" do
    element = Document.create_element "div"
    element = element |> Element.set_attribute(["class", "hello"])
    result = element |> Element.set_attribute(["id", "hi"])

    assert result == {"div", ["class", "hello", "id", "hi"], []}
  end
end
