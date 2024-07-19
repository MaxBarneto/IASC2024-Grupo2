defmodule KVServer do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/datos/:key" do
    IO.puts("Recibe un get con la clave: #{key}")

    # case DatoAgent.get(DatoRegistry, key) do
    #   {:ok, value} ->
    #     send_resp(conn, 200, value)
    #   :error ->
    #     send_resp(conn, 404, "Not Found")
    # end

    value = Orquestador.find(key)

    send_resp(conn, 200, value)
  end

  post "/datos/:key" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    IO.puts("Recibe un get con la clave: #{key} y valor: #{body}")
    #DatoAgent.insert(DatoRegistry, key, body)
    send_resp(conn, 201, "Created")
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
