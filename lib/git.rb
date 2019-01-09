class Git
  attr_reader :dirty, :staged, :untracked

  def initialize
    @active = git_dir?
    @unmodified = 0
    @dirty = 0
    @staged = 0
    @untracked = 0
    parse(`git status --porcelain`) if @active
  end

  def active?
    @active
  end

  def git_dir?
    system('git rev-parse --short HEAD >/dev/null 2>&1')
  end

  def dirty?
    @active && @dirty > 0
  end

  def staged?
    @active && @staged > 0
  end

  def untracked?
    @active && @untracked > 0
  end

  def clean?
    @active && @dirty == 0 && @staged == 0
  end

  def branch
    return '' unless active?
    @branch ||= `git branch | grep \\* | cut -d ' ' -f2`.delete("\n")
  end

  def parse(status)
    status.each_line do |line|
      index = line[0]
      work = line[1]
      if index == " " && work == " "
        @unmodified += 1
      elsif index == "?" || work == "?"
        @untracked += 1
      else
        if work != " "
          @dirty += 1
        elsif index != " "
          @staged += 1
        end
      end
    end
  end
end
