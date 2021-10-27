defmodule NFLRushing.Stats do
  @moduledoc """
  The context for managing Rushing statistics entries.
  """

  alias NFLRushing.Repo
  alias NFLRushing.Stats.Entry

  @doc """
  Returns the list of entries.

  ## Examples

      iex> list_entries()
      [%Entry{}, ...]

  """
  def list_entries do
    Repo.all(Entry)
  end
end
