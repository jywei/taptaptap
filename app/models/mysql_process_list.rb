class MysqlProcessList
  def initialize
    @result = Posting2.connection.query("show full processlist;")
  end

  def count
    @result.count
  end

  def list
    @list ||= begin
      a = []
      @result.each do |row|
        a << row
      end
      a
    end
  end

  def text
    text = ''

    text << '<br>'
    text << list.first.keys.join(' | ')
    list.each do |e|
      text << '<br>'
      text << e.values.join(' | ')
    end

    text
  end
end