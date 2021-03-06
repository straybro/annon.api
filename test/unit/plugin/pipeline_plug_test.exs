# TODO: Move to api pipeline tests
# defmodule Annon.Plugin.APILoaderTest do
#   @moduledoc false
#   use Annon.UnitCase
#   alias Annon.Factories.Configuration, as: ConfigurationFactory

#   describe "writes config to conn.private" do
#     test "with plugins" do
#       %{request: request} = api = ConfigurationFactory.insert(:api)
#       ConfigurationFactory.insert(:jwt_plugin, api: api)
#       ConfigurationFactory.insert(:acl_plugin, api: api)

#       %{private: %{api_config: %{} = config}} =
#         :get
#         |> conn(request.path, Poison.encode!(%{}))
#         |> Map.put(:host, request.host)
#         |> Map.put(:port, request.port)
#         |> Map.put(:method, request.methods |> hd())
#         |> Map.put(:scheme, request.scheme)
#         |> Annon.Plugin.APILoader.call([])

#       assert config.id == api.id
#       assert config.request == request
#       assert length(config.plugins) == 2
#     end

#     test "without plugins" do
#       %{request: request} = ConfigurationFactory.insert(:api)

#       %{private: %{api_config: nil}} =
#         :get
#         |> conn(request.path, Poison.encode!(%{}))
#         |> Map.put(:host, request.host)
#         |> Map.put(:port, request.port)
#         |> Map.put(:method, request.methods |> hd())
#         |> Map.put(:scheme, request.scheme)
#         |> Annon.Plugin.APILoader.call([])
#     end
#   end

#   describe "find API by request" do
#     test "with matching by path" do
#       api = ConfigurationFactory.insert(:api, %{
#         name: "API loader Test api",
#         request: ConfigurationFactory.build(:api_request, %{
#           methods: ["GET"],
#           scheme: "http",
#           host: "www.example.com",
#           port: 80,
#           path: "/mockbin",
#         })
#       })

#       ConfigurationFactory.insert(:proxy_plugin, %{
#         name: "proxy",
#         is_enabled: true,
#         api: api,
#         settings: %{
#           strip_api_path: false,
#           method: "GET",
#           scheme: "http",
#           host: "localhost",
#           port: 4040,
#           path: "/apis"
#         }
#       })

#       assert 404 == call_public_router("/some_path").status
#       assert 200 == call_public_router("/mockbin").status
#       assert 200 == call_public_router("/mockbin/path").status

#       assert "http://localhost:4040/apis/mockbin" == "/mockbin"
#       |> call_public_router()
#       |> get_from_body(["meta", "url"])

#       assert "http://localhost:4040/apis/mockbin/path" == "/mockbin/path"
#       |> call_public_router()
#       |> get_from_body(["meta", "url"])
#     end

#     test "with matching by overrided host" do
#       api = ConfigurationFactory.insert(:api, %{
#         name: "API loader Test api",
#         request: ConfigurationFactory.build(:api_request, %{
#           methods: ["GET"],
#           scheme: "http",
#           host: "www.example.com",
#           port: 80,
#           path: "/mockbin",
#         })
#       })

#       ConfigurationFactory.insert(:proxy_plugin, %{
#         name: "proxy",
#         is_enabled: true,
#         api: api,
#         settings: %{
#           strip_request_path: false,
#           method: "GET",
#           scheme: "http",
#           host: "localhost",
#           port: 4040,
#           path: "/apis"
#         }
#       })

#       resp = :get
#       |> conn("/mockbin")
#       |> put_req_header("content-type", "application/json")
#       |> Map.put(:host, "other_host")
#       |> Annon.PublicAPI.Router.call([])

#       assert 404 == resp.status

#       resp = :get
#       |> conn("/mockbin")
#       |> put_req_header("content-type", "application/json")
#       |> put_req_header("x-host-override", "www.example.com")
#       |> Map.put(:host, "other_host")
#       |> Annon.PublicAPI.Router.call([])

#       assert 200 == resp.status
#     end
#   end

#   defp get_from_body(response, what_to_get) do
#     response
#     |> Map.get(:resp_body)
#     |> Poison.decode!()
#     |> get_in(what_to_get)
#   end
# end
