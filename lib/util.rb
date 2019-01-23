# Utilities that helps with the theme
require 'pathname'

module Util
  def current_os
    `uname -s`
  end

  def darwin?
    current_os.chomp == 'Darwin'
  end

  def linux?
    current_os.chomp == 'Linux'
  end

  def clean_str(str)
    str.gsub(/\%f|%k|%F{\d+}|%K{\d+}/, '')
  end

  def fg_color(color)
    "%F{#{color}}"
  end

  def bg_color(color)
    "%K{#{color}}"
  end

  def shorten_path(path, git_path, segments = 3)
    path = File.expand_path(path)
    if git_path.nil?
      path = path.gsub(%r{^#{ENV['HOME']}}, "~")
      parts = path.split('/').reverse
      keep = parts.slice(0, segments)
      reduce = (parts.slice(segments, parts.length) || []).map { |p| p[0] || "" }
      (keep + reduce).reverse.join("/")
    else
      base = Pathname.new(path)
      name = File.basename(git_path)
      relative = File.join(name, base.relative_path_from(Pathname.new(git_path))).sub(/\/\.$/, '')
      root = File.dirname(git_path).gsub(%r{^#{ENV['HOME']}}, "~").split('/').map { |p| p[0] || "" }.join('/')
      File.join(root, relative)
    end
  end
end
