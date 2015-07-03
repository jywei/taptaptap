class SourceAccount

  def self.get_count_craig(volume)
    
    q = <<-SQL
      SELECT 
          count(*) as total
      FROM 
          postings#{ volume }
      WHERE
          source = 'CRAIG'    
    SQL

    Posting2.connection.query(q).to_a.first
  end

  def self.get_count_craig_with_source_account(volume)
    
    q = <<-SQL
      SELECT 
          count(*) as total
      FROM 
          postings#{ volume }
      WHERE
          source = 'CRAIG' AND annotations LIKE '%source_account%'    
    SQL

    Posting2.connection.query(q).to_a.first
  end 

end