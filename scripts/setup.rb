#!/usr/bin/env ruby

require 'yaml'
require 'etc'
require 'English'
require 'optparse'
require 'fileutils'

class Hash
  def to_s
    "{" + keys.inject([]) do |a, key|
      a << "'#{key}' => '#{fetch(key)}'"
    end.join(', ') +"}"
  end
end

$options = {
  dotfiles: true
} 


$nfs_config = {
  atboot: 'false',
  options: '_netdev,user,noauto',
  type: 'nfs'
}

$ideaU = {
  title: 'IDEA_Ultimate',
  path: '/tmp/ideaU.tar.gz',
  extract_to: '/opt/ideaU',
  source: 'https://download-cf.jetbrains.com/idea/ideaIU-2017.3.3.tar.gz',
  creates: '/opt/ideaU/idea-IU-173.4301.25'
}

$ideaU_de = <<~HEREDOC
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate Edition
Icon=/opt/ideaU/idea-IU-173.4301.25/bin/idea.png
Exec="/opt/ideaU/idea-IU-173.4301.25/bin/idea.sh" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
HEREDOC

$rubymine_de = <<~HEREDOC
[Desktop Entry]
Version=1.0
Type=Application
Name=RubyMine
Icon=/opt/rubymine/RubyMine-2017.3.2/bin/RMlogo.svg
Exec="/opt/rubymine/RubyMine-2017.3.2/bin/rubymine.sh" %f
Comment=The Drive to Develop
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-rubymine
HEREDOC

$rubymine = {
  title: 'rubymine',
  path: '/tmp/rubymine.tar.gz',
  extract_to: '/opt/rubymine',
  source: 'https://download.jetbrains.com/ruby/RubyMine-2017.3.2.tar.gz',
  creates: '/opt/rubymine/RubyMine-2017.3.1'
}


OptionParser.new do |opts|
  opts.banner = "Usage: setup.rb [options] <datafile>"

  opts.on('--no-puppet', 'Don\'t Run Puppet') do 
    $options[:nopuppet] = true
  end
  opts.on('--no-dotfiles', 'Skip Dot files') do 
    $options[:dotfiles] = false
  end
end.parse!

def do_as(user, &block)
  # Find the user in the password database.
  u = (user.is_a?(Integer)) ? Etc.getpwuid(user) : Etc.getpwnam(user)
  pid = Process.fork do
    # We're in the child. Set the process's user ID.
    Process.uid = u.uid
    # Invoke the caller's block of code.
    block.call(user)
  end
  Process.waitpid pid
  $CHILD_STATUS.exitstatus
end


def git_config(user, details)
    Dir.chdir('/tmp') do
      system("sudo -u #{user} git config --global user.name \"#{details[:name]}\"")
      system("sudo -u #{user} git config --global user.email \"#{details[:email]}\"")
  end
end




def archive_heredoc(options,config)
  <<~HEREDOC
  file {'#{options[:extract_to]}':
    ensure => 'directory'
  }

  archive{'#{options[:title]}':
    ensure        => present,
    path          => '#{options[:path]}',
    cleanup       => true,
    extract       => true,
    extract_path  => '#{options[:extract_to]}',
    creates       => '#{options[:creates]}',
    source        => '#{options[:source]}',
    require       => File['#{options[:extract_to]}']
   }

  \$#{options[:title].downcase}_plugins = #{config[:plugins] ? config[:plugins].to_s : '{}' }
  
  \$#{options[:title].downcase}_plugins.each  | $plugin, $url | {
    archive{"{$title}_${plugin}_plugin":
      ensure        => present,
      path          => "/tmp/${title}_${plugin}.zip",
      cleanup       => true,
      extract       => true,
      extract_path  => '#{options[:creates]}/plugins/',
      creates       => "#{options[:creates]}/plugins/${plugin}",
      source        => $url,
    }
  }

  HEREDOC
end

def mount_heredoc(options, config)
  <<~HEREDOC
  file{'#{options['mountpoint']}':
    ensure => present,
    mode => '0777'
  }
  
  mount{'#{options['mountpoint']}':
    ensure  => present,
    atboot  => '#{config[:atboot]}',
    fstype  => '#{config[:type]}',
    device  => '#{options['device']}',
    options => '#{config[:options]}',
  }
  HEREDOC
