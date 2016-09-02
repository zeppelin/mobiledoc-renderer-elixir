defmodule MobileDoc.Renderer_0_3 do
  alias MobileDoc.Dom.Element
  alias MobileDoc.Dom.Document
  alias MobileDoc.DocumentMeta

  def render(%{"sections" => sections, "markups" => marker_types, "atoms" => atom_types, "cards" => card_types}, cards \\ %{}, atoms \\ %{}) do
    document_meta = init_document_meta(marker_types, card_types, atom_types, cards, atoms)
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
    |> render_markers_on_element(markers, meta)
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
      |> render_markers_on_element(markers, meta)

      list_element
      |> Element.append_child(li)
    end)
  end

  # Card
  def render_section([10, card_id], meta) do
    card_for_id(meta, card_id)
    |> render_card
  end

  # Render valid card
  defp render_card({card, payload}) when not is_nil(card) do
    Module.concat(card, Html).setup(_buffer = [], {}, {}, payload)
    |> Enum.reduce(Document.create_element("div"), fn (string, card_element) ->
      card_element
      |> Element.append_child(Document.create_text_node(string))
    end)
  end

  # Render unknown card that has `src` in the payload
  defp render_card({nil, %{"src" => src}}) do
    Document.create_element("img")
    |> Element.set_attribute(["src", src])
  end

  # Render when no card and src
  defp render_card({nil, _}) do
    Document.create_element("p")
  end


  defp init_document_meta(marker_types, card_types, atom_types, cards, atoms) do
    cards = %{"image" => MobileDoc.Card.Image}
    |> Dict.merge(cards)

    %DocumentMeta{marker_types: marker_types, atom_types: atom_types, card_types: card_types}
    |> DocumentMeta.init_cards(cards)
    |> DocumentMeta.init_atoms(atoms)
  end

  defp render_markers_on_element(element, markers, meta) do
    {buffer, _} = markers
    |> Enum.reduce({"", []}, fn (marker, {buffer, tags_open}) ->
      render_marker(buffer, marker, tags_open, meta)
    end)

    element |> Element.append_child(Document.create_text_node(buffer))
  end

  # Markup marker
  defp render_marker(buffer, [0, open_types, close_types, text], tags_open, meta) do
    {opening_tags, tags_open} = render_opening_tags(open_types, tags_open, meta.marker_types)
    {closing_tags, tags_open} = render_closing_tags(close_types, tags_open, meta.marker_types)

    buffer = buffer <> opening_tags <> text <> closing_tags
    {buffer, tags_open}
  end

  # Atom marker

  defp render_marker(buffer, [1, open_types, close_types, atom_id], tags_open, meta) do
    {opening_tags, tags_open} = render_opening_tags(open_types, tags_open, meta.marker_types)
    {closing_tags, tags_open} = render_closing_tags(close_types, tags_open, meta.marker_types)

    atom = atom_for_id(meta, atom_id)
    |> render_atom

    buffer = buffer <> opening_tags <> atom <> closing_tags
    {buffer, tags_open}
  end

  defp render_atom({atom, text, payload}) when not is_nil(atom) do
    Module.concat(atom, Html).render(text, {}, {}, payload)
  end

  defp render_atom({nil, text, _payload}) do
    text
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

  defp card_for_id(meta, id) do
    case Enum.at(meta.card_types, id) do
      [card_name, payload] -> {Dict.get(meta.cards, card_name), payload}
      nil -> {nil, nil}
    end
  end

  defp atom_for_id(meta, id) do
    case Enum.at(meta.atom_types, id) do
      [atom_name, text, payload] -> {Dict.get(meta.atoms, atom_name), text, payload}
      nil -> {nil, nil, nil}
    end
  end

end
