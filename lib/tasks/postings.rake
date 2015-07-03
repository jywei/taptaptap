namespace :postings do
  desc "truncate posting_validation_infos table"
  task :truncate_validations do
    ActiveRecord::Base.connection.execute("TRUNCATE posting_validation_infos;")
  end

  desc "initialize multitable functionality"
  task :init_multitables, [:first_volume] => :environment do |t, args|
    first_volume = args[:first_volume].to_i
    connection = Mysql2::Client.new(
        {host: 'localhost'}.merge(ActiveRecord::Base.connection_config).except(:adapter)
    )
    connection.query(SystemData.create_table_script(first_volume))
    connection.query("UPDATE current_volume SET volume=#{first_volume};")
    connection.query(SystemData.create_table_script(first_volume+1))
  end

  desc "extract annotations to a separate table"
  task :extract_annotations => :environment do |_, args|
    Posting.table_name = "postings#{ Posting2.current_volume }"

    postings = Posting.all.load
    progress = 0

    puts "Importing annotations..."

    postings.each do |posting|
      progress += 1

      next if posting.annotations.blank?

      posting.annotations.each do |name, value|
        if a = Annotation.where(name: name).first
          a.categories << posting.category
          a.categories.uniq!
          a.category_groups << posting.category_group
          a.category_groups.uniq!
          a.sources << posting.source
          a.sources.uniq!
          a.options << value
          a.options.uniq!
          a.save
        else
          Annotation.create name: name, categories: [posting.category], category_groups: [posting.category_group], sources: [posting.source], options: [value] rescue nil
        end
      end

      print "\r"
      print "Processed #{ progress } out of #{ postings.count } postings"
    end

    puts "\nExtracted #{ Annotation.count } annotations"
  end
end
