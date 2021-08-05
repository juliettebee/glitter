defmodule GitservTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Gitserv.Router.init([])

  test "Create git repo" do
    conn = create_repo("test-repo") 

    assert conn.status == 200
    assert conn.resp_body == "Created"

    delete_repo("test-repo")
  end

  test "Delete git repo" do
    create_repo("test-repo-delete") 

    conn = delete_repo("test-repo-delete")
    assert conn.status == 200
    assert conn.resp_body == "Deleted" 
  end

  test "Push to remote" do
    create_repo("push-to-remote")

    # Creating local repo
    tmp = System.tmp_dir()

    {_result, _num} = System.cmd("git", ["init", "."], cd: tmp)

    File.write("#{tmp}testFile", "Hello")

    {_result, _num} = System.cmd("git", ["remote", "add", "origin", "http://localhost/g/push-to-remote"], cd: tmp)

    {_result, _num} = System.cmd("git", ["add", "."], cd: tmp)
    {_result, _num} = System.cmd("git", ["commit", "-m", "\"Test\""], cd: tmp)
    {_result, num} = System.cmd("git", ["push", "origin", "love"], cd: tmp)

    assert num == 0

    delete_repo("push-to-remote")
    File.rm_rf!(tmp)
  end

  defp create_repo(name) do
    conn(:post, "/a/new?name=#{name}")
    |> Gitserv.Router.call(@opts) 
  end

  defp delete_repo(name) do
    conn(:post, "/a/rm?name=#{name}")
    |> Gitserv.Router.call(@opts) 
  end
end
