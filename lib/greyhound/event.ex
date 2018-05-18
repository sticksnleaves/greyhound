defmodule Greyhound.Event do
  alias Greyhound.Helpers.UUID

  defstruct [:id, :message, :node, :occurred_at, :topic]

  @type t :: %__MODULE__{
    id: binary,
    message: term,
    node: atom,
    occurred_at: NaiveDateTime.t(),
    topic: binary
  }

  @doc "Returns a new event."
  @spec new(binary, term) :: t
  def new(topic, message) do
    %__MODULE__{
      id: UUID.v4(),
      message: message,
      node: node(),
      occurred_at: NaiveDateTime.utc_now(),
      topic: topic
    }
  end
end
