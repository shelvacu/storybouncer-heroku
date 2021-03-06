require './local_db'
require 'time'

module Boolean; end
class TrueClass; include Boolean; end
class FalseClass; include Boolean; end

def getarray(id)
  return DB[:"array#{id}"].order_by(:id)
end
def makearray(type = Integer,name = :val)
  id = DB[:array].insert
  DB.create_table(:"array#{id}") do
    primary_key :id
    column name, type
  end
  return id
end

class TableDoesntExist < StandardError
end
class ItemDoesntExist < StandardError
end

module ArrayIncludeable
  def def_attr_array(name,col_name=name,klass)
    self.send(:define_method,name) do
      DBArray.new(self[col_name],klass)
    end
  end
  alias def_array def_attr_array
end

class DBItem
  class << self
    def create(args = {},tablename = @tablename)
      #args = @@default_create.merge(args)
      s = args.map do |key,val|
        val = val.id if val.is_a?(DBItem)
        [key,val]
      end
      args = Hash[s]
      id = DB[tablename].insert(args)
      return self.new(id)
    end
    def all
      DB[tablename].select(:id).all.map{|o| self.new(o[:id])}
    end
    def columns
      DB[tablename].columns
    end
    attr_reader :tablename
  end
  @tablename = ""
  
  def tablename
    self.class.tablename
  end

  def initialize(id,get_cache = false)
    @id = id
    @table = DB[tablename]
    @cache = nil #initialize, not sure if this is neccecary
    raise TableDoesntExist, "table #{tablename.inspect} doesn't exist" unless DB.tables.include? tablename
    raise ItemDoesntExist, "Item with id #{id} doesn't exist" if @table.where(id:@id).empty?
    @table = @table.where(id:@id)
    update_cache if get_cache
  end
  
  attr_reader :id
  
  def ==(other)
    return false unless other.class == self.class
    self.id == other.id
  end
  
  def ===(other)
    self.id == other || self == other
  end

  def getall
    @cache = @table.first
  end
  alias update_cache getall
  
  def getcache
    @cache
  end
  
  def getattr(name, fromcache = false)
    if fromcache
      update_cache if @cache.nil
      return @cache[name] || getattr(name,false)
    else
      #getall[name]
      @table.select(name).first[name]
    end
  end
  alias get getattr
  alias [] getattr
  
  def setattr(name,val)
    @table.select(name).update(name => val)
  end
  alias set setattr
  alias []= setattr

  private
  class << self
    include ArrayIncludeable
    
    def column_reader(*args)
      raise ArgumentError if args.empty?
      args.each do |name|
        define_method(name) do
          self[name]
        end
      end
    end
    
    def column_writer(*args)
      raise ArgumentError if args.empty?
      args.each do |name|
        meth_name = (name.to_s + "=").to_sym
        define_method(meth_name) do |set_to|
          self[name] = set_to
        end
      end
    end
    
    def column_accessor(*args)
      column_reader(*args)
      column_writer(*args)
    end
  end
end

class DBArray
  include Enumerable
  def initialize(id,type) #`type' argument should be a subclass of DBItem
    @id = id
    @set = getarray(id)
    @type = type
  end
  attr_reader :id
  attr_reader :set

  def ==(other)
    return false unless other.class == self.class
    self.id == other.id
  end
  
  def ===(other)
    self.id == other || self == other
  end
  
  def all
    @set.all.map{|o| @type.new(o[:val])}
  end
  alias to_a all
  
  def all_order_rand
    @set.order_by{random{}}.all.map{|o| @type.new(o[:val])}
  end
  
  def <<(thing)
    if thing.is_a?(Integer)
      @set.insert(:val => thing)
    elsif thing.is_a?(@type)
      @set.insert(:val => thing.id)
    else
      raise ArgumentError, "'<<` must be given integer or type #{@type}"
    end
  end
  alias push <<

  def delete(thing)
    if thing.is_a?(Integer)
      @set.where(:val => thing).delete
    elsif thing.is_a?(@type)
      @set.where(:val => thing.id).delete
    else
      raise ArgumentError, "'delete` must be given integer or type #{@type}"
    end
  end
  alias remove delete
  
  def each(*args)
    self.all.each(*args)
  end
  
  def count
    @set.count
  end
  alias length count
  
  def include?(item)
    item = item.id if item.is_a?(DBItem)
    return (@set.where(:val => item).count) > 0
  end
  
  def [](index)
    ret = @set.order_by(:id).limit(1,index).first
    if ret.nil?
      return nil
    else
      return @type.new ret[:val]
    end
  end
  
  def []=(index,obj)
    obj = obj.id if obj.class == @type
    ret = @set.order_by(:id).limit(1,index).update(:val => obj)
    return (ret == 0 ? nil : obj)
  end
  
  def length
    @set.count
  end
  
  def last
    thing = @set.order_by(Sequel.desc(:id)).limit(1).first
    return nil if thing.nil?
    return @type.new thing[:val]
  end
end

class User < DBItem
end # Hack to get def_array to work in VotableItem. Votable requires User, User requires Votable, heres the fix. IM SORRY OKAY
class Para < DBItem;end
class Chap < DBItem;end
class Book < DBItem;end
class Name < DBItem;end


