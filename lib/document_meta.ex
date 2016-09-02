defmodule MobileDoc.DocumentMeta do
  defstruct marker_types: [],
            card_types: [],
            atom_types: [],
            cards: %{"image" => MobileDoc.Card.Image},
            atoms: %{}

  def init_cards(document_meta, cards \\ %{}) do
    cards = document_meta.cards
    |> Dict.merge(cards)

    %{document_meta | cards: cards}
  end

  def init_atoms(document_meta, atoms \\ %{}) do
    atoms = document_meta.atoms
    |> Dict.merge(atoms)

    %{document_meta | atoms: atoms}
  end
end
