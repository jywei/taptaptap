json.array!(@postings) do |posting|
  json.extract! posting, :source, :category, :location, :external_id, :external_url, :heading, :body, :html, :expires, :language, :price, :currency, :images, :annotation, :status, :flagged, :deleted, :immortal
  json.url posting_url(posting, format: :json)
end
