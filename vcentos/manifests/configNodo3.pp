$down_cassandra = "http://apache.claz.org/cassandra/2.1.14/apache-cassandra-2.1.14-bin.tar.gz"
#$down_cassandra = "http://apache.mirrors.hoobly.com/cassandra/2.0.14/apache-cassandra-2.0.14-bin.tar.gz"

#paquetes para la descarga de cassandra
package { 'java-1.8.0-openjdk':
	ensure => installed,
}
package { 'wget':
	ensure => installed,
}

#descarga de cassandra
exec { 'wget_cassandra':
	path => ['/usr/bin','/bin'],
	command => "wget -O /home/datum/nodo3/cassandra_2.1.14.tar.gz ${down_cassandra}",
	require => [Package['wget'],File['/home/datum/nodo3']],
}
exec { 'extract':
	path => '/bin',
#	command => 'tar -xvzf apache-cassandra-2.0.14-bin.tar.gz -C',
	command => '/bin/tar -zxvf /home/datum/nod3/cassandra_2.1.14.tar.gz',
#	user => 'datum',
	cwd => '/home/datum/nodo3/cassandra_2.1.14',
	require => [Exec['wget_cassandra'], File['/home/datum/nodo3/cassandra_2.1.14']],
}

#grupo y usuario
#group { 'datum':
#	ensure => present,
#}
user { 'datum':
	ensure => present,
	password => 'datum',
	managehome => true,
}

#creacion de directorio para cassandra
file { "/home/datum/nodo3":
	ensure => directory,
#	group => 'datum',
	owner => 'datum',
	mode => "755",
	require => User['datum'],
}
file { "/home/datum/nodo3/cassandra_2.1.14":
	ensure => directory,
	require => File['/home/datum/nodo3'],
}
#
