class NewAnnotationsRunner
  STOP_FILE = "log/kill_new_annotations_runner.txt"

  def self.process(annotations, category, source)
    category_group = PostingConstants::CATEGORY_RELATIONS_REVERSE[category]

    annotations.each do |name, value|
      annotation = Annotation.find_by name: name

      if Annotation::ALLOWED_OPTIONS.include?(name.downcase)
        options = value.split('|')
      else
        options = []
      end

      if annotation.blank?
        Annotation.create name: name,
                          categories: [ category ],
                          category_groups: [ category_group ],
                          sources: [ source ],
                          sent_as_annotation: true,
                          options: options
      else
        annotation.categories << category
        annotation.categories.uniq!

        annotation.category_groups << category_group
        annotation.category_groups.uniq!

        annotation.sources << source
        annotation.sources.uniq!

        annotation.options += options
        annotation.options.uniq!

        annotation.sent_as_annotation = true

        annotation.save
      end
    end
  end

  def self.perform
    raise "Annotations processing is disabled programmatically. Please, set Annotation::PROCESSING_ENABLED to true to start processing." unless Annotation::PROCESSING_ENABLED

    while true do
      count = 0

      # rework to either select or redis queue + select
      while RedisHelper.get_redis.llen(Annotation::QUEUE_NAME) > 0 and count < 1000
        count += 1
        id = RedisHelper.get_redis.lpop(Annotation::QUEUE_NAME)
        volume = Posting2.volume_by_id(id)
        Posting.table_name = "postings#{volume}"
        posting = Posting.find(id)

        process(posting[:annotations], posting[:category], posting[:source])
      end

      p "Processed #{ count } postings"

      if File.exists?(STOP_FILE)
        puts "Removing #{ STOP_FILE } file and stopping the loop"
        %x[rm -f #{ STOP_FILE }]
        break
      end

      sleep 1.minute
    end
  end
end
