defmodule MobileDoc.Card.Image do
  defstruct name: "image"

  defmodule Html do
    def setup(buffer, _options, _env, %{"src" => src}) do
      buffer ++ ["<img src=\"#{src}\">"]
    end
  end
end
