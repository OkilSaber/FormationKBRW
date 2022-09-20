defmodule Server.Riak do
  require Logger
  require Poison
  def url, do: "https://kbrw-sb-tutoex-riak-gateway.kbrw.fr"

  def auth_header do
    username = "sophomore"
    password = "jlessthan3tutoex"
    auth = :base64.encode_to_string("#{username}:#{password}")
    [{'authorization', 'Basic #{auth}'}]
  end

  def create(bucket, "text/plain", keys, data) do
    Logger.info("Creating in #{bucket} with #{keys} and #{data} as text/plain")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys/#{keys}',
      Server.Riak.auth_header(),
      'text/plain',
      data
    }

    {response, {{_, _code, _message}, _options, _body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{response}")
    response
  end

  def create(bucket, "application/json", keys, data) do
    Logger.info("Creating in #{bucket} with #{keys} and #{inspect(data)} as application/json")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys/#{keys}',
      Server.Riak.auth_header(),
      'application/json',
      Poison.encode!(data)
    }

    {response, {{_, _code, _message}, _options, _body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{response}")
    response
  end

  def create_bucket(bucket_name, props) do
    Logger.info("Creating bucket #{bucket_name}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket_name}/props',
      Server.Riak.auth_header(),
      'application/json',
      Poison.encode!(%{props: props})
    }

    {response, {{_, _code, _message}, _options, _body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{response}")
    response
  end

  def create_schema(name, path) do
    Logger.info("Creating schema #{name} with path #{path}")
    file_contents = File.read!(path)

    http_options = {
      '#{Server.Riak.url()}/search/schema/#{name}',
      Server.Riak.auth_header(),
      'application/xml',
      file_contents
    }

    {response, {{_, _code, _message}, _options, _body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{response}")
    response
  end

  def get_buckets do
    Logger.info("Getting buckets")

    http_options = {
      '#{Server.Riak.url()}/buckets?buckets=true',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")
    body
  end

  def get_bucket_keys(bucket) do
    Logger.info("Getting bucket #{bucket}'s keys")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys?keys=true',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")
    body
  end

  def get_key_data(bucket, key) do
    Logger.info("Getting bucket #{bucket}'s key #{key}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys/#{key}',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")
    body
  end

  def get_schema(name) do
    Logger.info("Getting schema #{name}")

    http_options = {
      '#{Server.Riak.url()}/search/schema/#{name}',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")
    body
  end

  def index_schema(index_name, schema_name) do
    Logger.info("Indexing schema #{schema_name} to index #{index_name}")

    http_options = {
      '#{Server.Riak.url()}/search/index/#{index_name}',
      Server.Riak.auth_header(),
      'application/json',
      Poison.encode!(%{schema: schema_name})
    }

    {response, {{_, _code, _message}, _options, _body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{response}")
    response
  end

  def get_all_indexes do
    Logger.info("Getting all indexes")

    http_options = {
      '#{Server.Riak.url()}/search/index',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")
    body
  end

  def delete_bucket(bucket) do
    Logger.info("Deleting bucket #{bucket}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/props',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, _body}} = :httpc.request(:delete, http_options, [], [])
    Logger.info("Response: #{response}")
    response
  end

  def delete_key(bucket, key) do
    Logger.info("Deleting key #{key} from bucket #{bucket}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys/#{key}',
      Server.Riak.auth_header()
    }

    {response, {{_, code, message}, _options, _body}} =
      :httpc.request(:delete, http_options, [], [])

    Logger.info("Response: #{response}")
    Logger.info("Code: #{code}")
    Logger.info("Message: #{message}")
    response
  end

  def empty_bucket(bucket) do
    Logger.info("Emptying bucket #{bucket}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys?keys=true',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")

    keys = Poison.decode!(body)
    keys = keys["keys"]

    for key <- keys do
      Logger.info("Deleting key #{key}")
      delete_key(bucket, key)
    end
  end

  def escape(string) do
    :http_uri.encode(string)
  end

  def search(index, query, page, rows, sort) do
    Logger.info("Searching index #{index}")

    http_options = {
      '#{Server.Riak.url()}/search/query/#{index}?wt=json&q=#{query}&start=#{page}&rows=#{rows}&sort=#{sort}',
      Server.Riak.auth_header()
    }

    {response, {{_, _code, _message}, _options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{response}")
    Poison.decode!(body)
  end
end
