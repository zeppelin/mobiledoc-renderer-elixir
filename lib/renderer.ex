defmodule MobileDoc.Renderer do
  alias MobileDoc.Dom.Element
  alias MobileDoc.Dom.Document
  alias MobileDoc.DocumentMeta

  def render(doc \\ %{"sections" => []}, cards \\ %{}) do
    [marker_types, sections] = doc |> Dict.get("sections")

    document_meta = init_document_meta(marker_types, cards)
    root = Document.create_element("div")

    sections
    |> Enum.reduce(root, fn (section, root) ->
      section = render_section(section, document_meta)
      root |> Element.append_child(section)
    end)
    |> Element.to_s
  end


  # Markup
  def render_section([1, tagname, markers], meta) do
    Document.create_element(tagname)
    |> render_markers_on_element(markers, meta.marker_types)
  end

  # Image
  def render_section([2, url], _) do
    Document.create_element("img") |> Element.set_attribute(["src", url])
  end

  # List
  def render_section([3, tagname, items], meta) do
    items
    |> Enum.reduce(Document.create_element(tagname), fn (markers, list_element) ->
      li = Document.create_element("li")
      |> render_markers_on_element(markers, meta.marker_types)

      list_element
      |> Element.append_child(li)
    end)
  end

  # Card
  def render_section([10, name, payload], meta) do
    card_for_name(meta.cards, name)
    |> render_card(payload)
  end

  # Render valid card
  defp render_card(card, payload) when not is_nil(card) do
    card.Html.setup(_buffer = [], {}, {}, payload)
    |> Enum.reduce(Document.create_element("div"), fn (string, card_element) ->
      card_element
      |> Element.append_child(Document.create_text_node(string))
    end)
  end

  # Render unknown card that has `src` in the payload
  defp render_card(nil, %{"src" => src}) do
    Document.create_element("img")
    |> Element.set_attribute(["src", src])
  end

  # Render when no card and src
  defp render_card(nil, _) do
    Document.create_element("p")
  end


  defp init_document_meta(marker_types, cards) do
    cards = %{"image" => MobileDoc.Card.Image}
    |> Dict.merge(cards)

    %DocumentMeta{marker_types: marker_types}
    |> DocumentMeta.init_cards(cards)
  end

  defp render_markers_on_element(element, markers, marker_types) do
    {buffer, _} = markers
    |> Enum.reduce({"", []}, fn ([open_types, close_types, text] = _marker, {buffer, tags_open}) ->
      {opening_tags, tags_open} = render_opening_tags(open_types, tags_open, marker_types)
      {closing_tags, tags_open} = render_closing_tags(close_types, tags_open, marker_types)

      buffer = buffer <> opening_tags <> text <> closing_tags
      {buffer, tags_open}
    end)

    element |> Element.append_child(Document.create_text_node(buffer))
  end

  defp render_opening_tags([], tags_open, _), do: {"", tags_open}
  defp render_opening_tags(open_types, tags_open, marker_types) do
    open_types
    |> Enum.reduce({"", tags_open}, fn (open_type, {buffer, tags_open}) ->
      tagname = tagname_for_marker_type(marker_types, open_type)
      attributes = attributes_for_marker_type(marker_types, open_type)

      buffer = buffer <> Element.render_opening_tag(tagname, attributes)
      tags_open = tags_open ++ [open_type]

      {buffer, tags_open}
    end)
  end

  defp render_closing_tags(0, tags_open, _), do: {"", tags_open}
  defp render_closing_tags(close_types, tags_open, marker_types) do
    0..(close_types-1)
    |> Enum.reduce({"", tags_open}, fn (_, {buffer, tags_open}) ->
      marker_type = List.last(tags_open)
      closing_tagname = tagname_for_marker_type(marker_types, marker_type)

      closing_tag = Element.render_closing_tag(closing_tagname)
      tags_open = tags_open |> Enum.drop(-1)

      buffer = buffer <> closing_tag

      {buffer, tags_open}
    end)
  end

  defp tagname_for_marker_type(marker_types, index) do
    marker_types
    |> Enum.at(index)
    |> List.first
  end

  defp attributes_for_marker_type(marker_types, index) do
    marker_types
    |> Enum.at(index)
    |> Enum.at(1)
  end

  defp card_for_name(cards, name) do
    cards |> Dict.get(name)
  end
end
