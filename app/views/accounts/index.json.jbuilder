json.array!(@accounts) do |account|
  json.extract! account, :id, :is_spammer, :name, :id
  json.url account_url(account, format: :json)
end
