defmodule MobileDoc.Dom.Element do
  def append_child({tagname, attributes, content} = _parent, child) do
    {tagname, attributes, content ++ [child]}
  end

  def set_attribute({tagname, attributes, content}, [_key, _value] = attribute) do
    {tagname, attributes ++ attribute, content}
  end

  # Text node
  def to_s({nil, _, content}) when is_binary(content), do: content

  # Any other element
  def to_s({tagname, attributes, content}) do
    html = "<#{tagname}#{render_attrs(attributes)}>"

    unless void_tag?(tagname) do
      content = cond do
        is_list(content) -> content |> Enum.map(&to_s(&1)) |> Enum.join
        content == nil -> ""
        is_binary(content) -> content
      end

      html = html <> content <> "</#{tagname}>"
    end

    html
  end

  def render_opening_tag(tagname, attributes) do
    "<#{String.downcase(tagname)}#{render_attrs(attributes)}>"
  end

  def render_closing_tag(tagname) do
    "</#{String.downcase(tagname)}>"
  end


  defp render_attrs(nil), do: ""
  defp render_attrs([]), do: ""
  defp render_attrs([_|_] = attributes) do
    attributes
    |> Enum.chunk(2, 2)
    |> Enum.map(fn [key, value] -> " #{key}=\"#{value}\"" end)
    |> Enum.join
  end


  @void_tags "area base br col command embed hr img input keygen link meta param source track wbr"
  |> String.split(" ")

  defp void_tag?(tagname) do
    @void_tags |> Enum.member?(tagname)
  end
end
