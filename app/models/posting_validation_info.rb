class PostingValidationInfo < ActiveRecord::Base
  class << self
    def insert_from_hash(e)
      time = Time.now.to_s(:db)

      str = if e.respond_to?(:messages)
              e.messages.keys.map { |attr| "`#{ attr }`=FALSE" }.join(',')
            else
              e.keys.map { |attr| "`#{ attr }`=FALSE" }.join(',')
            end

      q = %Q(
              INSERT INTO posting_validation_infos
              SET
                posting_id=NULL,
              created_at='#{time}',
              updated_at='#{time}',
                #{ str };
            )

      connection.execute q
    end
  end
end
