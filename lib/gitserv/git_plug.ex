defmodule Gitserv.Git_plug do
  import Plug.Conn

  def init(options), do: options

  @doc """
  Only gets called when path is "/g/:repo/info/refs" this is needed because we need to run a command and return the response of that.
  """
  def call(conn, _opts) when tl(conn.path_info) == ["info", "refs"] and conn.method == "GET" do
    conn = Plug.Conn.fetch_query_params(conn)
    service = conn.query_params["service"]

    {result, _num} = System.cmd("git", [String.slice(service, 4..-1), "--advertise-refs", "#{File.cwd!()}/g/#{hd(conn.path_info)}"])

    ad = "# service=#{service}"
    ad_length = :io_lib.format("~4.16.0b", [String.length(ad) + 4])

    conn
    |> put_resp_content_type("application/x-#{service}-advertisement")
    |> send_resp(200, "#{ad_length}#{ad}0000#{result}")
  end

  def call(conn, _opts) when conn.method == "POST" do
    service = conn.path_info
              |> tl()
              |> hd()
              |> String.slice(4..-1)

    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    command = "git #{service} --stateless-rpc #{File.cwd!()}/g/#{hd(conn.path_info)}"
    p = Port.open({:spawn, command}, [:binary, :exit_status])
    Port.command(p, body) 
    result = recv()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, result)
  end

  def call(conn, _opts) when conn.method == "GET" do
    try do
      content_type = MIME.from_path(conn.request_path)
      content = File.read!(File.cwd! <> conn.request_path)
      conn
      |> put_resp_content_type(content_type)
      |> send_resp(200, content)
    rescue
      _e in File.Error -> conn
      |> put_resp_content_type("text/plain")
      |> send_resp(404, "")
    end
  end

  defp recv do
    recv("")
  end

  defp recv(data) do
    receive do
      {_port, {:data, newdata}} -> recv(data <> newdata)
      {_port, {:exit_status, _}} -> data
    end
  end

end
