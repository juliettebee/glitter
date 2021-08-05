defmodule Gitserv.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, 200, "Welcome")
  end

  get "/r/:repo" do
    # Return repo
    send_resp(conn, 200, "Repo #{repo}")
  end

  forward "/g", to: Gitserv.Git_plug 
  
  forward "/a", to: Gitserv.Api_plug

end
