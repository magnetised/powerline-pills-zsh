class Git
  attr_reader :dirty, :staged, :untracked

  def initialize
    @active = git_dir?
    @unmodified = 0
    @dirty = 0
    @staged = 0
    @untracked = 0
    @ref_name = ''
    if @active
      parse(`git status --porcelain`)
      @ref_type, @ref_name = parse_branch
    end
  end

  def active?
    @active
  end

  def git_dir?
    system('git rev-parse --short HEAD >/dev/null 2>&1')
  end

  def git_dir
    return nil unless @active
    @git_dir ||= `git rev-parse --show-toplevel`.chomp
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

  def branch?
    @active && @ref_type == :branch
  end

  def tag?
    @active && @ref_type == :tag
  end

  def detached?
    @active && @ref_type == :detached
  end

  def ref_name(length = -1)
    name = @ref_name[0..length]
    if name.length < @ref_name.length
      "#{name}…"
    else
      name
    end
  end

  def parse_branch
    success, ref = runcmd('git symbolic-ref HEAD 2>/dev/null')
    if success
      return [:branch, ref.sub(/^refs\/heads\//, '')]
    end

    success, ref = runcmd('git describe --tags --exact-match 2>/dev/null')
    if success
      return [:tag, ref]
    end

    _success, ref = runcmd('git show-ref --head -s --abbrev | head -n1 2>/dev/null')
    return [:detached, ref]
  end

  def runcmd(cmd)
    result = %x[#{cmd}].chomp
    [$?.success?, result]
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
