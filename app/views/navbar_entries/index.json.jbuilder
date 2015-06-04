json.array!(@navbar_entries) do |navbar_entry|
  json.extract! navbar_entry, :title, :url
  json.url navbar_entry_url(navbar_entry, format: :json)
end
