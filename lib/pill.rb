require_relative 'segment'
require_relative 'util'

# Class that holds information about a pill
class Pill
  attr_accessor :background, :foreground, :foreground_icon,
                :icon, :foreground_text, :text

  def initialize(background, foreground_icon, icon, foreground_text = '',
                 text = '')
    @background = background
    @foreground = background.tr('K', 'F')
    @foreground_icon = foreground_icon
    @icon = icon
    @foreground_text = foreground_text
    @text = text
  end

  def segment
    Segment.new(@background, ' ' + @foreground_icon + @icon + ' ' + @foreground_text + @text + ' ')
  end
end

class GitPill
  include Util

  def initialize(config)
    @config = config
  end

  def segment
    if git_dir?
      Segment.new(background_color, text)
    else
      BlankSegment.new
    end
  end

  def background_color
    color =
      if git_modified?
        @config['background_color_dirty']
      else
        @config['background_color_clean']
      end
    bg_color(color)
  end

  def text
    foreground_icon = fg_color(@config['icon']['color'])
    [
      '',
      foreground_icon + @config['icon']['char'],
      git_branch_name,
      git_dirty_text,
      git_untracked_text,
      git_staged_text,
      '',
    ].compact.join(' ')
  end

  def git_dir?
    system('git rev-parse --short HEAD >/dev/null 2>&1')
  end

  def git_branch_name
    `git branch | grep \\* | cut -d ' ' -f2`.delete("\n")
  end

  def git_modified?
    !`git status --porcelain -uno`.empty?
  end

  def git_dirty_text
    if git_modified?
      fg_color(@config['icon']['dirty']['color']) << @config['icon']['dirty']['char']
    else
      nil
    end
  end

  def git_untracked_text
    untracked = `git ls-files --other --exclude-standard --directory --no-empty-directory 2>/dev/null`.chomp
    if untracked == ''
      nil
    else
      fg_color(@config['icon']['untracked']['color']) << @config['icon']['untracked']['char']
    end
  end

  def git_staged_text
    staged = !system('git diff --cached --no-ext-diff --quiet --exit-code 2>/dev/null')
    if staged
      fg_color(@config['icon']['staged']['color']) << @config['icon']['staged']['char']
    else
      nil
    end
  end
end
