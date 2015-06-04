class ExpiredTasks
  @queue = :task4
  
  def self.perform
    f=File.open('/Users/sameer/tmp/tmp.txt', 'a')
    f.puts "#{Time.now}: In ExpiredTasks perform"
    f.close
  end

end
