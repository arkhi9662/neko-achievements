defmodule Neko.UserRate do
  alias Neko.UserRate.Store
  alias Neko.UserRate.Store.Registry

  defstruct ~w(
    id
    user_id
    target_id
    target_type
    score
    status
  )a

  def from_request(request) do
    struct(__MODULE__, Map.from_struct(request))
  end

  def load(user_id) do
    case Registry.lookup(user_id) do
      {:ok, _store} -> {:ok, :already_loaded}
      :error -> Registry.fetch(user_id) |> Store.reload(user_id)
    end
  end

  # TODO: NatSet
  #
  # stopping achievement store stops underlying agent ->
  # monitoring process (achievement store registry) is notified about
  # about terminated agent process and deletes ETS entry for specified
  # user_id (no achievement store is mapped to that user_id any longer)
  def reset(user_id) do
    case Registry.lookup(user_id) do
      {:ok, store} -> Store.stop(store)
      :error -> {:ok, :not_found}
    end
  end

  def all(user_id) do
    store(user_id) |> Store.all()
  end

  def put(user_id, user_rate) do
    store(user_id) |> Store.put(user_rate)
  end

  def set(user_id, user_rates) do
    store(user_id) |> Store.set(user_rates)
  end

  def delete(user_id, user_rate) do
    store(user_id) |> Store.delete(user_rate)
  end

  defp store(user_id) do
    case Registry.lookup(user_id) do
      {:ok, store} -> store
      :error -> raise("load user_rate store first")
    end
  end
end
