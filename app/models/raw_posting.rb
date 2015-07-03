class RawPosting < ActiveRecord::Base
  MODEL_VALIDATION = 0
  CONVERTER_VALIDATION = 1

  belongs_to :posting

  scope :rejected, -> { where('rejected = 1') }
  scope :rejected_by_model, -> { where(validation_module: MODEL_VALIDATION)}
  scope :rejected_by_converter, -> { where(validation_module: CONVERTER_VALIDATION)}

  class << self
    def insert_from_hash(posting, validation_module, error_messages, warning_messages, posting_id = nil)
      data = Remote::Normalizer.new(posting).normalize

      data[:rejected] = 0 if error_messages.blank?

      p "raw posting insert from hash"
      p data

      posting_id ||= 'NULL'

      q = %Q(
            INSERT INTO raw_postings
            SET #{ data.map{ |attr, value| "`#{ attr }`='#{ value }'" }.join(',') },
              `posting_id` = #{posting_id},
              `text` = #{sanitize(posting.to_yaml)},
              `validation_module` = #{validation_module},
              `error_messages` = '#{error_messages.join(';')}',
              `warning_messages` = '#{warning_messages.join(';')}';
          )

      connection.execute q

      id = connection.execute("SELECT LAST_INSERT_ID();").to_a.first.first
    rescue Exception => e
      SULO4.error e.inspect
      # SULO4.error e.message
      # SULO4.error q
    end

    def update_messages_for(id, errors, warnings)
      return unless id.present?

      q = %Q(
      UPDATE raw_postings
      SET
        `error_messages` = IF(`error_messages` IS NULL, #{ sanitize(errors.join ';') }, CONCAT(`error_messages`, #{ sanitize(errors.join ';') })),
        `warning_messages` = IF(`warning_messages` IS NULL, #{ sanitize(warnings.join ';') }, CONCAT(`warning_messages`, #{ sanitize(warnings.join ';') }))
      WHERE `id` = #{ id };
      )

      connection.execute q
    end
  end
end
