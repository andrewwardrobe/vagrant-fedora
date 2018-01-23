$idea_plugins = {
  'puppet' => 'https://plugins.jetbrains.com/plugin/download?updateId=41058',
  'gerrit-intellij-plugin' => 'https://plugins.jetbrains.com/plugin/download?updateId=42037',
  'jenkins-control-plugin-0.10.2016' => 'https://plugins.jetbrains.com/plugin/download?updateId=32596',
  'Docker' => 'https://plugins.jetbrains.com/plugin/download?updateId=40538',
  'vagrant' => 'https://plugins.jetbrains.com/plugin/download?updateId=41069',
  'atlassian-idea-plugin' => 'https://plugins.jetbrains.com/plugin/download?updateId=19501'
}


$idea_url = 'https://download.jetbrains.com/idea/ideaIC-2017.3.2.tar.gz'

yumrepo{'docker-ce':
  name     => 'docker-ce-stable',
  baseurl  => 'https://download.docker.com/linux/centos/7/$basearch/stable',
  enabled  => 1,
  gpgcheck => 1,
  gpgkey   => 'https://download.docker.com/linux/centos/gpg',
}

$ruby_deps = ['zlib', 'zlib-devel', 'gcc-c++', 'patch', 'readline', 'readline-devel', 'libyaml-devel', 'libffi-devel', 'openssl-devel','make', 'bzip2', 'autoconf', 'automake', 'libtool', 'bison', 'sqlite-devel',  'gcc', 'redhat-rpm-config']

$util_packages = ['vim','curl','wget']
$dev_packages = ['java-1.8.0-openjdk-devel','ruby','rubygems','ruby-devel','nodejs','npm', 'kernel-devel', 'git']
$iac_packages = ['puppet','ansible','docker-ce','docker-compose']

$gems = ['bundle','serverspec','rails','bundler', 'puppet-lint']

ensure_packages($ruby_deps)
ensure_packages($util_packages)
ensure_packages($dev_packages)
ensure_packages($iac_packages)

package{$gems:
  require  => Package[$dev_packages],
  provider => 'gem'
}

service{'docker':
  ensure => 'running',
  enable => true
}

file{'/opt/idea':
  ensure => 'directory',
}

archive{'intellij':
  ensure        => present,
  path          => '/tmp/idea/intellij.tar.gz',
  cleanup       => true,
  extract       => true,
  extract_path  => '/opt/idea',
  creates       => '/opt/idea/idea-IC-173.4127.27',
  source        => $idea_url,
  checksum      => '70cc4f36a6517c7af980456758214414ea74c5c4f314ecf30dd2640600badd62',
  checksum_type => 'sha256',
}


$idea_plugins.each | $plugin, $url | {
  archive{"intellij_${plugin}_plugin":
    ensure        => present,
    path          => "/tmp/${plugin}.zip",
    cleanup       => true,
    extract       => true,
    extract_path  => '/opt/idea/idea-IC-173.4127.27/plugins/',
    creates       => "/opt/idea/idea-IC-173.4127.27/plugins/${plugin}",
    source        => $url,
  }
}
