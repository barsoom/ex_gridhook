defmodule ExGridhook.YamlType do
  @behaviour Ecto.Type

  def type, do: :yaml

  def cast(any), do: {:ok, any}
  def load(value), do: {:ok, YamlElixir.read_from_string!(value)}
  def dump(value), do: {:ok, "---\n" <> Jason.encode!(value)}
end
