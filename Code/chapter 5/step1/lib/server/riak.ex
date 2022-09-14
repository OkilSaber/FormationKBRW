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

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
  end

  def create(bucket, "application/json", keys, data) do
    Logger.info("Creating in #{bucket} with #{keys} and #{inspect(data)} as application/json")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys/#{keys}',
      Server.Riak.auth_header(),
      'application/json',
      Poison.encode!(data)
    }

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
  end

  def create_bucket(bucket_name, props) do
    Logger.info("Creating bucket #{bucket_name}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket_name}/props',
      Server.Riak.auth_header(),
      'application/json',
      Poison.encode!(%{props: props})
    }

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
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

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
  end

  def get_buckets do
    Logger.info("Getting buckets")

    http_options = {
      '#{Server.Riak.url()}/buckets?buckets=true',
      Server.Riak.auth_header()
    }

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
  end

  def get_bucket(bucket) do
    Logger.info("Getting bucket #{bucket}")

    http_options = {
      '#{Server.Riak.url()}/buckets/#{bucket}/keys?keys=true?',
      Server.Riak.auth_header()
    }

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
  end

  def get_schema(name) do
    Logger.info("Getting schema #{name}")

    http_options = {
      '#{Server.Riak.url()}/search/schema/#{name}',
      Server.Riak.auth_header()
    }

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:get, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
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

    {reponse, {{_, _code, _message},_options, body}} = :httpc.request(:put, http_options, [], [])
    Logger.info("Response: #{reponse}")
    Logger.info("Body: #{body}")
    body
  end
end
