defmodule MobileDoc.DocumentMeta do
  defstruct marker_types: [],
            cards: %{"image" => MobileDoc.Card.Image}

  def init_cards(document_meta, cards \\ %{}) do
    cards = document_meta.cards
    |> Dict.merge(cards)

    %{document_meta | cards: cards}
  end
end
