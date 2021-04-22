defmodule ExGridhook.YamlType do
  use Ecto.Type

  def type, do: :yaml

  def cast(any), do: {:ok, any}
  def load(value), do: {:ok, YamlElixir.read_from_string!(value)}

  # Henrik's and Albert's best guess 2020-01-23 on why we put JSON among YAML:
  # we only use this for arrays and hashes where it seems YAML can decode JSON successfully,
  # e.g.: YAML.load(JSON.dump({"url" => "hi"}))
  def dump(value), do: {:ok, "---\n" <> Jason.encode!(value)}
end
