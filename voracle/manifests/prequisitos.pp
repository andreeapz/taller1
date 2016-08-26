#preinstall
package { 'oracle-rdbms-server-12cR1-preinstall':
	ensure => installed,
}

#configuracion usuario
user { 'oracle':
	ensure => present,
	password => 'oracle',
	require => Package['oracle-rdbms-server-12cR1-preinstall'],
}
exec { 'change_pass':
	path => ['/bin', '/usr/bin'],
	command => "echo datum2016 | passwd oracle --stdin",
	require => User['oracle'],
}

#configuraciones en archivos
	#archivo 90-nproc.conf
file { '/etc/security/limits.d/90-nproc.conf':
	ensure => present,
	require => User['oracle'],
}
file_line { '90-nproc.conf':
	path => '/etc/security/limits.d/90-nproc.conf',
	line => '* - nproc 16384',
	match => '^\*',
	require => User['oracle'],
}
	#archivo config
file { '/etc/selinux/config':
	ensure => present,
	require => User['oracle'],
}
file_line {'config':
	ensure => present,
	path => '/etc/selinux/config',
	line => 'SELINUX=permissive',
	match => 'SELINUX=disabled',
	require => File_line['90-nproc.conf'],
}

#reinicia
#exec { 'restart':
#	path => '/sbin',
#	command => '/sbin/restart',
#	user => root,
#	require => File_line['config'],
#	refreshonly => true,
#}
#exec { 'restart':
#	path => '/usr/sbin',
#	command => 'setenforce Permissive',
#	require => File_line['config'],
#}

#bajar firewall
service { 'disable':
	name => 'iptables',
	ensure => 'stopped',
#	require => Exec['restart'],
	require => File_line['config'],
}
exec {'chkconfig':
	path => '/sbin',
	command => 'chkconfig iptables off',
	require => Service['disable'],
}

#crea directorio oracle
exec { 'directory_oracle':
	path => '/bin',
	command => 'mkdir -p /u01/app/oracle/product/12.1.0.2/db_1',
	require => Package['oracle-rdbms-server-12cR1-preinstall'],
}

#permisos /u01
file { '/u01':
	ensure => directory,
#	path => '/u01',
	owner => 'oracle',
	group => 'oinstall',
	mode => '775',
	recurse => true,
	require => Exec['directory_oracle'],
}

#cambios .bash_profile
file_line {'bash_profile_a':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export TMP=/tmp',
	require => User['oracle'],
}
file_line {'bash_profile_b':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export TMPDIR=$TMP',
	require => File_line['bash_profile_a'],
}
file_line {'bash_profile_c':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export ORACLE_HOSTNAME=ol6-121.localdomain',
	require => File_line['bash_profile_b'],
}
file_line {'bash_profile_d':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export ORACLE_UNQNAME=cdb1',
	require => File_line['bash_profile_c'],
}
file_line {'bash_profile_e':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export ORACLE_BASE=/u01/app/oracle',
	require => File_line['bash_profile_d'],
}
file_line {'bash_profile_f':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export ORACLE_HOME=$ORACLE_BASE/product/12.1.0.2/db_1',
	require => File_line['bash_profile_e'],
}
file_line {'bash_profile_g':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export ORACLE_SID=cdb1',
	require => File_line['bash_profile_f'],
}
file_line {'bash_profile_h':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export PATH=/usr/sbin:$PATH',
	require => File_line['bash_profile_g'],
}
file_line {'bash_profile_i':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export PATH=$ORACLE_HOME/bin:$PATH',
	require => File_line['bash_profile_h'],
}
file_line {'bash_profile_j':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib',
	require => File_line['bash_profile_i'],
}
file_line {'bash_profile_k':
	ensure => present,
	path => '/home/oracle/.bash_profile',
	line => 'export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib',
	require => File_line['bash_profile_j'],
}
