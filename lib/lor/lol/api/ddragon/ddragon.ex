defmodule Lor.Lol.Ddragon do
  @moduledoc """
  Convenience for converting asset IDs to image URLs
  """

  @ddragon_cdn "https://ddragon.leagueoflegends.com/cdn"

  @doc """
  Get a champion image given the game_version and champion_key.
  ## Example
    iex> Ddragon.get_champion_image("12.16.1", 1)
    "https://ddragon.leagueoflegends.com/cdn/12.16.1/img/champion/Annie.png"
  """
  def get_champion_image(game_version, champion_key) do
    case Lor.Lol.Ddragon.Cache.get({:champion, champion_key}) do
      champion_img when is_binary(champion_img) ->
        "#{@ddragon_cdn}/#{game_version}/img/champion/#{champion_img}"

      nil ->
        nil
    end
  end

  @doc """
  Get a summoner image given the game_version and summoner_key.
  ## Example
    iex> Ddragon.get_summoner_image("12.16.1", 1038)
    "https://ddragon.leagueoflegends.com/cdn/12.16.1/img/item/1038.png"
  """
  def get_summoner_image(game_version, summoner_key) do
    case Lor.Lol.Ddragon.Cache.get({:summoner, summoner_key}) do
      summoner_img when is_binary(summoner_img) ->
        "#{@ddragon_cdn}/#{game_version}/img/spell/#{summoner_img}"

      nil ->
        nil
    end
  end

  @doc """
  Get a summoner image given the game_version and summoner_key.
  ## Example
    iex> Ddragon.get_item_image("12.16.1", 1038)
    "https://ddragon.leagueoflegends.com/cdn/12.16.1/img/item/1038.png"
  """
  def get_item_image(game_version, item_key)
  def get_item_image(_game_version, 0), do: nil

  def get_item_image(game_version, item_key) do
    "#{@ddragon_cdn}/#{game_version}/img/item/#{item_key}.png"
  end

  @doc """
  Get a champion search map

  ## Example

    iex> Ddragon.get_champions_search_map()
    %{
      "lux" => 99,
      "evelynn" => 28,
      "heimerdinger" => 74,
      ...
    }
  """
  def get_champion_search_map do
    case Lor.Lol.Ddragon.Cache.get(:champions_search_map) do
      search_map when is_map(search_map) ->
        search_map

      nil ->
        %{}
    end
  end

  @doc """
  Get a profile icon
  """
  def get_profile_icon(game_version, icon_key) do
    "#{@ddragon_cdn}/#{game_version}/img/profileicon/#{icon_key}.png"
  end

  @doc """
  Get last game version
  """
  def get_last_game_version do
    case Lor.Lol.Ddragon.Cache.get(:last_game_version) do
      game_version when is_binary(game_version) ->
        game_version

      nil ->
        "14.2.1"
    end
  end
end
