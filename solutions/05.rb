class Operation
  attr_reader :name, :message, :success, :error, :result, :proc

  def initialize(message, success: true, error: false, result: nil)
    @message, @success, @error, @result = message, success, error, result
  end

  def success?()
    @success
  end

  def error?()
    @error
  end
end

class ObjectsHash
  attr_accessor :objects

  def initialize()
    @objects = {}
  end

  def add(name, value)
    @objects[name] = value
  end

  def remove(name)
    @objects.delete name
  end
end

class Commit
  attr_accessor :date, :message, :hash, :objects
  def initialize(message, date, hash, objects)
    @date, @message, @hash, @objects = date, message, hash, objects
  end
end

class ObjectStore
  require 'digest/sha1'

  attr_reader :branch

  def initialize()
    @branch = Branch.new
    @working_directory = []
    instance_eval &Proc.new
  end

  def self.init(&block)
    ObjectStore.new &block
  end

  def add(name, object)
    message = "Added #{name} to stage."
    @working_directory << Proc.new { add(name, object) }
    Operation.new(message, result: object)
  end

  def commit(message)
    if @working_directory.empty?
      commit_message = "Nothing to commit, working directory clean."
    else
      commit_message = "#{message}\n\t#{@working_directory.count}" +
                       " objects changed"
    end
    @branch.push(message, @working_directory)
    @working_directory = []
    Operation.new(commit_message)
  end

  def remove(name)
    if branch.objects.objects.include? name
      message = "Added #{name} for removal."
    else
      message = "Object #{name} is not committed."
    end
    @working_directory << Proc.new { remove(name) }
    Operation.new(message)

  end

  def checkout(commit_hash)
    @branch.update(commit_hash)
  end

  #def log()
  #  if @branch.commit_history.empty?
  #    message = "Branch #{@branch.current_branch} " +
  #              "does not have any commits yet."
  #  else
  #    message = @branch
  #             .commit_history
  #             .reverse
  #             .map do |message, time, working_directory|
  #      "Commit " +
  #      Digest::SHA1.hexdigest("#{time.ctime}#{message}").to_s +
  #      "\nDate: #{time.ctime}\n\n\t#{message}\n\n"
  #    end.reduce(:+)
  #  end
  #  Operation.new(message)
  #end

  def head()
    latest_commit = @branch.commit_history.last
    time = latest_commit[1].ctime
    message = latest_commit[0]
    hash = Digest::SHA1.hexdigest("#{time}#{message}").to_s
    Commit.new(message, time, hash, @branch.objects)
  end

  def get(name)
  end

end

class Branch
  require 'date'

  attr_reader :current_branch, :commit_history

  def initialize()
    @commit_history = []
    @current_branch = "master"
    @branch = {@current_branch => ObjectsHash.new}
  end

  def objects()
    @branch[@current_branch]
  end

  def create(branch_name)
    @branch[branch_name] = @branch[@current_branch].dup
  end

  def checkout(branch_name)
    @current_branch = branch_name
  end

  def remove(branch_name)
    @branch.delete branch_name
  end

  def list()
    message = @branch.keys.sort.map do |branch|
      " " +
      ((branch == @current_branch) ? "*" : " ") +
      branch.to_s +
      "\n"
    end.reduce(:+)
    Operation.new(message)
  end

  def push(message, working_directory)
    time = Time.now
    @commit_history << [message, time, working_directory]
    working_directory.each do |operation|
      @branch[@current_branch].instance_eval &operation
    end
  end

  def update(commit_name)
    @branch[@current_branch] = ObjectsHash.new
    commit_index = @commit_history
                  .index { |commit, _, _| commit == commit_name }
    @commit_history = @commit_history[0..commit_index]
    @commit_history.each do |_, _, operation|
      operation.each do |change|
        @branch[@current_branch].instance_eval &change
      end
    end
  end
end