end

def dotfile_script(user,dotfile_repo)
  <<~HEREDOC
    cd ~#{user}
    echo ".cfg" >> .gitignore
    git clone --bare #{dotfile_repo} \$HOME/.cfg > /dev/null 2>&1

    alias config="/usr/bin/git --git-dir=\$HOME/.cfg/ --work-tree=\$HOME"

    mkdir -p .config-backup
    config checkout > /dev/null 2>&1
    res=$?
    if [ $res = 0 ]; then
      echo "Checked out config.";
      else
        echo "Backing up pre-existing dot files.";
        config checkout 2>&1 | egrep "\\s+\\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    fi;
    config checkout > /dev/null
    config config status.showUntrackedFiles no
    sed -i 's/%USER%/#{user}/g' .bashrc
  HEREDOC
end

def dotfiles(user, repo)
  puts "Downloading Dotfiles from #{repo}"
  do_as user do
    script = dotfile_script(user, repo)
    env = { 'HOME' => "/home/#{user}" }
    system env ,script
  end
end

def create_user(user, details)
  pwd = "--password '#{details[:passwd]}'" if details[:passwd]
  res = system("useradd --groups docker,wheel -d /home/#{user} #{pwd} --create-home --uid #{details[:uid]} #{user}", :err => File::NULL)
  if res
    puts "#{ user } created!"
  else
    puts "#{ user } failed!"
  end
end

def symbolize_keys(hash)
  hash.inject({}){|result, (key, value)|
    new_key = case key
              when String then key.to_sym
              else key
              end
    new_value = case value
                when Hash then symbolize_keys(value)
                else value
                end
    result[new_key] = new_value
    result
  }
end

def validate_user(user,details)
  puts "Validating #{user}:"
  errs = 0
  unless details[:name] 
   puts "\t Needs name" ; errs+=1  
  end 
  unless details[:email] 
    puts "\t Needs Email" ; errs+=1 
  end

  unless details[:uid] && details[:uid].is_a?(Integer)
    puts "\t Needs a numeric uid" ; errs+=1 
  end
  errs 
end

def gen_puppet(config)
  puppet_file = '/tmp/extras.pp'
  File.open(puppet_file, 'w') do |file|
    file.write archive_heredoc($ideaU,config[:intellij_ultimate]) if (config[:intellij_ultimate] && config[:intellij_ultimate][:install])
    file.write archive_heredoc($rubymine,config[:rubymine]) if (config[:rubymine] && config[:rubymine][:install])
    if config[:mounts]
      config[:mounts][:nfs].each do |data|
        file.write mount_heredoc(data, $nfs_config)
      end
    end
    
  end
  puppet_file
end

def shortcuts(config)
	File.open('/usr/local/share/applications/jetbrains-idea.desktop','w') {|file| file.write $ideaU_de} if (config[:intellij_ultimate] && config[:intellij_ultimate][:install])
	File.open('/usr/local/share/applications/jetbrains-rubymine.desktop','w') {|file| file.write $rubymine_de} if (config[:rubymine] && config[:rubymine][:install])
end

def do_puppet(config)
  file = gen_puppet(config)
  system("puppet apply #{file}" ) unless $options[:nopuppet]
end

def do_ssh(user, details)
 path = File.expand_path "~#{user}/.ssh/"
  Dir.mkdir(path) unless Dir.exists?  path
  if details[:id_rsa]
    File.open("#{path}/id_rsa", 'w') { |file| file.write details[:id_rsa] }
  end
  if details[:public_key]
    File.open("#{path}/id_rsa.pub", 'w') { |file| file.write details[:public_key] }
  end
  FileUtils.chown_R(user, user, path)
  File.open("#{path}/config",'w') do |file|
    
  end
  
end

def main(cfg_file)
  config = symbolize_keys YAML.load_file(cfg_file)
  if config[:users]
    config[:users].each do |user, details|
      next if validate_user(user, details) > 0
      create_user(user.to_s, details)
      git_config(user.to_s, details)
      do_ssh(user.to_s, details)
      dotfiles(user.to_s, details[:dotfiles]) if details[:dotfiles] && $options[:dotfiles]
    end
  end
  
  do_puppet(config)
  shortcuts(config)
end






main ARGV[0]
