get '/db/dump.json' do #This will cause problems when the database (in json format) is bigger than the memory of the site
  error 404 unless params[:pass] == "OMGthisIsAsoupers33cr3tp4sswordOMG"
  content_type 'application/json', :encoding => "utf-8"
  tables = DB.tables
  hash_db = Hash[ tables.zip( tables.map{|t| DB[t].all} ) ]
  JSON.generate(hash_db)
end
