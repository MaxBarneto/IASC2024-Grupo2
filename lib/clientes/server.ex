defmodule KVServer do
  use Plug.Router

  plug :match
  plug :dispatch

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  get "/ping" do
    send_resp(conn, 200, "pong!")
  end

  get "/datos/:key" do
    IO.puts("Buscando dato para clave: #{key}")

    case Orquestador.find(key) do
      [value] -> send_resp(conn, 200, value)
      [] -> send_resp(conn, 404, "Not Found")
    end
  end

  get "filter/greather/datos/:value" do
    
    #query_params = conn.query_params
    #filter = Map.get(query_params, "filter", "default")

    IO.puts("Buscando dato para valores mayores que: #{value}")

    result = Orquestador.find_by_value(value, ">")
    send_resp(conn, 200, Jason.encode!(result))
  end

  get "filter/less/datos/:value" do
    
    #query_params = conn.query_params
    #filter = Map.get(query_params, "filter", "default")

    IO.puts("Buscando dato para valores menores que: #{value}")

    result = Orquestador.find_by_value(value, "<")
    send_resp(conn, 200, Jason.encode!(result))
  end

  post "/datos" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    data = Jason.decode!(body)
    key = data["key"]
    value = data["value"]

    IO.puts("Insertando clave: #{key} y valor: #{value}")

    case Orquestador.insert(key, value) do
      :ok -> send_resp(conn, 201, "Created")
      :error -> send_resp(conn, 409, "Stack overflow")
    end
  end

  match _ do
    send_resp(conn, 400, "Bad Request")
  end
end

# Curl examples
# curl -X GET localhost:<PORT>/datos/b
# curl -X POST localhost:<PORT>/datos --data '{"key":"b","value":"bbb"}'
