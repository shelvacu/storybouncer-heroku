require 'sequel'
require 'jdbc/postgres'

def getarray(id)
  return DB[:"array#{id}"]
end
def makearray(type = Integer,name = :val)
  id = DB[:array].insert
  DB.create_table(:"array#{id}") do
    primary_key :id
    column name, type
  end
  return id
end
#DB = Sequel.connect(ENV['JUSTONEDB_DBI_URL'].gsub("postgres:","jdbc:postgresql") || 'jdbc:sqlite:local.db')
if (url = ENV['JUSTONEDB_DBI_URL'])
  m = url.match(/:\/\/(?<user>\w+):(?<pass>\w+)@(?<else>.*)/)
  DB = Sequel.connect("jdbc:postgresql://#{m[:else]}?user=#{m[:user]}&password=#{m[:pass]}")
else
  require 'jdbc/sqlite3'
  Jdbc::SQLite3.load_driver
  DB = Sequel.connect("jdbc:sqlite:local.db")
end

class TableDoesntExist < StandardError
end

class DBItem
  def initialize(id,get_cache,tablename)
    @id = id
    @tablename = tablename
    @table = DB[tablename]
    @cache = nil #initialize, not sure if this is neccecary
    raise TableDoesntExist unless DB.tables.include? @tablename
    update_cache if get_cache
  end
  
  def getall
    @cache = @table.first(id:@id)
  end
  alias update_cache getall
  
  def getcache
    @cache
  end
  
  def getattr(name, fromcache = false)
    if fromcache
      update_cache if @cache.nil
      return @cache[name]
    else
      #getall[name]
      @table.select(name).first(id:@id)[name]
    end
  end
  alias get getattr
  alias [] getattr
end

module VotableItem
  def votes_set(up_down) # TRUE: UP / FALSE: DOWN
    getarray(self[(up_down ? :upvotes : :downvotes)])
  end

  def numvotes(up_down)
    votes_set(up_down).count
  end
  
  def votes(up_down)
    votes_set(up_down).all
  end
  
  def users(up_down)
    votes(up_down).each do |set|
      id = set[:val]
      User.new(id)
    end
  end
end
class Para < DBItem
  
  include VoteableItem
  
  def initialize(id,get)
    super(id,get,:para)
  end

  def auth
    Auth.new(self[:auth])
  end
  alias author auth
end
class Chap < DBItem
  def name
    self[:name]
  end
  def