module VoteableItem
  class << self
    include ArrayIncludeable
  end

  def_array(:upvotes,User)
  def_array(:downvotes,User)
  def votes(up_down=nil)
    case up_down
    when true #up
      upvotes.all
    when false #down
      downvotes.all
    when nil #all
      upvotes.all + downvotes.all
    end
  end
  
  alias users votes
  
  def vote_count(up_down=nil)
    case up_down
    when true
      upvotes.count
    when false
      downvotes.count
    when nil
      upvotes.count - downvotes.count
    end
  end
    
  def can_vote?(uzer) # Returns whether or not a user is allowed to vote
    res = true
    users.each do |user|
      res = false if uzer == user
    end
    return res
  end
  alias can_vote can_vote?
  
  def voted_on(user) #What a user has voted, up(true),down(false), or hasn't voted (nil)
    return true if upvotes.include?(user)
    return false if downvotes.include?(user)
    return nil
  end
  
  def unvote(user) # Remove a vote
    upvotes.delete(user)
    downvotes.delete(user)
  end
  
  def re_vote(uzer,up_down) # Vote again & undo prev
    vote = voted_on(uzer)
    return vote if vote = up_down
    unvote(user)
    if up_down
      upvotes << user
    elsif up_down == false # make sure it isn't nil
      downvotes << user
    end
    up_down
  end
end


class Para < DBItem
  include VoteableItem
  @tablename = :paras
  
  def auth
    User.new(self[:auth])
  end
  alias author auth
   
  column_accessor :an
  alias authors_note an
  alias authors_note= an=
  
  column_accessor :text
  column_accessor :chapname
end



class Chap < DBItem
  class << self
    def create(opts = {})
      opts[:paras] ||= makearray
      super(opts)
    end
  end
  @tablename = :chaps
  
  column_accessor :name
  #def_array(:pnames,Name) #Eventual-e!
  def_array(:paras,Para)
  def namestr
    name.to_s
  end
  alias strname namestr
end
VotableItem = VoteableItem



class Book < DBItem
  class << self
    def create(opts)
      [:chaps,:pparas,:pnames].each{ |arr_name|
        opts[arr_name] ||= makearray
      }
      
      #req'd user,pass(md5),email, emailver
      super(opts)
    end
  end
  include VoteableItem
  @tablename = :books

  def get_subs
    DB[:subs].where(book_id:@id).all.map{|o| User.new(o[:user_id])}
  end
  def get_subs_length
    DB[:subs].where(book_id:@id).count
  end
  def add_sub(user)
    raise unless user.is_a?(User)
    DB[:subs].insert(book_id: @id,user_id: user.id)
  end

  def auth
    User.new(self[:auth])
  end
  alias author auth
  
  def_array(:chaps,Chap)
  def_array(:pparas,Para)
  def fin
    !!self[:fin]
  end
  alias finished fin
  alias fin? fin
  def fin=(bool)
    self[:fin] = !!bool
  end
  
  alias finished= fin=
    
  def_array(:pnames,Name)
  def name
    Name.new(self[:name])
  end
  
  def namestr
    name.name
  end
  alias strname namestr
  
  def inspect
    "#<Book: ##{id} \"#{namestr}\">"
  end
  alias to_s inspect
end

class User < DBItem
  class << self
    def create(opts)
      [:hist].each do |arr|
        opts[arr] ||= makearray
      end
      super(opts)
    end
    
    def from_name(name)
      t = DB[@tablename].where('lower("user") = ?',name.downcase).all
      return nil if t.empty?
      return self.new(t[0][:id])
    end
  end
  @tablename = :users

  def subs_dataset
    DB[:subs].where(user_id:@id)
  end
  def get_subs
    subs_dataset.all.map{|o| Book.new(o[:user_id])}
  end
  def get_subs_length
    subs_dataset.count
  end
  def add_sub(book)
    raise unless book.is_a?(Book)
    DB[:subs].insert(user_id: @id,book_id: book.id)
  end
  
  column_accessor :user,:pass,:email,:emailver,:auth,:ban,:reset
  alias name user
  alias name= user=
  alias username user
  alias password_reset reset
  
  def veri
    !!self[:veri]
  end
  alias veri? veri  
  
  def veri=(stuff)
    self[:veri] = !!stuff
  end
  def_array(:hist,Book)
  
  def calc_reputation
    total_votes = 0
    paras_written = DB[:paras].where(auth: user.id).all
    paras_written.each do |para|
      total_votes += Para.new(para[:id]).vote_count
    end
    return total_votes
  end
  
  def inspect
    "#<User ##{id} \"#{name}\">"
  end
end
class Name < DBItem
  class << self
    def create(opts)
      opts[:fin] ||= false
      super(opts)
    end
  end
  include VotableItem
  @tablename = :names
  
  def auth
    Auth.new(self[:auth])
  end
  
  def auth=(thing)
    if thing.is_a?(Auth)
      self[:auth] = thing.id
    elsif thing.is_a?(Integer)
      self[:auth] = thing
    else
      raise ArgumentError, "must be Integer or Auth"
    end
  end
  alias author auth
  alias author= auth=
  column_accessor :name
  def fin
    self[:fin] == 't'
  end
  def fin=(ob)
    self[:fin] = !!ob
  end  
end
