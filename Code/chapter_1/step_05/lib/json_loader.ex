defmodule JsonLoader do
  def load_to_database(db, path) do
    {:ok, json} = Poison.decode(File.read!(path))

    for item <- json do
      :ets.insert(:"#{db}", {item["id"], item})
    end
  end
end
