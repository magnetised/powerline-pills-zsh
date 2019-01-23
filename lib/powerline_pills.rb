#!/bin/env ruby
# encoding: utf-8

require 'yaml'
require_relative 'util'
require_relative 'pill'
require_relative 'segment'
require_relative 'git'
include Util

# VARS
mode = ARGV[0]
last_exit = ARGV[1] == '0'
username = ENV['USER']
size = `tput cols`.to_i

xdg_config_home = ENV["XDG_CONFIG_HOME"] || File.join(ENV["HOME"], ".config")

script_dir = File.expand_path("../..", __FILE__)

paths = [
  File.join(xdg_config_home, "powerline-pills"),
  File.join(xdg_config_home, "powerline_pills"),
  script_dir,
]

path =
  paths
    .map { |dir| File.join(dir, "config.yml") }
    .find { |path|  File.exist?(path) }

config = YAML.load_file(path)

date_format = config['date']['format']
cur_date = `date +#{date_format}`.to_s.chomp
config_left_top = config['base']['left_top']
config_right_top = config['base']['right_top']
config_left_bottom = config['base']['left_bottom']

# ICONS
powerline_icon_right = config['base']['powerline_icon_right']
powerline_icon_left = config['base']['powerline_icon_left']
icon_linux = config['os']['icon_linux']
icon_darwin = config['os']['icon_darwin']
icon_os = linux? ? icon_linux : icon_darwin
icon_user = config['user']['icon']['char']
icon_folder = config['folder']['icon']['char']
icon_git_dirty = config['git_dirty']['icon']['char']
icon_date = config['date']['icon']['char']
icon_bash = config['cmd']['icon']['char']

background_os = bg_color(config['os']['background_color'])
foreground_os = fg_color(config['os']['color'])

background_user = bg_color(config['user']['background_color'])
foreground_icon_user = fg_color(config['user']['icon']['color'])
foreground_user = fg_color(config['user']['color'])

background_folder = bg_color(config['folder']['background_color'])
foreground_icon_folder = fg_color(config['folder']['icon']['color'])
foreground_folder = fg_color(config['folder']['color'])

background_date = bg_color(config['date']['background_color'])
foreground_icon_date = fg_color(config['date']['icon']['color'])
foreground_date = fg_color(config['date']['color'])

background_cmd_failed = bg_color(config['cmd']['background_color_failed'])
foreground_cmd_failed = fg_color(config['cmd']['color_failed'])
background_cmd_success = bg_color(config['cmd']['background_color_success'])
foreground_cmd_success = fg_color(config['cmd']['color_success'])

background_reset = '%f%k'
color = fg_color(config['base']['color'])

background_git_dirty = bg_color(config['git_dirty']['background_color'])
foreground_icon_git_dirty = fg_color(config['git_dirty']['icon']['color'])
foreground_git_dirty = fg_color(config['git_dirty']['color'])

git = Git.new
dir = shorten_path(Dir.pwd, git.git_dir)

# PILLS
insert_mode_pill = OptionalPill.new(mode != 'vicmd', config['insert_mode'])
normal_mode_pill = OptionalPill.new(mode == 'vicmd', config['normal_mode'])

os_pill = Pill.new(background_os, foreground_os, icon_os)

user_pill = Pill.new(background_user, foreground_icon_user, icon_user,
                     foreground_user, username)

folder_pill = Pill.new(background_folder, foreground_icon_folder, icon_folder,
                       foreground_folder, dir)

git_branch_pill = OptionalPill.new(git.branch?, config['git_branch'], git.ref_name(30))
git_tag_pill = OptionalPill.new(git.tag?, config['git_tag'], git.ref_name(30))
git_detached_pill = OptionalPill.new(git.detached?, config['git_detached'], git.ref_name(30))
git_dirty_pill = OptionalPill.new(git.dirty?, config['git_dirty'], git.dirty)
git_staged_pill = OptionalPill.new(git.staged?, config['git_staged'], git.staged)
git_untracked_pill = OptionalPill.new(git.untracked?, config['git_untracked'], git.untracked)

date_pill = Pill.new(background_date, foreground_icon_date, icon_date,
                     foreground_date, cur_date)

background_cmd = last_exit ? background_cmd_success : background_cmd_failed
foreground_cmd = last_exit ? foreground_cmd_success : foreground_cmd_failed
cmd_pill = Pill.new(background_cmd, foreground_cmd, icon_bash)

pill_names = {
  insert_mode: insert_mode_pill,
  normal_mode: normal_mode_pill,
  os: os_pill,
  user: user_pill,
  folder: folder_pill,
  git_branch: git_branch_pill,
  git_tag: git_tag_pill,
  git_detached: git_detached_pill,
  git_dirty: git_dirty_pill,
  git_staged: git_staged_pill,
  git_untracked: git_untracked_pill,
  date: date_pill,
  cmd: cmd_pill
}

left_top = []
right_top = []
left_bottom = []

config_left_top.each do |clt|
  left_top.push(pill_names[clt.to_sym]) unless pill_names[clt.to_sym].nil?
end

config_right_top.each do |crt|
  right_top.push(pill_names[crt.to_sym]) unless pill_names[crt.to_sym].nil?
end

config_left_bottom.each do |clb|
  left_bottom.push(pill_names[clb.to_sym]) unless pill_names[clb.to_sym].nil?
end

def render_segments(pills, icon_left, icon_right)
  segments = pills.map(&:segment).compact
  ([BlankSegment.new] + segments).zip(segments + [BlankSegment.new]).map do |prev, current|
    current.join(prev, icon_left, icon_right)
  end.join('')
end

# LEFT (TOP)
str_left_top = render_segments(left_top, powerline_icon_left, powerline_icon_right)

# RIGHT (TOP)
str_right_top = render_segments(right_top, powerline_icon_left, powerline_icon_right)

# LEFT (BOTTOM)
str_left_bottom = render_segments(left_bottom, powerline_icon_left, powerline_icon_right)

spaces = size - (clean_str(str_left_top).size + clean_str(str_right_top).size)
spaces = 0 if spaces < 0
puts str_left_top + (' ' * spaces) + str_right_top + str_left_bottom + ' ' +
     background_reset + color
