defmodule MobileDoc.Dom.Document do
  def create_element(tagname) when is_binary(tagname) do
    {String.downcase(tagname), [], []}
  end

  def create_text_node(text) when is_binary(text) do
    {nil, [], text}
  end
end
