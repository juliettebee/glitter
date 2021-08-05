defmodule Gitserv.Api_plug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) when hd(conn.path_info) == "new" and conn.method == "POST" do
    conn = Plug.Conn.fetch_query_params(conn)
    name = conn.query_params["name"]

    {result, num} = System.cmd("git", ["init", "--bare", "#{File.cwd!()}/g/#{name}"])

    if num == 0 do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Created")
    else
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(500, "Unable to create, reason given: #{result}")
    end
  end

  def call(conn, _opts) when hd(conn.path_info) == "rm" and conn.method == "POST" do
    conn = Plug.Conn.fetch_query_params(conn)
    name = conn.query_params["name"]

    try do
      File.rm_rf!("#{File.cwd!()}/g/#{name}")
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Deleted")
    rescue 
      _e in File.Error -> conn
      |> put_resp_content_type("text/plain")
      |> send_resp(500, "Unable to delete")
    end
  end
end
