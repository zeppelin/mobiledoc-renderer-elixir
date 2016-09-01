defmodule MobileDoc.Renderer do

  def render(doc, cards \\ %{})

  def render(doc = %{ "version" => "0.2.0" }, cards) do
    MobileDoc.Renderer_0_2.render(doc, cards)
  end

  def render(doc = %{ "version" => "0.3.0" }, cards) do
    MobileDoc.Renderer_0_3.render(doc, cards)
  end

end
