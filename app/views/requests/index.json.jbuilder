json.array!(@requests) do |request|
  json.extract! request, :id, :query, :email, :start_time, :end_time, :results
  json.url request_url(request, format: :json)
end
