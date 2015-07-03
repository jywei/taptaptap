require 'fileutils'

paths = [
    File.join(Rails.root, %w(log custom bodies create)),
    File.join(Rails.root, %w(log custom traces))
]

paths.each { |p| FileUtils.mkdir_p(p) unless Dir.exists?(p) }

SULO = Logger.new("#{Rails.root}/log/custom/0.log")
SULO1 = Logger.new("#{Rails.root}/log/custom/1.log")
SULO2 = Logger.new("#{Rails.root}/log/custom/2.log")
SULO3 = Logger.new("#{Rails.root}/log/custom/3.log")
SULO4 = Logger.new("#{Rails.root}/log/custom/4.log")
SULO5 = Logger.new("#{Rails.root}/log/custom/5.log")
SULO6 = Logger.new("#{Rails.root}/log/custom/6.log")
SULO7 = Logger.new("#{Rails.root}/log/custom/7.log")
SULO8 = Logger.new("#{Rails.root}/log/custom/8.log")
SULO9 = Logger.new("#{Rails.root}/log/custom/9.log")
SULOEXC = Logger.new("#{Rails.root}/log/custom/exceptions.log")
LATENCY = Logger.new("#{Rails.root}/log/custom/latency_runner.log")
