# Greyhound

## Installation

```elixir
def deps do
  [
    {:greyhound, "~> 0.1.0"}
  ]
end
```

## Defining an event bus

```elixir
defmodule MyApp.Bus do
  use Greyhound.Bus, otp_app: :my_app
end
```
