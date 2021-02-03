defmodule Allo do
  use Crawly.Spider

  @impl Crawly.Spider
  def base_url(), do: "https://allo.ua/ru/"

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://allo.ua/ru/products/notebooks/"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # Parse response body to document
    {:ok, document} = Floki.parse_document(response.body)

    # Extract individual product page URLs
    urls =
      document
      |> Floki.find("div.product-card__content")
      |> Floki.find("a.product-card__title")
      |> Floki.attribute("href")

    requests =
      urls
      |> Enum.uniq()
      |> Enum.map(&Crawly.Utils.request_from_url/1)

    # Create item (for pages where items exists)
    item = %{
      title: product_title(document),
      description: product_description(document),
      price: product_price(document)
    }

    %Crawly.ParsedItem{items: [item], requests: requests}
  end

  defp product_title(document) do
    document
    |> Floki.find("h1.product-header__title")
    |> Floki.text()
  end

  defp product_description(document) do
    document
    |> Floki.find("td.product-details__value")
    |> Floki.text()
  end

  defp product_price(document) do
    document
    |> Floki.find("div.v-price-box__cur.metric")
    |> Floki.find("span.sum")
    |> Floki.text()
  end
end
